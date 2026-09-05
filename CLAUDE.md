# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`better_mailer_previews` is a mountable Rails engine (`isolate_namespace BetterMailerPreviews`) that
renders every `ActionMailer::Preview` of the host application on one page. It is a *thin layer over*
native Rails mailer previews — it never renders mail itself on the index page, it embeds
`/rails/mailers/...` URLs in `<iframe>`s. That constraint explains most of the design.

This is the jbox-web fork of `harrison-broadbent/better_mailer_previews`. jbox does not own the
`better_mailer_previews` name on RubyGems, so the gem is consumed from git and there is no publish
workflow — do not add one. Requires Ruby >= 3.2 and Rails >= 7.2.

## Commands

Use the project binstubs, never `bundle exec`.

- Full suite: `bin/rspec`
- Single file: `bin/rspec spec/requests/mailers_spec.rb`
- Single example by line: `bin/rspec spec/requests/mailers_spec.rb:24`
- Lint: `bin/rubocop` (auto-correct: `bin/rubocop -a`)
- Continuous testing: `bin/guard`
- Boot the dummy app: `bin/rails server` (engine mounted at `/better_mailer_previews`)

### Testing across Rails versions

Matrix defined in `Appraisals`, generated gemfiles in `gemfiles/` (`rails_7.2`, `rails_8.0`,
`rails_8.1`). Lockfiles are not tracked.

- One Rails version: `BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bin/rspec`
- Regenerate after editing `Appraisals`: `bin/appraisal install`

CI (`.github/workflows/ci.yml`) runs Rubocop once, then RSpec across Ruby 3.2–4.0 × the three
gemfiles.

`.ruby-version` is not tracked. If the shell resolves a Ruby the gems were not installed for,
`bin/rspec` dies in `Bundler::Definition#materialize` with `GemNotFound` — that is an environment
failure, not a code failure.

## Architecture

**Routing is wildcard-based, and that is load-bearing.** `config/routes.rb` uses
`get "/*mailer_path/:email_type"` specifically so namespaced mailers (`User::SignupMailer`) survive
the round trip. Any change to route shape must keep `mailer_path` greedy across `/`.

**Three string conversions tie the pieces together**, and they must stay mutually inverse:

1. `MailersController#native_preview_urls_by_mailer` turns a preview class into a native preview
   URL: `preview.name.underscore.gsub("_preview", "")` → `/rails/mailers/<mailer_path>/<email_name>`.
2. `ApplicationHelper#preview_path_for_url` turns that native URL back into an engine URL, prefixed
   with the engine mount point. Never hardcode the mount point.
3. `MailersController#deliver_preview` rebuilds the preview class from the path:
   `mailer_path.split("/").map(&:camelize).join("::") + "Preview"`, then `constantize`.

Break one and namespaced mailers silently 404 or raise `NameError`.

**Finding the mount point is version-sensitive.** `Engine.routes.find_script_name({})` returned the
mount path up to Rails 7.2 and returns `""` from Rails 8.0 on. `ApplicationHelper#engine_mount_path`
therefore reads it from the application route set instead, which answers identically on all
supported versions. Do not "simplify" it back.

**`show` passes query params through** to the iframe URL (`request.query_string`), so preview
classes that branch on params keep working inside the engine. Note that `&` is HTML-escaped to
`&amp;` in the rendered attribute — specs must expect the escaped form.

**Sending is a re-render, not a forward.** `deliver_preview` instantiates the preview class, decodes
`mail.body`, and ships the HTML through a fresh `ActionMailer::Base` *instance* using the host app's
configured `delivery_method`. The class-level `ActionMailer::Base.mail` shortcut was removed in
Rails 8.0 and must not come back. Headers, attachments and multipart parts of the original message
are dropped by design. The destination address is persisted in the
`better_mailer_previews_email_address` cookie to repopulate the form.

**Controllers inherit `ActionController::Base` directly**, not the engine's `ApplicationController`
— `MailersController` sets its own `layout` and declares `helper ApplicationHelper`, so the engine
works in hosts running with `config.action_controller.include_all_helpers = false`.

**Styling comes from the TailwindCSS CDN** loaded in the engine layout, plus hand-written CSS in the
same layout for the iframe scale trick (`.wrap`/`.frame`, `transform: scale(0.5)`). There is no
build step and no Tailwind config; the engine needs an internet connection to look right. The
`app/assets/stylesheets/better_mailer_previews/application.css` file exists for the Sprockets
manifest, not for the actual design.

## Tests

RSpec with a Rails dummy app under `spec/dummy/`. Fixture mailers and their `ActionMailer::Preview`
classes live in `spec/dummy/app/mailers/` and `spec/dummy/spec/mailers/previews/`, wired through
`config.action_mailer.preview_paths` in the dummy's `application.rb` — both a plain mailer and a
namespaced one (`Test::TestMailer`), because namespacing is where this engine breaks first.

Spec types are inferred from file location. `spec/dummy/**/*` is excluded from Rubocop. Coverage is
emitted by SimpleCov into `coverage/`.

When touching the controller or the helper, add the case to `spec/requests/mailers_spec.rb` — it is
the only thing exercising the actual rendering path.

## Conventions

- The gem is meant for the host's `:development` group only; assume `Rails.env.development?` at the
  mount point and do not add production-safe assumptions that complicate the code.
- `spec.files` in the gemspec globs `README.md`, `CHANGELOG.md`, `LICENSE`, `app`, `config` and
  `lib` — code placed anywhere else will not ship.

# CHANGELOG

## Unreleased

### Security

* Fix: the iframe `src` attribute was not quoted, so a crafted preview path could append arbitrary
  attributes to the tag and run script in the host application's origin (ERB escapes quotes and
  angle brackets, but not spaces)
* The engine now refuses to serve unless `Rails.env.local?`, instead of relying on the host to mount
  it behind an environment check. Override with `BetterMailerPreviews.enabled = true`
* Sending a preview no longer `constantize`s the class name taken from the URL; the preview and its
  email must both appear in `ActionMailer::Preview.all`
* The remembered-address cookie is now flagged `HttpOnly` and `SameSite=Lax`
* The TailwindCSS CDN script is pinned to a version and carries a Subresource Integrity hash

### Fixed

* Sending a multipart preview delivered an **empty** email: a multipart `Mail::Message` has an empty
  `body.decoded`. The HTML part (or the text part) is now selected and its content type propagated
* `preview_path_for_url` dropped the engine mount prefix on Rails 8, because
  `Engine.routes.find_script_name({})` returns an empty string since Rails 8.0
* Sending a preview by email raised `NoMethodError` on Rails 8, the class-level
  `ActionMailer::Base.mail` shortcut having been removed in Rails 8.0
* A preview class whose name contains `_preview` more than once once underscored (for instance
  `DailyPreviewMailerPreview`) produced a wrong URL, `gsub` having stripped every occurrence
* The engine no longer breaks the boot of a host that runs Propshaft or no asset pipeline at all:
  the Sprockets precompile hint is applied only when a precompile list actually exists
* Errors during a send — unknown preview, empty render, delivery failure — are reported in the page
  instead of raising a 500
* An engine mounted at `/` no longer yields protocol-relative `//mailer/email` links
* Engine views no longer depend on the host running with
  `config.action_controller.include_all_helpers = true`

### Changed

* Adopt the jbox-web gem layout: RSpec, Appraisal, Rubocop, Guard and a multi-version CI matrix
* Drop support of Rails < 7.2 and require Ruby >= 3.2
* Remove the unused generated scaffolding (`ApplicationController`, `ApplicationRecord`,
  `ApplicationJob`, `ApplicationMailer`) and the empty rake task stub. `ApplicationRecord` in
  particular referenced `ActiveRecord::Base` in a gem that has no model

### Added

* Request specs covering `MailersController#index`, `#show` and `#send_email`, plus the security
  behaviours above

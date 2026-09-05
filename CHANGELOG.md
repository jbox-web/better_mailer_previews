# CHANGELOG

## Unreleased

* Adopt the jbox-web gem layout: RSpec, Appraisal, Rubocop, Guard and a multi-version CI matrix
* Drop support of Rails < 7.2 and require Ruby >= 3.2
* Fix: `preview_path_for_url` dropped the engine mount prefix on Rails 8, because
  `Engine.routes.find_script_name({})` returns an empty string since Rails 8.0
* Fix: sending a preview by email raised `NoMethodError` on Rails 8, the class-level
  `ActionMailer::Base.mail` shortcut having been removed in Rails 8.0
* Fix: engine views no longer depend on the host application running with
  `config.action_controller.include_all_helpers = true`
* Add: request specs covering `MailersController#index`, `#show` and `#send_email`

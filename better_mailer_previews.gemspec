# frozen_string_literal: true

require_relative 'lib/better_mailer_previews/version'

Gem::Specification.new do |s|
  s.name        = 'better_mailer_previews'
  s.version     = BetterMailerPreviews::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Harrison Broadbent', 'Nicolas Rodriguez']
  s.email       = ['harrison@railsnotes.xyz', 'nico@nicoladmin.fr']
  s.homepage    = 'https://github.com/jbox-web/better_mailer_previews'
  s.summary     = 'A lightweight Rails engine for improved ActionMailer previews.'
  s.description = 'Better Mailer Previews is a Ruby on Rails gem that makes it easier to preview ActionMailer email templates.'
  s.license     = 'MIT'
  s.metadata    = {
    'homepage_uri'    => 'https://github.com/jbox-web/better_mailer_previews',
    'changelog_uri'   => 'https://github.com/jbox-web/better_mailer_previews/blob/main/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/jbox-web/better_mailer_previews',
    'bug_tracker_uri' => 'https://github.com/jbox-web/better_mailer_previews/issues',
  }

  s.required_ruby_version = '>= 3.2.0'

  s.files = Dir['README.md', 'CHANGELOG.md', 'LICENSE', 'app/**/*', 'config/**/*', 'lib/**/*.rb']

  s.add_dependency 'rails', '>= 7.2'
end

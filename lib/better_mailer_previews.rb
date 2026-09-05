# frozen_string_literal: true

require 'better_mailer_previews/version'
require 'better_mailer_previews/engine'

module BetterMailerPreviews

  class Error < StandardError; end

  # The requested preview class, or one of its preview emails, does not exist.
  class PreviewNotFound < Error; end

  # The preview rendered to an empty body, so there is nothing worth sending.
  class EmptyPreviewBody < Error; end

  class << self

    # Whether the engine answers requests at all.
    #
    # This engine sends mail to an address taken from the request, without any
    # authentication, so it must not be reachable from a production deployment.
    # Mounting it behind `if Rails.env.development?` is the documented practice,
    # but the engine does not rely on the host getting that right.
    #
    # Set `BetterMailerPreviews.enabled = true` to override, for instance on a
    # staging environment that is not `Rails.env.local?`.
    #
    attr_writer :enabled

    def enabled?
      return @enabled unless @enabled.nil?

      Rails.env.local?
    end
  end

  @enabled = nil
end

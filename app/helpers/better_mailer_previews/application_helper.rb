# frozen_string_literal: true

module BetterMailerPreviews
  module ApplicationHelper

    # For generating mailer preview link names on mailers/index,
    # including namespaced methods.
    #
    # input: "/rails/mailers/invoice_mailer/saas"
    # output: "Preview InvoiceMailer.SaaS →"
    #
    def preview_text_for_url(url)
      camelized = url.split('/')[3...].map(&:camelize)
      last_element = camelized.pop

      # A URL with a single segment after /rails/mailers leaves nothing to
      # prefix, and must not render as "Preview .Foo".
      pretty_mailer_preview_name =
        camelized.empty? ? last_element.to_s : "#{camelized.join('/')}.#{last_element}"

      "Preview #{pretty_mailer_preview_name} →"
    end

    # For generating mailer preview link paths on mailers/index
    #
    # input: "/rails/mailers/invoice_mailer/saas"
    # output: /better_mailer_previews/invoice_mailer/basic
    #
    def preview_path_for_url(url)
      "#{engine_mount_path}/#{url.split('/')[3..].join('/')}"
    end

    private

      # Where the host application mounted this engine.
      #
      # Rails <= 7.2 answered this with `Engine.routes.find_script_name({})`, but
      # since Rails 8.0 that returns an empty string. The mount point is still
      # readable from the application route set, which is stable across versions.
      #
      def engine_mount_path
        route = Rails.application.routes.routes.find do |candidate|
          candidate.app.respond_to?(:app) && candidate.app.app == BetterMailerPreviews::Engine
        end

        # `chomp` matters for an engine mounted at "/": the raw spec is "/", which
        # would build "//invoice_mailer/saas" — a protocol-relative URL pointing at
        # the host "invoice_mailer".
        route ? route.path.spec.to_s.chomp('/') : ''
      end
  end
end

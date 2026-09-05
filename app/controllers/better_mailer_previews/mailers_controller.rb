# frozen_string_literal: true

module BetterMailerPreviews
  class MailersController < ActionController::Base
    layout 'better_mailer_previews/application'

    # Host applications may run with `include_all_helpers = false`, which would
    # otherwise leave the engine views without our own helper.
    helper ApplicationHelper

    def index
      @urls_by_mailer = native_preview_urls_by_mailer
    end

    def show
      @mailer_path = params[:mailer_path]
      @email_type = params[:email_type]
      @email_address = cookies[:better_mailer_previews_email_address]

      # construct URL for <iframe>, passing through any query params
      @url_for_mailer = "/rails/mailers/#{@mailer_path}/#{@email_type}"
      @url_for_mailer += "?#{request.query_string}" unless request.query_string.empty?
    end

    def send_email
      email_address = params[:email_address]

      # save email in a cookie so we can re-populate the form
      cookies[:better_mailer_previews_email_address] = email_address

      deliver_preview(params[:mailer_path], params[:email_type], email_address)

      flash[:notice] = delivery_notice_for(email_address)
      redirect_back(fallback_location: root_path)
    end

    private

      # Maps every ActionMailer::Preview of the host app to the URLs of the
      # native Rails previews it exposes, which the index embeds in iframes.
      #
      def native_preview_urls_by_mailer
        ActionMailer::Preview.all.each_with_object({}) do |preview, urls_by_mailer|
          mailer_name = preview.name.underscore.gsub('_preview', '')

          urls_by_mailer[mailer_name] = preview.emails.map do |email|
            "/rails/mailers/#{mailer_name}/#{email.underscore}"
          end
        end
      end

      def delivery_notice_for(email_address)
        "sent to #{email_address} (via #{Rails.application.config.action_mailer.delivery_method})"
      end

      # Instantiate the preview class (ie: InvoiceMailerPreview), render its
      # preview html into a string, then send that string to the address from
      # the form submission.
      #
      # mailer_path: underscore_case of base mailer path | test/invoice_mailer
      # email_type: string mailer method to call on class | "round"
      # email_address: string email address to send to | "test@t.com"
      #
      def deliver_preview(mailer_path, email_type, email_address)
        preview_class_string = mailer_path.split('/').map(&:camelize).join('::').concat('Preview')
        preview_method = email_type.to_sym

        mail = preview_class_string.constantize.new.public_send(preview_method).message

        # NOTE: this goes through an ActionMailer::Base *instance*. The class-level
        # `ActionMailer::Base.mail` shortcut worked up to Rails 7.2 but was removed
        # in Rails 8.0.
        ActionMailer::Base.new.mail(
          content_type: 'text/html',
          from:         'better-mailer-previews@railsnotes.xyz',
          to:           email_address,
          subject:      "#{preview_class_string}.#{preview_method} (via BetterMailerPreviews)",
          body:         mail.body.decoded
        ).deliver
      end
  end
end

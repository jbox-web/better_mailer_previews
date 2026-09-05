# frozen_string_literal: true

module BetterMailerPreviews
  class MailersController < ActionController::Base
    layout 'better_mailer_previews/application'

    # Host applications may run with `include_all_helpers = false`, which would
    # otherwise leave the engine views without our own helper.
    helper ApplicationHelper

    before_action :ensure_enabled

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

      remember_email_address(email_address)
      report_delivery(email_address)

      redirect_back(fallback_location: root_path, allow_other_host: false)
    end

    private

      def ensure_enabled
        head :forbidden unless BetterMailerPreviews.enabled?
      end

      # Maps every ActionMailer::Preview of the host app to the URLs of the
      # native Rails previews it exposes, which the index embeds in iframes.
      #
      # `ActionMailer::Preview.all` is deliberately not memoized: in development
      # it is what picks up a preview class written since the last page load.
      #
      def native_preview_urls_by_mailer
        ActionMailer::Preview.all.each_with_object({}) do |preview, urls_by_mailer|
          # Anchored on the suffix, not a plain gsub: a class named
          # MyPreviewMailerPreview would otherwise lose both occurrences and
          # yield "my_mailer".
          mailer_name = preview.name.underscore.delete_suffix('_preview')

          urls_by_mailer[mailer_name] = preview.emails.map do |email|
            "/rails/mailers/#{mailer_name}/#{email.underscore}"
          end
        end
      end

      # save email in a cookie so we can re-populate the form
      def remember_email_address(email_address)
        cookies[:better_mailer_previews_email_address] = {
          value:     email_address,
          httponly:  true,
          same_site: :lax,
        }
      end

      def report_delivery(email_address)
        deliver_preview(params[:mailer_path], params[:email_type], email_address)
        flash[:notice] = "sent to #{email_address} (via #{delivery_method})"
      rescue PreviewNotFound, EmptyPreviewBody => e
        flash[:alert] = e.message
      rescue StandardError => e
        # Anything the delivery itself raises: an unreachable SMTP host, a
        # rejected recipient. Reported rather than swallowed — both the class and
        # the message reach the page.
        flash[:alert] = "delivery failed — #{e.class}: #{e.message}"
      end

      def delivery_method
        Rails.application.config.action_mailer.delivery_method || 'default'
      end

      # Look the preview up among the ones the host actually declares, rather
      # than `constantize`-ing whatever the URL carries.
      #
      # mailer_path: underscore_case of base mailer path | test/invoice_mailer
      # email_type: string mailer method to call on class | "round"
      #
      def find_preview(mailer_path, email_type)
        wanted = mailer_path.split('/').map(&:camelize).join('::').concat('Preview')
        preview = ActionMailer::Preview.all.find { |klass| klass.name == wanted }

        raise PreviewNotFound.new("unknown mailer preview: #{wanted}") if preview.nil?
        raise PreviewNotFound.new("unknown preview email: #{wanted}##{email_type}") unless preview.emails.include?(email_type)

        [preview, wanted]
      end

      # A mailer with both an .html.erb and a .text.erb renders a multipart
      # message, whose own `body.decoded` is an empty string — sending that
      # delivers a blank email. Pick the part that actually carries content.
      #
      def rendered_preview(preview, email_type, preview_class_string)
        mail = preview.new.public_send(email_type).message
        part = mail.html_part || mail.text_part || mail
        body = part.body.decoded

        raise EmptyPreviewBody.new("#{preview_class_string}##{email_type} rendered an empty body") if body.empty?

        [body, part.content_type || 'text/html']
      end

      # Render the preview into a string and send that string to the address from
      # the form submission.
      #
      def deliver_preview(mailer_path, email_type, email_address)
        preview, preview_class_string = find_preview(mailer_path, email_type)
        body, content_type = rendered_preview(preview, email_type, preview_class_string)

        # NOTE: this goes through an ActionMailer::Base *instance*. The class-level
        # `ActionMailer::Base.mail` shortcut worked up to Rails 7.2 but was removed
        # in Rails 8.0.
        ActionMailer::Base.new.mail(
          content_type: content_type,
          from:         'better-mailer-previews@railsnotes.xyz',
          to:           email_address,
          subject:      "#{preview_class_string}.#{email_type} (via BetterMailerPreviews)",
          body:         body
        ).deliver
      end
  end
end

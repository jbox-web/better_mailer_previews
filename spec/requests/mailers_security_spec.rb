# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mailer previews — security' do
  describe 'HTML attribute escaping' do
    # Regression for the unquoted `src` attribute: ERB escapes quotes and angle
    # brackets but not spaces, so an unquoted attribute let a crafted path append
    # arbitrary attributes to the iframe tag.
    it 'does not let a crafted path escape the iframe src attribute' do
      get '/better_mailer_previews/invoice_mailer/x%20onload=alert(1)'

      expect(response.body).to_not include 'onload=alert(1) frameborder'
    end

    it 'keeps the crafted path inside the quoted attribute' do
      get '/better_mailer_previews/invoice_mailer/x%20onload=alert(1)'

      expect(response.body).to include 'src="/rails/mailers/invoice_mailer/x onload=alert(1)"'
    end
  end

  describe 'environment gating' do
    after { BetterMailerPreviews.enabled = nil }

    it 'serves the index while enabled' do
      get '/better_mailer_previews'

      expect(response).to have_http_status(:ok)
    end

    it 'refuses the index when disabled' do
      BetterMailerPreviews.enabled = false
      get '/better_mailer_previews'

      expect(response).to have_http_status(:forbidden)
    end

    it 'refuses to send mail when disabled' do
      BetterMailerPreviews.enabled = false
      ActionMailer::Base.deliveries.clear
      post '/better_mailer_previews/invoice_mailer/saas/send', params: { email_address: 'a@b.c' }

      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe 'preview allow-listing' do
    before { ActionMailer::Base.deliveries.clear }

    it 'refuses a class that is not a declared preview' do
      post '/better_mailer_previews/kernel/system/send', params: { email_address: 'a@b.c' }

      expect(flash[:alert]).to eq 'unknown mailer preview: KernelPreview'
    end

    it 'sends nothing for an undeclared preview class' do
      post '/better_mailer_previews/kernel/system/send', params: { email_address: 'a@b.c' }

      expect(ActionMailer::Base.deliveries).to be_empty
    end

    it 'refuses a method that is not a declared preview email' do
      post '/better_mailer_previews/invoice_mailer/inspect/send', params: { email_address: 'a@b.c' }

      expect(flash[:alert]).to eq 'unknown preview email: InvoiceMailerPreview#inspect'
    end

    it 'sends nothing for an undeclared preview email' do
      post '/better_mailer_previews/invoice_mailer/inspect/send', params: { email_address: 'a@b.c' }

      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe 'CSRF protection' do
    # The dummy app disables forgery protection for the whole test environment,
    # so it has to be turned back on to exercise it at all.
    around do |example|
      previous = ActionController::Base.allow_forgery_protection
      ActionController::Base.allow_forgery_protection = true
      example.run
      ActionController::Base.allow_forgery_protection = previous
    end

    before { ActionMailer::Base.deliveries.clear }

    it 'rejects a POST carrying no authenticity token' do
      post '/better_mailer_previews/invoice_mailer/saas/send', params: { email_address: 'a@b.c' }

      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'sends nothing for a forged POST' do
      post '/better_mailer_previews/invoice_mailer/saas/send', params: { email_address: 'a@b.c' }

      expect(ActionMailer::Base.deliveries).to be_empty
    end
  end

  describe 'the remembered address cookie' do
    # Set-Cookie is an array of header lines, one per cookie.
    def address_cookie
      post '/better_mailer_previews/invoice_mailer/saas/send', params: { email_address: 'a@b.c' }
      Array(response.headers['Set-Cookie']).find { |line| line.start_with?('better_mailer_previews_email_address=') }
    end

    it 'is flagged HttpOnly' do
      expect(address_cookie).to match(/httponly/i)
    end

    it 'is flagged SameSite=Lax' do
      expect(address_cookie).to match(/samesite=lax/i)
    end
  end
end

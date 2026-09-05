# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Mailer previews' do
  describe 'GET /better_mailer_previews' do
    before { get '/better_mailer_previews' }

    it 'succeeds' do
      expect(response).to have_http_status(:ok)
    end

    it 'embeds the native preview URL of a plain mailer' do
      expect(response.body).to include '/rails/mailers/invoice_mailer/saas'
    end

    it 'embeds the native preview URL of a namespaced mailer' do
      expect(response.body).to include '/rails/mailers/test/test_mailer/github_test'
    end

    it 'links to the engine preview page, mount prefix included' do
      expect(response.body).to include '/better_mailer_previews/invoice_mailer/saas'
    end
  end

  describe 'GET /better_mailer_previews/:mailer_path/:email_type' do
    it 'succeeds for a plain mailer' do
      get '/better_mailer_previews/invoice_mailer/saas'
      expect(response).to have_http_status(:ok)
    end

    it 'succeeds for a namespaced mailer' do
      get '/better_mailer_previews/test/test_mailer/github_test'
      expect(response).to have_http_status(:ok)
    end

    it 'points the iframe at the native preview' do
      get '/better_mailer_previews/invoice_mailer/saas'
      expect(response.body).to include 'src=/rails/mailers/invoice_mailer/saas'
    end

    it 'passes query params through to the iframe URL' do
      get '/better_mailer_previews/invoice_mailer/saas', params: { locale: 'fr', part: 'text' }
      expect(response.body).to include 'src=/rails/mailers/invoice_mailer/saas?locale=fr&amp;part=text'
    end
  end

  describe 'POST /better_mailer_previews/:mailer_path/:email_type/send' do
    before { ActionMailer::Base.deliveries.clear }

    def send_preview(path = '/better_mailer_previews/invoice_mailer/saas/send', address: 'someone@example.com')
      post path, params: { email_address: address }
    end

    it 'redirects back' do
      send_preview
      expect(response).to have_http_status(:redirect)
    end

    it 'delivers exactly one email' do
      send_preview
      expect(ActionMailer::Base.deliveries.size).to eq 1
    end

    it 'delivers to the submitted address' do
      send_preview
      expect(ActionMailer::Base.deliveries.last.to).to eq ['someone@example.com']
    end

    it 'names the preview class and method in the subject' do
      send_preview
      expect(ActionMailer::Base.deliveries.last.subject).to eq 'InvoiceMailerPreview.saas (via BetterMailerPreviews)'
    end

    it 'ships the rendered preview body' do
      send_preview
      expect(ActionMailer::Base.deliveries.last.body.decoded).to include 'SaaS invoice'
    end

    it 'remembers the address in a cookie' do
      send_preview
      expect(cookies['better_mailer_previews_email_address']).to eq 'someone@example.com'
    end

    it 'resolves a namespaced preview class' do
      send_preview('/better_mailer_previews/test/test_mailer/github_test/send')
      expect(ActionMailer::Base.deliveries.last.subject).to eq 'Test::TestMailerPreview.github_test (via BetterMailerPreviews)'
    end
  end
end

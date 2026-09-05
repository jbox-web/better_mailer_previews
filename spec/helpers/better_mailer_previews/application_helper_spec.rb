# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BetterMailerPreviews::ApplicationHelper do
  describe '#preview_text_for_url' do
    it 'generates the preview text for a URL' do
      url = '/rails/mailers/invoice_mailer/saas'
      expect(helper.preview_text_for_url(url)).to eq 'Preview InvoiceMailer.Saas →'
    end

    it 'generates the preview text for a namespaced URL' do
      url = '/rails/mailers/test/test_mailer/github_test'
      expect(helper.preview_text_for_url(url)).to eq 'Preview Test/TestMailer.GithubTest →'
    end
  end

  describe '#preview_path_for_url' do
    it 'generates the preview path for a URL' do
      url = '/rails/mailers/invoice_mailer/saas'
      expect(helper.preview_path_for_url(url)).to eq '/better_mailer_previews/invoice_mailer/saas'
    end

    it 'generates the preview path for a namespaced URL' do
      url = '/rails/mailers/test/test_mailer/github_test'
      expect(helper.preview_path_for_url(url)).to eq '/better_mailer_previews/test/test_mailer/github_test'
    end
  end
end

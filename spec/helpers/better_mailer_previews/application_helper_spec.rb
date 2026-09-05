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

    it 'does not emit a leading dot when there is a single segment' do
      expect(helper.preview_text_for_url('/rails/mailers/foo')).to eq 'Preview Foo →'
    end
  end

  describe '#preview_email_label' do
    it 'keeps only the email name, the mailer being carried by the section header' do
      expect(helper.preview_email_label('/rails/mailers/invoice_mailer/saas')).to eq 'Saas'
    end

    it 'titleizes a multi-word email name' do
      expect(helper.preview_email_label('/rails/mailers/test/test_mailer/github_test')).to eq 'Github Test'
    end
  end

  describe '#preview_body_url' do
    it 'asks Rails for the body part, dropping the preview chrome' do
      expect(helper.preview_body_url('/rails/mailers/invoice_mailer/saas'))
        .to eq '/rails/mailers/invoice_mailer/saas?part=text%2Fhtml'
    end
  end

  describe '#engine_mount_path' do
    # Built from plain structs rather than doubles: the helper only calls
    # `app.app` and `path.spec.to_s` on the route.
    def route_mounted_at(spec)
      constraints = Struct.new(:app)
      path        = Struct.new(:spec)
      route       = Struct.new(:app, :path)

      route.new(constraints.new(BetterMailerPreviews::Engine), path.new(spec))
    end

    it 'strips the trailing slash of an engine mounted at the root' do
      allow(Rails.application.routes).to receive(:routes).and_return([route_mounted_at('/')])

      expect(helper.send(:engine_mount_path)).to eq ''
    end

    it 'builds a single-slash path for an engine mounted at the root' do
      allow(Rails.application.routes).to receive(:routes).and_return([route_mounted_at('/')])

      expect(helper.preview_path_for_url('/rails/mailers/invoice_mailer/saas')).to eq '/invoice_mailer/saas'
    end

    it 'falls back to an empty prefix when the engine is not mounted' do
      allow(Rails.application.routes).to receive(:routes).and_return([])

      expect(helper.send(:engine_mount_path)).to eq ''
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

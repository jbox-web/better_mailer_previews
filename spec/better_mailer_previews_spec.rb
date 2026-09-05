# frozen_string_literal: true

require 'spec_helper'

RSpec.describe BetterMailerPreviews do
  describe 'VERSION' do
    it 'exposes a version string' do
      expect(described_class::VERSION::STRING).to match(/\A\d+\.\d+\.\d+/)
    end

    it 'exposes a Gem::Version' do
      expect(described_class.gem_version).to eq Gem::Version.new(described_class::VERSION::STRING)
    end
  end
end

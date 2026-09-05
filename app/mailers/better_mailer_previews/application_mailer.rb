# frozen_string_literal: true

module BetterMailerPreviews
  class ApplicationMailer < ActionMailer::Base
    default from: 'from@example.com'
    layout 'mailer'
  end
end

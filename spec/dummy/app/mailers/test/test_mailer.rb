module Test
  class TestMailer < ApplicationMailer
    def github_test
      mail(to: "customer@example.com", subject: "Namespaced mailer")
    end
  end
end

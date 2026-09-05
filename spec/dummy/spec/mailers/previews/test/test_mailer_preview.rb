module Test
  class TestMailerPreview < ActionMailer::Preview
    def github_test
      Test::TestMailer.github_test
    end
  end
end

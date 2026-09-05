class DailyPreviewMailerPreview < ActionMailer::Preview
  def digest
    DailyPreviewMailer.digest
  end
end

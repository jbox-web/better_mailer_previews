# Underscored, its preview class reads "daily_preview_mailer_preview": the
# suffix "_preview" appears twice, which a gsub would strip twice.
class DailyPreviewMailer < ApplicationMailer
  def digest
    mail(to: "customer@example.com", subject: "Daily digest")
  end
end

class InvoiceMailer < ApplicationMailer
  def saas
    mail(to: "customer@example.com", subject: "Your SaaS invoice")
  end

  def basic
    mail(to: "customer@example.com", subject: "Your invoice")
  end
end

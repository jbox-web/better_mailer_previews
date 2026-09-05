class InvoiceMailer < ApplicationMailer
  def saas
    mail(to: "customer@example.com", subject: "Your SaaS invoice")
  end

  def basic
    mail(to: "customer@example.com", subject: "Your invoice")
  end

  # Both an .html.erb and a .text.erb exist for this action, so the rendered
  # message is multipart. Its own body.decoded is empty.
  def multipart
    mail(to: "customer@example.com", subject: "Multipart invoice")
  end
end

class InvoiceMailerPreview < ActionMailer::Preview
  def saas
    InvoiceMailer.saas
  end

  def basic
    InvoiceMailer.basic
  end

  def multipart
    InvoiceMailer.multipart
  end
end

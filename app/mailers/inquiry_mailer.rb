class InquiryMailer < ApplicationMailer
  def inquiry_email(email:, subject:, message:, voter: nil)
    @email = email
    @subject = subject
    @message = message
    @voter = voter

    recipient = ENV["INQUIRY_RECIPIENT_EMAIL"].presence || "support@ascent.ing"

    mail(
      to: recipient,
      reply_to: @email,
      subject: "[Ascent Inquiry] #{@subject}"
    )
  end
end

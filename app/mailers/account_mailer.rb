class AccountMailer < Devise::Mailer
  def confirmation_instructions(record, token, opts = {})
    opts[:subject] = t("devise.mailer.confirmation_instructions.new_email_subject") if record.pending_reconfirmation?
    super
  end
end

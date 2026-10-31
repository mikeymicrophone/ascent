class ApplicationMailer < ActionMailer::Base
  default from: "Ascent <no-reply@were.ascent.ing>", reply_to: "support@ascent.ing"
  layout "mailer"
end

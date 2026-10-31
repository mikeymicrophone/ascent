require "rails_helper"

RSpec.describe AccountMailer do
  let(:new_voter) { create :voter, :unverified }

  describe "confirmation instructions for a new signup" do
    subject(:mail) { new_voter.send_confirmation_instructions; ActionMailer::Base.deliveries.last }

    it "is sent from the sending subdomain with replies going to support" do
      expect(mail.from).to eq [ "no-reply@were.ascent.ing" ]
      expect(mail.reply_to).to eq [ "support@ascent.ing" ]
      expect(mail.to).to eq [ new_voter.email ]
    end

    it "invites the voter to confirm and try the ballot" do
      expect(mail.subject).to eq "Confirm your email to finish setting up Ascent"
      expect(mail.html_part.body.to_s).to include "Confirm my email", "rank every politician in the country"
      expect(mail.text_part.body.to_s).to match %r{/voters/confirmation\?confirmation_token=}
    end
  end

  describe "confirmation instructions after an email change" do
    let(:changed_voter) { create(:voter, :verified).tap { |voter| voter.update!(email: "new-address@example.com") } }
    subject(:mail) { changed_voter.send_confirmation_instructions; ActionMailer::Base.deliveries.last }

    it "goes to the new address with its own subject and wording" do
      expect(mail.to).to eq [ "new-address@example.com" ]
      expect(mail.subject).to eq "Confirm your new email address"
      expect(mail.html_part.body.to_s).to include "Confirm new email"
    end
  end

  describe "password reset" do
    subject(:mail) { new_voter.confirm; new_voter.send_reset_password_instructions; ActionMailer::Base.deliveries.last }

    it "names the link's lifetime and says what happens if ignored" do
      expect(mail.subject).to eq "Reset your Ascent password"
      expect(mail.html_part.body.to_s).to include "6 hours", "your password stays the same"
      expect(mail.text_part.body.to_s).to match %r{/voters/password/edit\?reset_password_token=}
    end
  end

  describe "password change notice" do
    it "is sent when a confirmed voter's password changes" do
      voter = create :voter
      ActionMailer::Base.deliveries.clear
      voter.update!(password: "a-new-password-456", password_confirmation: "a-new-password-456")
      mail = ActionMailer::Base.deliveries.last
      expect(mail.subject).to eq "Your Ascent password was changed"
      expect(mail.html_part.body.to_s).to include "reply right away"
    end
  end
end

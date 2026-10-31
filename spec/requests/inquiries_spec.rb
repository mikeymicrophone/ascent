require "rails_helper"

RSpec.describe "Inquiries", type: :request do
  include ActiveJob::TestHelper

  def page
    Nokogiri::HTML(response.body)
  end

  it "renders the inquiry form with empty email when signed out and all four subject tags" do
    get new_inquiry_path

    expect(response).to have_http_status(:ok)
    expect(page.at_css("input#inquiry_email")["value"]).to be_nil
    expect(page.at_css("input#inquiry_subject[data-inquiry-subject-target='input']")).to be_present
    expect(page.at_css("textarea#inquiry_message")).to be_present

    tag_buttons = page.css("button[data-action='click->inquiry-subject#select']")
    expect(tag_buttons.map(&:text)).to eq([
      "features",
      "question",
      "I’m involved in an election",
      "I want to invest"
    ])
    expect(tag_buttons.map { it["data-inquiry-subject-value-param"] }).to eq(Inquiry::SUBJECT_TAGS)
  end

  it "prefills the email field when a voter is signed in" do
    voter = create(:voter, email: "marisol.vega@example.com")
    sign_in voter

    get new_inquiry_path

    expect(response).to have_http_status(:ok)
    expect(page.at_css("input#inquiry_email")["value"]).to eq("marisol.vega@example.com")
  end

  it "sends an email to INQUIRY_RECIPIENT_EMAIL on valid submission" do
    voter = create(:voter, first_name: "Marisol", last_name: "Vega", email: "marisol.vega@example.com")
    sign_in voter

    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("INQUIRY_RECIPIENT_EMAIL").and_return("inquiries@micharisma.example.com")

    perform_enqueued_jobs do
      expect do
        post inquiries_path, params: {
          inquiry: {
            email: "marisol.vega@example.com",
            subject: "I’m involved in an election",
            message: "We have a municipal election coming up in November."
          }
        }
      end.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    expect(response).to redirect_to(new_inquiry_path)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([ "inquiries@micharisma.example.com" ])
    expect(mail.reply_to).to eq([ "marisol.vega@example.com" ])
    expect(mail.subject).to eq("[Ascent Inquiry] I’m involved in an election")
    expect(mail.body.encoded).to include("We have a municipal election coming up in November.")
    expect(mail.body.encoded).to include("Marisol Vega")
  end

  it "renders validation errors and preserves input when fields are invalid" do
    expect do
      post inquiries_path, params: {
        inquiry: {
          email: "not-an-email",
          subject: "",
          message: "Keep this message text"
        }
      }
    end.not_to have_enqueued_mail(InquiryMailer, :inquiry_email)

    expect(response).to have_http_status(:unprocessable_content)
    expect(page.at_css("[role='alert']")).to be_present
    expect(page.at_css("textarea#inquiry_message").text).to eq("Keep this message text")
  end
end

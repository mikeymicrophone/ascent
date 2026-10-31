class InquiriesController < ApplicationController
  def new
    authorize! :inquiry
    @inquiry = Inquiry.new(
      email: current_voter&.email,
      subject: params[:subject]
    )
    render Views::Inquiries::NewView.new(inquiry: @inquiry)
  end

  def create
    authorize! :inquiry
    @inquiry = Inquiry.new(inquiry_params)

    if @inquiry.valid?
      InquiryMailer.inquiry_email(
        email: @inquiry.email,
        subject: @inquiry.subject,
        message: @inquiry.message,
        voter: current_voter
      ).deliver_later

      redirect_to new_inquiry_path, notice: "Your inquiry has been sent.", status: :see_other
    else
      render Views::Inquiries::NewView.new(inquiry: @inquiry), status: :unprocessable_entity
    end
  end

  private

  def inquiry_params
    params.require(:inquiry).permit(:email, :subject, :message)
  end
end

class ChannelsController < ApplicationController
  def index
    channels = Channel.includes(:owner, :reviewed_by)
      .order(Arel.sql("CASE WHEN review_status = 'pending' THEN 0 ELSE 1 END"), :platform, :handle, :id)
    if Channel::REVIEW_STATUSES.include?(params[:review_status])
      channels = channels.where(review_status: params[:review_status])
    end
    @pagy, @channels = pagy(channels)
    render Views::Channels::IndexView.new(channels: @channels, pagy: @pagy, review_status: params[:review_status])
  end

  def update
    @channel = Channel.find(params[:id])

    case params[:review_status]
    when "approved"
      @channel.approve!(current_voter)
    when "rejected"
      @channel.reject!(current_voter)
    else
      head :bad_request
      return
    end

    redirect_to channels_path, notice: "Channel marked as #{@channel.review_status}.", status: :see_other
  end
end

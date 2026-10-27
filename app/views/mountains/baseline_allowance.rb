# frozen_string_literal: true

# Five pips for the day's saved baseline changes: used, the one saving would use, and those still free.
class Views::Mountains::BaselineAllowance < Views::ApplicationView
  prop :mountain, Mountain

  def view_template
    div(class: "baseline-allowance", id: "baseline-allowance") do
      div(class: "allowance-pips", aria: { hidden: true }) do
        VoterRaceBaseline::DAILY_CHANGE_LIMIT.times { span(class: "allowance-pip allowance-pip-#{pip_state(it)}") }
      end
      p(class: "allowance-note") { allowance_note }
    end
  end

  private

  def left
    @left ||= @mountain.baseline_changes_left_today
  end

  def used
    VoterRaceBaseline::DAILY_CHANGE_LIMIT - left
  end

  def baseline_pending?
    @mountain.unsaved_changes[:baseline].present? && @mountain.saved_baseline_record.present?
  end

  def pip_state(index)
    if index < used then "used"
    elsif baseline_pending? && index == used then "pending"
    else "free"
    end
  end

  def allowance_note
    if baseline_pending?
      "Saving uses 1 of your #{left} baseline changes left today."
    else
      "#{left} of #{VoterRaceBaseline::DAILY_CHANGE_LIMIT} baseline changes left today. Ratings are unlimited."
    end
  end
end

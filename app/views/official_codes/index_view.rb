# frozen_string_literal: true

# Every section of code on Ascent, or one law's, by number: search by title.
class Views::OfficialCodes::IndexView < Views::ApplicationView
  prop :official_codes, ActiveRecord::Relation
  prop :pagy, _Nilable(Pagy)
  prop :parent, _Nilable(Policy)
  prop :filters, Hash

  def view_template
    IndexPage(title: @parent ? "Code for #{@parent.title}" : "Official codes", records: @official_codes, pagy: @pagy, noun: "official code",
      frame: "official-codes-list", eyebrow: "Governance", lede: "The sections of code that carry laws out, with how they are enforced.",
      trail: [ [ "Policies", policies_path ], *([ [ @parent.title, @parent ] ] if @parent) ], clear_path: list_path,
      actions: (method(:new_code_link) if allowed_to?(:new?, OfficialCode)), filters: method(:filter_form)) { code_row(it) }
  end

  private

  def list_path
    @parent ? policy_official_codes_path(@parent) : official_codes_path
  end

  def new_code_link
    PillLink(label: "New official code", path: new_official_code_path, icon: :plus)
  end

  def filter_form
    FilterForm(url: list_path, label: "Filter official codes", placeholder: "Title", values: @filters, clear_path: list_path)
  end

  def code_row(code)
    ListRow(record: code, title: code.title, meta: [ code.code_number, code.policy.title ].compact_blank.join(" · "), detail: code.summary.presence) do
      StatusChip(status: code.status) if code.status.present?
    end
  end
end

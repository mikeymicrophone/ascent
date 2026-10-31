require "rails_helper"

RSpec.describe "Approach filters", type: :request do
  let!(:housing) { create(:topic, title: "Housing") }
  let!(:education) { create(:topic, title: "Education") }
  let!(:rents) { create(:issue, title: "Rising rents", topic: housing) }
  let!(:supply) { create(:issue, title: "Housing supply", topic: housing) }
  let!(:funding) { create(:issue, title: "School funding", topic: education) }
  let!(:rent_cap) { create(:approach, title: "Cap annual rent increases", issue: rents) }
  let!(:vouchers) { create(:approach, title: "Expand housing vouchers", issue: rents) }
  let!(:homes) { create(:approach, title: "Build homes near transit", issue: supply) }
  let!(:teachers) { create(:approach, title: "Hire more teachers", issue: funding) }

  def page
    Nokogiri::HTML(response.body)
  end

  def titles
    page.css("#approaches-list .list-row-title").map(&:text)
  end

  it "offers topics and issues labeled with their topic" do
    get approaches_path

    expect(response).to have_http_status(:ok)
    expect(titles).to eq([ homes.title, rent_cap.title, vouchers.title, teachers.title ])
    expect(page.css('select[name="topic_id"] option').map(&:text)).to eq([ "Every topic", "Education", "Housing" ])
    expect(page.css('select[name="issue_id"] option').map(&:text)).to eq([
      "Every issue", "Housing · Housing supply", "Housing · Rising rents", "Education · School funding"
    ])
    form = page.at_css("form.filter-form")
    expect(form["data-controller"]).to eq("form-submit")
    expect(form.css("select").map { it["data-action"] }).to eq([ "change->form-submit#submit" ] * 2)
    expect(form.at_css('input[name="q"]')["data-action"]).to be_nil
  end

  it "keeps other list filters on their existing manual submission behavior" do
    get issues_path
    expect(page.at_css("form.filter-form")["data-controller"]).to be_nil
    expect(page.at_css('select[name="topic_id"]')["data-action"]).to be_nil
  end

  it "filters by topic across its issues and keeps the controls selected" do
    get approaches_path, params: { topic_id: housing.id }

    expect(titles).to eq([ homes.title, rent_cap.title, vouchers.title ])
    expect(page.at_css('select[name="topic_id"] option[selected]')["value"]).to eq(housing.id.to_s)
    expect(page.at_css('form.filter-form')["action"]).to eq(approaches_path)
    expect(page.css('select[name="issue_id"] option').map(&:text)).to eq([
      "Every issue", "Housing · Housing supply", "Housing · Rising rents"
    ])
  end

  it "filters by issue without turning the general list into a nested list" do
    get approaches_path, params: { issue_id: rents.id }

    expect(titles).to eq([ rent_cap.title, vouchers.title ])
    expect(page.at_css('select[name="issue_id"] option[selected]')["value"]).to eq(rents.id.to_s)
    expect(page.at_css('form.filter-form')["action"]).to eq(approaches_path)
    clear = page.css(".filter-actions a").find { it.text == "Clear" }
    expect(clear["href"]).to eq(approaches_path)
    get clear["href"]
    expect(titles.size).to eq(4)
  end

  it "combines title search with topic and issue" do
    get approaches_path, params: { topic_id: housing.id, issue_id: rents.id, q: "voucher" }

    expect(titles).to eq([ vouchers.title ])
    expect(page.at_css('input[name="q"]')["value"]).to eq("voucher")
    expect(page.at_css('select[name="issue_id"] option[selected]')["value"]).to eq(rents.id.to_s)
  end

  it "clears an issue that is outside the applied topic" do
    get approaches_path, params: { topic_id: education.id, issue_id: rents.id }

    expect(titles).to eq([ teachers.title ])
    expect(page.at_css('select[name="topic_id"] option[selected]')["value"]).to eq(education.id.to_s)
    issue = page.at_css('select[name="issue_id"]')
    expect(issue.css("option").map(&:text)).to eq([ "Every issue", "Education · School funding" ])
    expect(issue.css("option[selected]").map { it["value"] }).not_to include(rents.id.to_s)
  end

  it "offers all issues again when the topic is cleared" do
    get approaches_path, params: { topic_id: "", issue_id: rents.id }

    expect(titles).to eq([ rent_cap.title, vouchers.title ])
    expect(page.css('select[name="issue_id"] option').map { it["value"] }).to contain_exactly("", rents.id.to_s, supply.id.to_s, funding.id.to_s)
    expect(page.at_css('select[name="issue_id"] option[selected]')["value"]).to eq(rents.id.to_s)
  end

  it "retains all filters through pagination and starts new submissions on the first page" do
    26.times { |index| create(:approach, title: "Add housing vouchers in District #{index + 1}", issue: rents) }
    get approaches_path, params: { topic_id: housing.id, issue_id: rents.id, q: "voucher" }

    next_link = page.at_css('a[rel="next"]')["href"]
    values = Rack::Utils.parse_nested_query(URI.parse(next_link).query)
    expect(values).to include("topic_id" => housing.id.to_s, "issue_id" => rents.id.to_s, "q" => "voucher", "page" => "2")
    get next_link

    expect(titles.size).to eq(2)
    expect(page.at_css('select[name="topic_id"] option[selected]')["value"]).to eq(housing.id.to_s)
    expect(page.at_css('select[name="issue_id"] option[selected]')["value"]).to eq(rents.id.to_s)
    form = page.at_css('form.filter-form')
    expect(form.css('input[name="page"]')).to be_empty
    expect(form["action"]).to eq(approaches_path)
  end

  it "keeps an issue's nested list and Clear link scoped to that issue" do
    get issue_approaches_path(rents), params: { q: "voucher" }

    expect(titles).to eq([ vouchers.title ])
    form = page.at_css('form.filter-form')
    expect(form["action"]).to eq(issue_approaches_path(rents))
    expect(form.css("select")).to be_empty
    clear = form.css(".filter-actions a").find { it.text == "Clear" }
    expect(clear["href"]).to eq(issue_approaches_path(rents))
    get clear["href"]
    expect(titles).to eq([ rent_cap.title, vouchers.title ])
  end

  it "treats blank filters as the unfiltered list" do
    get approaches_path, params: { topic_id: "", issue_id: "", q: "" }
    expect(response).to have_http_status(:ok)
    expect(titles.size).to eq(4)
  end
end

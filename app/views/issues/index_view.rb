class Views::Issues::IndexView < Views::ApplicationView
  def initialize(issues:, pagy: nil, notice: nil)
    @issues = issues
    @pagy = pagy
    @notice = notice
  end

  def view_template(&)
    div(class: "scaffold issues-index", id: "index_issues") do
      render_notice if @notice.present?
      
      div do
        h1 { "Issues" }
        link_to "New issue", 
                new_issue_path,
                class: "primary"
      end

      div(id: "issues") do
        if @issues.any?
          @issues.each do |issue|
            div(id: dom_id(issue, :list_item)) do
              IssuePartial(issue: issue)
              
              Ui::ResourceActions(resource: issue)
            end
          end
        else
          p { "No issues found." }
        end
      end

      Views::Components::Pagination(pagy: @pagy) if @pagy
    end
  end

  private

  def render_notice
    p(id: "notice") do
      @notice
    end
  end
end
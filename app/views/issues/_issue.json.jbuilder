json.extract! issue, :id, :title, :description, :topic_id, :created_at, :updated_at
json.url issue_url(issue, format: :json)

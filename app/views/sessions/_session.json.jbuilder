json.extract! session, :id, :session_string, :click_count, :team_id, :created_at, :updated_at
json.url session_url(session, format: :json)

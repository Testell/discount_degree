json.extract! course, :id, :credit_hours, :school_id, :name, :code, :degree_requirement_id, :created_at, :updated_at
json.url course_url(course, format: :json)

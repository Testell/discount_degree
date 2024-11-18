json.extract! course_requirement, :id, :course_id, :degree_requirement_id, :is_mandatory, :created_at, :updated_at
json.url course_requirement_url(course_requirement, format: :json)

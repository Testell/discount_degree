require 'csv'

# Clear existing data
puts "Clearing existing data..."
SavedPlan.destroy_all
Plan.destroy_all
CourseRequirement.destroy_all
Course.destroy_all
DegreeRequirement.destroy_all
Degree.destroy_all
Term.destroy_all
School.destroy_all
User.destroy_all

def load_csv(filename)
  CSV.read(Rails.root.join('db', 'seeds', filename), headers: true)
end

# Seed Schools
puts "Seeding schools..."
schools_data = load_csv('schools.csv')
schools_data.each do |row|
  School.create!(
    id: row['id'],
    name: row['name'].strip,
    school_type: row['school_type'],
    credit_hour_price: row['credit_hour_price'],
    minimum_credits_from_school: row['minimum_credits_from_school'],
    max_credits_from_community_college: row['max_credits_from_community_college'],
    max_credits_from_university: row['max_credits_from_university']
  )
end

# Seed Degrees (hardcoded since not in CSV)
puts "Seeding degrees..."
Degree.create!(
  id: 1,
  name: "Computer Science - Artificial Intelligence",
  school_id: 1
)

# Seed Degree Requirements
puts "Seeding degree requirements..."
degree_requirements_data = load_csv('degree_requirements.csv')
degree_requirements_data.each do |row|
  DegreeRequirement.create!(
    id: row['id'],
    name: row['name'],
    credit_hour_amount: row['credit_hour_amount'],
    degree_id: row['degree_id']
  )
end

# Seed Courses
puts "Seeding courses..."
courses_data = load_csv('courses.csv')
courses_data.each do |row|
  Course.create!(
    id: row['id'],
    name: row['name'].strip,
    code: row['code'],
    course_number: row['course_number'],
    department: row['department'].strip,
    category: row['category'],
    credit_hours: row['credit_hours'],
    school_id: row['school_id']
  )
end

# Seed Terms
puts "Seeding terms..."
terms_data = load_csv('terms.csv')
terms_data.each do |row|
  Term.create!(
    id: row['id'],
    name: row['name'],
    credit_hour_minimum: row['credit_hour_minimum'],
    credit_hour_maximum: row['credit_hour_maximum'],
    tuition_cost: row['tuition_cost'].gsub(',', '').to_f, # Remove commas from numbers
    school_id: row['school_id']
  )
end

puts "Seeding completed successfully!"

# Reset PostgreSQL sequences
ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end

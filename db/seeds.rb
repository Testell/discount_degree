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

# Add this to your seeds.rb file after the other seeds

puts "Creating sample plan..."

Plan.create!(
  degree_id: 1, # Computer Science - AI degree
  starting_school_id: 3, # City Colleges of Chicago
  intermediary_school_id: 2, # UIC
  ending_school_id: 1, # DePaul
  total_cost: 81533,
  path: [
    {
      school_id: 3,
      name: "City Colleges of Chicago"
    },
    {
      school_id: 2,
      name: "UIC"
    },
    {
      school_id: 1,
      name: "DePaul"
    }
  ],
  term_assignments: [
    {
      term_number: 1,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Composition" },
        { name: "Computer Science 101" },
        { name: "Race & Ethnic Relations" },
        { name: "Radio Production I" }
      ]
    },
    {
      term_number: 2,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Intro To Programming Logic" },
        { name: "Pop Cul-Mirror Of Amer Life" },
        { name: "Philosophy Of Religion" },
        { name: "Introduction To Religion " }
      ]
    },
    {
      term_number: 3,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Comparative Religion" },
        { name: "Nutrition-Consumer Education" },
        { name: "Cultural Anthropology" },
        { name: "Applied Anthropology  " }
      ]
    },
    {
      term_number: 4,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "History of American People To 1865 " },
        { name: "History Of Chicago Metropolitan Area" },
        { name: "Principles Of Economics I" },
        { name: "Social/Political Philosophy" }
      ]
    },
    {
      term_number: 5,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 13.0,
      cost: 1986.00,
      courses: [
        { name: "Composition II" },
        { name: "Introduction To Literature " },
        { name: "Discrete Mathematics" },
        { name: "Introduction to Technical Communication  " }
      ]
    },
    {
      term_number: 6,
      school_id: 3,
      name: "Part-Time at City Colleges of Chicago",
      credit_hours: 5.0,
      cost: 765.00,
      courses: [
        { name: "Calculus & Analytic Geometry I" }
      ]
    },
    {
      term_number: 7,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 10.0,
      cost: 3726.00,
      courses: [
        { name: "Data Structures" },
        { name: "Ethical Issues in Computing" },
        { name: "Programming Practicum" }
      ]
    },
    {
      term_number: 8,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 10.0,
      cost: 3726.00,
      courses: [
        { name: "Programming Language Design and Implementation" },
        { name: "Software Design" },
        { name: "Machine Organization" }
      ]
    },
    {
      term_number: 9,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 7.0,
      cost: 3726.00,
      courses: [
        { name: "Systems Programming" },
        { name: "Computer Algorithms I" }
      ]
    },
    {
      term_number: 10,
      school_id: 1,
      name: "Full-time at DePaul",
      credit_hours: 10.66,
      cost: 15065.00,
      courses: [
        { name: "Data Structures I" },
        { name: "Data Analysis" },
        { name: "Discrete Mathematics II" },
        { name: "Existential Themes" }
      ]
    },
    {
      term_number: 11,
      school_id: 1,
      name: "Full-time at DePaul",
      credit_hours: 10.66,
      cost: 15065.00,
      courses: [
        { name: "Applied Linear Algebra" },
        { name: "Computer Systems I" },
        { name: "Foundations of Artificial Intelligence" },
        { name: "Ethics in Artificial Intelligence" }
      ]
    },
    {
      term_number: 12,
      school_id: 1,
      name: "Full-time at DePaul",
      credit_hours: 10.66,
      cost: 15065.00,
      courses: [
        { name: "Machine Learning" },
        { name: "Symbolic Programming" },
        { name: "Applied AI Lab" },
        { name: "Introduction to Digital Image Processing" }
      ]
    },
    {
      term_number: 13,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 8.0,
      cost: 15065.00,
      courses: [
        { name: "Applied Image Analysis" },
        { name: "Deep Learning" },
        { name: "Software Projects" }
      ]
    }
  ],
  transferable_courses: []
)

Plan.create!(
  degree_id: 1, # Computer Science - AI degree
  starting_school_id: 3, # City Colleges of Chicago
  intermediary_school_id: 2, # UIC
  ending_school_id: 1, # DePaul
  total_cost: 69033,
  path: [
    {
      school_id: 3,
      name: "City Colleges of Chicago"
    },
    {
      school_id: 2,
      name: "UIC"
    },
    {
      school_id: 1,
      name: "DePaul"
    }
  ],
  term_assignments: [
    {
      term_number: 1,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Composition" },
        { name: "Computer Science 101" },
        { name: "Race & Ethnic Relations" },
        { name: "Radio Production I" }
      ]
    },
    {
      term_number: 2,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Intro To Programming Logic" },
        { name: "Pop Cul-Mirror Of Amer Life" },
        { name: "Philosophy Of Religion" },
        { name: "Introduction To Religion " }
      ]
    },
    {
      term_number: 3,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "Comparative Religion" },
        { name: "Nutrition-Consumer Education" },
        { name: "Cultural Anthropology" },
        { name: "Applied Anthropology  " }
      ]
    },
    {
      term_number: 4,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 12.0,
      cost: 1836.00,
      courses: [
        { name: "History of American People To 1865 " },
        { name: "History Of Chicago Metropolitan Area" },
        { name: "Principles Of Economics I" },
        { name: "Social/Political Philosophy" }
      ]
    },
    {
      term_number: 5,
      school_id: 3,
      name: "Full-Time at City Colleges of Chicago",
      credit_hours: 13.0,
      cost: 1986.00,
      courses: [
        { name: "Composition II" },
        { name: "Introduction To Literature " },
        { name: "Discrete Mathematics" },
        { name: "Introduction to Technical Communication  " }
      ]
    },
    {
      term_number: 6,
      school_id: 3,
      name: "Part-Time at City Colleges of Chicago",
      credit_hours: 5.0,
      cost: 765.00,
      courses: [
        { name: "Calculus & Analytic Geometry I" }
      ]
    },
    {
      term_number: 7,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 10.0,
      cost: 3726.00,
      courses: [
        { name: "Data Structures" },
        { name: "Ethical Issues in Computing" },
        { name: "Programming Practicum" }
      ]
    },
    {
      term_number: 8,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 10.0,
      cost: 3726.00,
      courses: [
        { name: "Programming Language Design and Implementation" },
        { name: "Software Design" },
        { name: "Machine Organization" }
      ]
    },
    {
      term_number: 9,
      school_id: 2,
      name: "Part-time at UIC",
      credit_hours: 7.0,
      cost: 3726.00,
      courses: [
        { name: "Systems Programming" },
        { name: "Computer Algorithms I" }
      ]
    },
    {
      term_number: 10,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33, # 8 quarter hours
      cost: 6368.00, # 8 quarter hours × $796
      courses: [
        { name: "Data Structures I" },
        { name: "Data Analysis" }
      ]
    },
    {
      term_number: 11,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Discrete Mathematics II" },
        { name: "Existential Themes" }
      ]
    },
    {
      term_number: 12,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Applied Linear Algebra" },
        { name: "Computer Systems I" }
      ]
    },
    {
      term_number: 13,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Foundations of Artificial Intelligence" },
        { name: "Ethics in Artificial Intelligence" }
      ]
    },
    {
      term_number: 14,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Machine Learning" },
        { name: "Symbolic Programming" }
      ]
    },
    {
      term_number: 15,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Applied AI Lab" },
        { name: "Introduction to Digital Image Processing" }
      ]
    },
    {
      term_number: 16,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 5.33,
      cost: 6368.00,
      courses: [
        { name: "Applied Image Analysis" },
        { name: "Deep Learning" }
      ]
    },
    {
      term_number: 17,
      school_id: 1,
      name: "Part-time at DePaul",
      credit_hours: 2.67, # 4 quarter hours
      cost: 3184.00, # 4 quarter hours × $796
      courses: [
        { name: "Software Projects" }
      ]
    }
  ],
  transferable_courses: []
)

puts "Sample plan created successfully!"

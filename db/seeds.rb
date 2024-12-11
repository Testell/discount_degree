require "csv"

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
  CSV.read(Rails.root.join("db", "seeds", filename), headers: true)
end

# Seed Schools
puts "Seeding schools..."
schools_data = load_csv("schools.csv")
schools_data.each do |row|
  School.create!(
    id: row["id"],
    name: row["name"].strip,
    school_type: row["school_type"],
    credit_hour_price: row["credit_hour_price"],
    minimum_credits_from_school: row["minimum_credits_from_school"],
    max_credits_from_community_college: row["max_credits_from_community_college"],
    max_credits_from_university: row["max_credits_from_university"]
  )
end

# Seed Degrees
puts "Seeding degrees..."
Degree.create!(id: 1, name: "Computer Science - Artificial Intelligence", school_id: 1)

# Seed Degree Requirements
puts "Seeding degree requirements..."
degree_requirements_data = load_csv("degree_requirements.csv")
degree_requirements_data.each do |row|
  DegreeRequirement.create!(
    id: row["id"],
    name: row["name"],
    credit_hour_amount: row["credit_hour_amount"],
    degree_id: row["degree_id"]
  )
end

# Seed Courses
puts "Seeding courses..."
courses_data = load_csv("courses.csv")
courses_data.each do |row|
  Course.create!(
    id: row["id"],
    name: row["name"].strip,
    code: row["code"],
    course_number: row["course_number"],
    department: row["department"].strip,
    category: row["category"],
    credit_hours: row["credit_hours"],
    school_id: row["school_id"]
  )
end

# Seed Terms
puts "Seeding terms..."
terms_data = load_csv("terms.csv")
terms_data.each do |row|
  Term.create!(
    id: row["id"],
    name: row["name"],
    credit_hour_minimum: row["credit_hour_minimum"],
    credit_hour_maximum: row["credit_hour_maximum"],
    tuition_cost: row["tuition_cost"].gsub(",", "").to_f,
    school_id: row["school_id"]
  )
end

puts "Seeding completed successfully!"

# Reset PostgreSQL sequences
ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end

puts "Creating sample plans..."

# Helper method to create a term assignment with cleaner course format
def create_term_assignment(term_number, school_id, name, credit_hours, cost, courses)
  {
    term_number: term_number,
    school_id: school_id,
    name: name,
    credit_hours: credit_hours,
    cost: cost,
    courses: courses # Pass course names directly as strings
  }
end

# First plan - Part-time at DePaul
Plan.create!(
  degree_id: 1,
  starting_school_id: 3,
  intermediary_school_id: 2,
  ending_school_id: 1,
  total_cost: 69_033,
  path: ["City Colleges of Chicago", "UIC", "DePaul"], # Simplified path format
  term_assignments: [
    create_term_assignment(
      1,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      ["Composition", "Computer Science 101", "Race & Ethnic Relations", "Radio Production I"]
    ),
    create_term_assignment(
      2,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "Intro To Programming Logic",
        "Pop Cul-Mirror Of Amer Life",
        "Philosophy Of Religion",
        "Introduction To Religion"
      ]
    ),
    create_term_assignment(
      3,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "Comparative Religion",
        "Nutrition-Consumer Education",
        "Cultural Anthropology",
        "Applied Anthropology"
      ]
    ),
    create_term_assignment(
      4,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "History of American People To 1865",
        "History Of Chicago Metropolitan Area",
        "Principles Of Economics I",
        "Social/Political Philosophy"
      ]
    ),
    create_term_assignment(
      5,
      3,
      "Full-Time at City Colleges of Chicago",
      13.0,
      1986.00,
      [
        "Composition II",
        "Introduction To Literature",
        "Discrete Mathematics",
        "Introduction to Technical Communication"
      ]
    ),
    create_term_assignment(
      6,
      3,
      "Part-Time at City Colleges of Chicago",
      5.0,
      765.00,
      ["Calculus & Analytic Geometry I"]
    ),
    create_term_assignment(
      7,
      2,
      "Part-time at UIC",
      10.0,
      3726.00,
      ["Data Structures", "Ethical Issues in Computing", "Programming Practicum"]
    ),
    create_term_assignment(
      8,
      2,
      "Part-time at UIC",
      10.0,
      3726.00,
      ["Programming Language Design and Implementation", "Software Design", "Machine Organization"]
    ),
    create_term_assignment(
      9,
      2,
      "Part-time at UIC",
      7.0,
      3726.00,
      ["Systems Programming", "Computer Algorithms I"]
    ),
    create_term_assignment(
      10,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Data Structures I", "Data Analysis"]
    ),
    create_term_assignment(
      11,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Discrete Mathematics II", "Existential Themes"]
    ),
    create_term_assignment(
      12,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Applied Linear Algebra", "Computer Systems I"]
    ),
    create_term_assignment(
      13,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Foundations of Artificial Intelligence", "Ethics in Artificial Intelligence"]
    ),
    create_term_assignment(
      14,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Machine Learning", "Symbolic Programming"]
    ),
    create_term_assignment(
      15,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Applied AI Lab", "Introduction to Digital Image Processing"]
    ),
    create_term_assignment(
      16,
      1,
      "Part-time at DePaul",
      5.33,
      6368.00,
      ["Applied Image Analysis", "Deep Learning"]
    ),
    create_term_assignment(17, 1, "Part-time at DePaul", 2.67, 3184.00, ["Software Projects"])
  ],
  transferable_courses: []
)

# Second plan - Full-time at DePaul
Plan.create!(
  degree_id: 1,
  starting_school_id: 3,
  intermediary_school_id: 2,
  ending_school_id: 1,
  total_cost: 81_533,
  path: ["City Colleges of Chicago", "UIC", "DePaul"],
  term_assignments: [
    create_term_assignment(
      1,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      ["Composition", "Computer Science 101", "Race & Ethnic Relations", "Radio Production I"]
    ),
    create_term_assignment(
      2,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "Intro To Programming Logic",
        "Pop Cul-Mirror Of Amer Life",
        "Philosophy Of Religion",
        "Introduction To Religion"
      ]
    ),
    create_term_assignment(
      3,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "Comparative Religion",
        "Nutrition-Consumer Education",
        "Cultural Anthropology",
        "Applied Anthropology"
      ]
    ),
    create_term_assignment(
      4,
      3,
      "Full-Time at City Colleges of Chicago",
      12.0,
      1836.00,
      [
        "History of American People To 1865",
        "History Of Chicago Metropolitan Area",
        "Principles Of Economics I",
        "Social/Political Philosophy"
      ]
    ),
    create_term_assignment(
      5,
      3,
      "Full-Time at City Colleges of Chicago",
      13.0,
      1986.00,
      [
        "Composition II",
        "Introduction To Literature",
        "Discrete Mathematics",
        "Introduction to Technical Communication"
      ]
    ),
    create_term_assignment(
      6,
      3,
      "Part-Time at City Colleges of Chicago",
      5.0,
      765.00,
      ["Calculus & Analytic Geometry I"]
    ),
    create_term_assignment(
      7,
      2,
      "Part-time at UIC",
      10.0,
      3726.00,
      ["Data Structures", "Ethical Issues in Computing", "Programming Practicum"]
    ),
    create_term_assignment(
      8,
      2,
      "Part-time at UIC",
      10.0,
      3726.00,
      ["Programming Language Design and Implementation", "Software Design", "Machine Organization"]
    ),
    create_term_assignment(
      9,
      2,
      "Part-time at UIC",
      7.0,
      3726.00,
      ["Systems Programming", "Computer Algorithms I"]
    ),
    create_term_assignment(
      10,
      1,
      "Full-time at DePaul",
      10.66,
      15065.00,
      ["Data Structures I", "Data Analysis", "Discrete Mathematics II", "Existential Themes"]
    ),
    create_term_assignment(
      11,
      1,
      "Full-time at DePaul",
      10.66,
      15065.00,
      [
        "Applied Linear Algebra",
        "Computer Systems I",
        "Foundations of Artificial Intelligence",
        "Ethics in Artificial Intelligence"
      ]
    ),
    create_term_assignment(
      12,
      1,
      "Full-time at DePaul",
      10.66,
      15065.00,
      [
        "Machine Learning",
        "Symbolic Programming",
        "Applied AI Lab",
        "Introduction to Digital Image Processing"
      ]
    ),
    create_term_assignment(
      13,
      1,
      "Part-time at DePaul",
      8.0,
      15065.00,
      ["Applied Image Analysis", "Deep Learning", "Software Projects"]
    )
  ],
  transferable_courses: []
)

puts "Sample plans created successfully!"

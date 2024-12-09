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

# Seed Degrees
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
    tuition_cost: row['tuition_cost'].gsub(',', '').to_f,
    school_id: row['school_id']
  )
end

puts "Creating sample plans..."

# Helper method to create term assignments with school-specific numbering
def create_term_assignments(terms_by_school)
  all_terms = []
  terms_by_school.each do |school_id, terms|
    school_term_number = 1
    terms.each do |term|
      all_terms << {
        term_number: school_term_number,
        school_id: school_id,
        name: term[:name],
        credit_hours: term[:credit_hours],
        cost: term[:cost],
        courses: term[:courses]
      }
      school_term_number += 1
    end
  end
  all_terms
end

# First Plan
city_college_terms = [
  {
    name: "Full-Time at City Colleges of Chicago",
    credit_hours: 12.0,
    cost: 1836.00,
    courses: [
      "Composition",
      "Computer Science 101",
      "Race & Ethnic Relations",
      "Radio Production I"
    ]
  },
  {
    name: "Full-Time at City Colleges of Chicago",
    credit_hours: 12.0,
    cost: 1836.00,
    courses: [
      "Intro To Programming Logic",
      "Pop Cul-Mirror Of Amer Life",
      "Philosophy Of Religion",
      "Introduction To Religion"
    ]
  }
  {
    name: "Full-Time at City Colleges of Chicago",
    credit_hours: 12.0,
    cost: 1836.00,
    courses: [
      "Comparative Religion",
      "Nutrition-Consumer Education",
      "Cultural Anthropology",
      "Applied Anthropology"
    ]
  },
  {
    name: "Full-Time at City Colleges of Chicago",
    credit_hours: 12.0,
    cost: 1836.00,
    courses: [
      "History of American People To 1865",
      "History Of Chicago Metropolitan Area",
      "Principles Of Economics I",
      "Social/Political Philosophy"
    ]
  },
  {
    name: "Full-Time at City Colleges of Chicago",
    credit_hours: 13.0,
    cost: 1986.00,
    courses: [
      "Composition II",
      "Introduction To Literature",
      "Discrete Mathematics",
      "Introduction to Technical Communication"
    ]
  },
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 5.0,
    cost: 765.00,
    courses: [
      "Calculus & Analytic Geometry I"
    ]
  }
]

uic_terms = [
  {
    name: "Part-time at UIC",
    credit_hours: 10.0,
    cost: 3726.00,
    courses: [
      "Data Structures",
      "Ethical Issues in Computing",
      "Programming Practicum"
    ]
  },
  {
    name: "Part-time at UIC",
    credit_hours: 10.0,
    cost: 3726.00,
    courses: [
      "Programming Language Design and Implementation",
      "Software Design",
      "Machine Organization"
    ]
  },
  {
    name: "Part-time at UIC",
    credit_hours: 7.0,
    cost: 3726.00,
    courses: [
      "Systems Programming",
      "Computer Algorithms I"
    ]
  }
]

depaul_terms = [
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Data Structures I",
      "Data Analysis"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Discrete Mathematics II",
      "Existential Themes"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Applied Linear Algebra",
      "Computer Systems I"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Foundations of Artificial Intelligence",
      "Ethics in Artificial Intelligence"
    ]
  }
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Machine Learning",
      "Symbolic Programming"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Applied AI Lab",
      "Introduction to Digital Image Processing"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 5.33,
    cost: 6368.00,
    courses: [
      "Applied Image Analysis",
      "Deep Learning"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 2.67,
    cost: 3184.00,
    courses: [
      "Software Projects"
    ]
  }
]

# Create the first plan with school-specific term numbering
Plan.create!(
  degree_id: 1,
  starting_school_id: 3,
  intermediary_school_id: 2,
  ending_school_id: 1,
  total_cost: 81533,
  path: ["City Colleges of Chicago", "UIC", "DePaul"],
  term_assignments: create_term_assignments({
    3 => city_college_terms,
    2 => uic_terms,
    1 => depaul_terms
  }),
  transferable_courses: []
)

# Second Plan Structure
puts "Creating second plan..."

# Second plan terms
city_college_terms_2 = [
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 9.0,
    cost: 1377.00,
    courses: [
      "English Composition I",
      "Data Structures",
      "Programming II"
    ]
  },
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 9.0,
    cost: 1377.00,
    courses: [
      "Programming I",
      "Introduction to Computing",
      "College Algebra"
    ]
  }
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 9.0,
    cost: 1377.00,
    courses: [
      "Environmental Biology",
      "Music Fundamentals",
      "Art History"
    ]
  },
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 9.0,
    cost: 1377.00,
    courses: [
      "Fundamentals of Speech",
      "Introduction to Sociology",
      "General Psychology"
    ]
  },
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 9.0,
    cost: 1377.00,
    courses: [
      "U.S. History",
      "Introduction to Philosophy",
      "Ethics"
    ]
  },
  {
    name: "Part-Time at City Colleges of Chicago",
    credit_hours: 6.0,
    cost: 918.00,
    courses: [
      "English Composition II",
      "Computer Organization"
    ]
  }
]

depaul_terms_2 = [
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Creative Writing",
      "Web Development"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Mobile App Development",
      "Computer Graphics"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Data Mining",
      "Parallel Computing"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Capstone Project II",
      "Capstone Project I"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "AI Ethics",
      "Robotics"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Computer Vision",
      "Natural Language Processing"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Deep Learning",
      "Machine Learning"
    ]
  }
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Artificial Intelligence",
      "Software Engineering"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Operating Systems",
      "Database Systems"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Algorithms",
      "Film Studies"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Global Perspectives",
      "Logic and Reasoning"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 8.0,
    cost: 9552.00,
    courses: [
      "Cultural Studies",
      "Modern Literature"
    ]
  },
  {
    name: "Part-time at DePaul",
    credit_hours: 4.0,
    cost: 4776.00,
    courses: [
      "Cloud Computing"
    ]
  }
]

# Create the second plan
Plan.create!(
  degree_id: 1,
  starting_school_id: 3,
  intermediary_school_id: nil, # No intermediary school in this plan
  ending_school_id: 1,
  total_cost: 127203,
  path: ["City Colleges of Chicago", "DePaul"],
  term_assignments: create_term_assignments({
    3 => city_college_terms_2,
    1 => depaul_terms_2
  }),
  transferable_courses: []
)

puts "Sample plans created successfully!"

# Reset PostgreSQL sequences
ActiveRecord::Base.connection.tables.each do |table|
  ActiveRecord::Base.connection.reset_pk_sequence!(table)
end

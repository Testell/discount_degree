# db/seeds.rb

require 'bigdecimal'
require 'bigdecimal/util'

# Run this only in the development environment
if Rails.env.development?
  # Create Admin User
  admin_email = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
  admin_password = ENV.fetch('ADMIN_PASSWORD', 'password123')

  admin_user = User.find_or_create_by!(email: admin_email) do |user|
    user.username = 'admin'
    user.password = admin_password
    user.password_confirmation = admin_password
    user.role = 'admin'
  end

  puts "Admin user created in development: #{admin_user.email}, role: #{admin_user.role}"

  # Seed Data for Demo Plan Generation
  # Clear existing data to avoid duplicates
  puts "Clearing existing data..."
  Plan.destroy_all
  TransferableCourse.destroy_all
  CourseRequirement.destroy_all
  DegreeRequirement.destroy_all
  Course.destroy_all
  Degree.destroy_all
  School.destroy_all
  Term.destroy_all

  puts "Seeding data for schools, degrees, courses, and plans..."

  # 1. Create Schools

  # City Colleges of Chicago (CCC)
  ccc = School.create!(
    name: "City Colleges of Chicago",
    school_type: "community_college",
    credit_hour_price: 153.00,
    max_credits_from_community_college: 66,
    minimum_credits_from_school: 0
  )

  # University of Illinois Chicago (UIC)
  uic = School.create!(
    name: "University of Illinois Chicago",
    school_type: "university",
    credit_hour_price: nil,
    max_credits_from_community_college: 60,
    max_credits_from_university: 60,
    minimum_credits_from_school: 0
  )

  # DePaul University
  depaul = School.create!(
    name: "DePaul",
    school_type: "university",
    credit_hour_price: 1194.00,
    max_credits_from_community_college: 66,
    max_credits_from_university: 88,
    minimum_credits_from_school: 40
  )

  # 2. Add Terms to Schools

  ## CCC Terms
  ccc.terms.create!([
    { name: "Regular Term", credit_hour_minimum: 1, credit_hour_maximum: 18, tuition_cost: 0.00 }
  ])

  ## UIC Terms
  uic.terms.create!([
    { name: "1-5 Credits", credit_hour_minimum: 1, credit_hour_maximum: 5, tuition_cost: 1863.00 },
    { name: "6-11 Credits", credit_hour_minimum: 6, credit_hour_maximum: 11, tuition_cost: 3726.00 },
    { name: "12-18 Credits", credit_hour_minimum: 12, credit_hour_maximum: 18, tuition_cost: 5589.00 }
  ])

  ## DePaul Terms
  depaul.terms.create!([
    { name: "Full-time", credit_hour_minimum: 12.0, credit_hour_maximum: 18.0, tuition_cost: 15535.00 },
    { name: "Part-time", credit_hour_minimum: 1.0, credit_hour_maximum: 11.0, tuition_cost: 0.00 }
  ])

  # 3. Create Degree at DePaul
  degree = Degree.create!(
    name: "Computer Science - Artificial Intelligence",
    school: depaul
  )

  # 4. Create Degree Requirements
  liberal_studies = DegreeRequirement.create!(
    name: "Liberal Studies",
    credit_hour_amount: 51.0,
    degree: degree
  )

  major_requirements = DegreeRequirement.create!(
    name: "Major and Concentration Requirements",
    credit_hour_amount: 64.0,
    degree: degree
  )

  open_electives = DegreeRequirement.create!(
    name: "Open Electives",
    credit_hour_amount: 14.0,
    degree: degree
  )

  # Helper method to generate department code
  def get_department_code(course_name)
    case course_name.downcase
    when /compos|writing|english|literature/
      "ENG"
    when /ethic|philosoph/
      "PHL"
    when /history/
      "HST"
    when /psycholog/
      "PSY"
    when /sociolog/
      "SOC"
    when /speech|speaking|communication/
      "CMN"
    when /art/
      "ART"
    when /music/
      "MUS"
    when /environment|biology|science/
      "SCI"
    when /statistic|algebra|calculus|mathematics|linear/
      "MAT"
    when /computer|programming|software|data|algorithm/
      "CSC"
    when /business/
      "BUS"
    when /economic/
      "ECO"
    when /marketing/
      "MKT"
    else
      "GEN"
    end
  end

  # 5. Create Courses and Link to Degree Requirements

  # DePaul Courses
  depaul_courses = []
  course_number_counter = 100

  # Liberal Studies Courses at DePaul
  liberal_studies_courses = [
    "Composition and Rhetoric I",
    "Composition and Rhetoric II",
    "Creative Writing",
    "Ethics in Technology",
    "Introduction to Philosophy",
    "World History",
    "Introduction to Psychology",
    "Introduction to Sociology",
    "Public Speaking",
    "Art Appreciation",
    "Music Appreciation",
    "Environmental Science",
    "Introduction to Statistics"
  ]

  liberal_studies_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 4.0,
      school: depaul,
      category: "Liberal Studies"
    )
    course_number_counter += 1
    depaul_courses << course

    CourseRequirement.create!(
      course: course,
      degree_requirement: liberal_studies,
      is_mandatory: false
    )
  end

  # Reset counter for major courses
  course_number_counter = 200

  # Major and Concentration Courses at DePaul
  major_courses = [
    "Introduction to Computer Science",
    "Data Structures",
    "Algorithms",
    "Computer Systems",
    "Database Systems",
    "Operating Systems",
    "Software Engineering",
    "Artificial Intelligence",
    "Machine Learning",
    "Deep Learning",
    "Natural Language Processing",
    "Computer Vision",
    "Robotics",
    "AI Ethics",
    "Capstone Project I",
    "Capstone Project II"
  ]

  major_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 4.0,
      school: depaul,
      category: "Major Requirements"
    )
    course_number_counter += 1
    depaul_courses << course

    CourseRequirement.create!(
      course: course,
      degree_requirement: major_requirements,
      is_mandatory: true
    )
  end

  # Reset counter for electives
  course_number_counter = 300

  # Open Elective Courses at DePaul
  open_elective_courses = [
    "Advanced Topics in CS",
    "Mobile App Development",
    "Web Development",
    "Cloud Computing"
  ]

  open_elective_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 4.0,
      school: depaul,
      category: "Open Electives"
    )
    course_number_counter += 1
    depaul_courses << course

    CourseRequirement.create!(
      course: course,
      degree_requirement: open_electives,
      is_mandatory: false
    )
  end

  # Reset counter for CCC courses
  course_number_counter = 100

  # CCC Courses
  ccc_courses = []

  # CCC Liberal Studies Courses
  ccc_liberal_studies_courses = [
    "English Composition I",
    "English Composition II",
    "Introduction to Literature",
    "Ethics",
    "Introduction to Philosophy",
    "U.S. History",
    "General Psychology",
    "Introduction to Sociology",
    "Fundamentals of Speech",
    "Art History",
    "Music Fundamentals",
    "Environmental Biology",
    "College Algebra",
    "Cultural Anthropology"
  ]

  ccc_liberal_studies_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 3.0,
      school: ccc,
      category: "Liberal Studies"
    )
    course_number_counter += 1
    ccc_courses << course
  end

  # Reset counter for major courses
  course_number_counter = 200

  # CCC Major Courses
  ccc_major_courses = [
    "Introduction to Computing",
    "Programming I",
    "Programming II",
    "Discrete Mathematics",
    "Calculus I",
    "Calculus II",
    "Linear Algebra",
    "Computer Organization",
    "Data Structures"
  ]

  ccc_major_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 3.0,
      school: ccc,
      category: "Major Requirements"
    )
    course_number_counter += 1
    ccc_courses << course
  end

  # Reset counter for electives
  course_number_counter = 300

  # CCC Open Electives
  ccc_open_electives = [
    "Introduction to Business",
    "Fundamentals of Marketing",
    "Introduction to Economics",
    "Computer Graphics",
    "Public Relations"
  ]

  ccc_open_electives.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 3.0,
      school: ccc,
      category: "Open Electives"
    )
    course_number_counter += 1
    ccc_courses << course
  end

  # Reset counter for UIC courses
  course_number_counter = 200

  # UIC Courses
  uic_courses = []

  uic_major_courses = [
    "Software Design",
    "Theory of Computation",
    "Artificial Intelligence",
    "Computer Networks",
    "Human-Computer Interaction",
    "Operating Systems",
    "Database Systems"
  ]

  uic_major_courses.each do |course_name|
    department = get_department_code(course_name)
    course = Course.create!(
      name: course_name,
      code: department,
      department: department,
      course_number: course_number_counter,
      credit_hours: 3.0,
      school: uic,
      category: "Major Requirements"
    )
    course_number_counter += 1
    uic_courses << course
  end

  # Create Transfer Agreements
  # CCC to DePaul Transfers
  ccc_courses.each do |ccc_course|
    depaul_course = depaul_courses.find do |course|
      course.category == ccc_course.category &&
      course.name.downcase.include?(ccc_course.name.split.last.downcase)
    end
    next unless depaul_course

    TransferableCourse.create!(
      from_course: ccc_course,
      to_course: depaul_course
    )
  end

  # UIC to DePaul Transfers
  uic_courses.each do |uic_course|
    depaul_course = depaul_courses.find do |course|
      course.category == uic_course.category &&
      course.name.downcase.include?(uic_course.name.split.last.downcase)
    end
    next unless depaul_course

    TransferableCourse.create!(
      from_course: uic_course,
      to_course: depaul_course
    )
  end

  # CCC to UIC Transfers
  ccc_courses.each do |ccc_course|
    uic_course = uic_courses.find do |course|
      course.category == ccc_course.category &&
      course.name.downcase.include?(ccc_course.name.split.last.downcase)
    end
    next unless uic_course

    TransferableCourse.create!(
      from_course: ccc_course,
      to_course: uic_course
    )
  end

  # Generate the Plan
  generator = PlanServices::CheapestPlanGenerator.new(degree, ccc, depaul)
  plan = generator.generate_cheapest_plan

  if plan
    puts "Plan generated successfully!"
    puts "Plan ID: #{plan.id}"
    puts "Total Cost: $#{plan.total_cost}"
    puts "Path: #{plan.path.join(' → ')}"
  else
    puts "Failed to generate the plan."
  end
else
  puts "Did not create seeded Admin User or demo data because the environment is not development."
end

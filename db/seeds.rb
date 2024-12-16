if Rails.env.development?
  admin_email = ENV.fetch("ADMIN_EMAIL", "admin@example.com")
  admin_password = ENV.fetch("ADMIN_PASSWORD", "password123")

  admin_user = User.find_or_initialize_by(email: admin_email)
  if admin_user.new_record?
    admin_user.username = "admin"
    admin_user.password = admin_password
    admin_user.role = "admin"
    admin_user.save!
  end

  puts "Admin user created in development: #{admin_user.email}, role: #{admin_user.role}"

  puts "Clearing existing data..."
  Plan.destroy_all
  TransferableCourse.destroy_all
  CourseRequirement.destroy_all
  CoursePrerequisite.destroy_all
  DegreeRequirement.destroy_all
  Course.destroy_all
  Degree.destroy_all
  School.destroy_all
  Term.destroy_all

  puts "Seeding data from the test scenario..."

  ccc =
    School.create!(
      name: "Community College A",
      school_type: "community_college",
      credit_hour_price: 100,
      max_credits_from_community_college: 10,
      minimum_credits_from_school: 0,
      max_credits_from_university: 0
    )
  ccc.terms.create!(
    name: "Regular Term",
    credit_hour_minimum: 1,
    credit_hour_maximum: 18,
    tuition_cost: 0.0
  )

  cheap_u =
    School.create!(
      name: "Cheapest University",
      school_type: "university",
      credit_hour_price: 500,
      max_credits_from_community_college: 60,
      max_credits_from_university: 10,
      minimum_credits_from_school: 0
    )
  cheap_u.terms.create!(
    name: "Part-time",
    credit_hour_minimum: 1,
    credit_hour_maximum: 11,
    tuition_cost: 0.0
  )

  exp_u =
    School.create!(
      name: "Expensive University",
      school_type: "university",
      credit_hour_price: 1200,
      max_credits_from_community_college: 60,
      max_credits_from_university: 10,
      minimum_credits_from_school: 0
    )
  exp_u.terms.create!(
    name: "Part-time",
    credit_hour_minimum: 1,
    credit_hour_maximum: 11,
    tuition_cost: 0.0
  )

  ending_u =
    School.create!(
      name: "Ending University",
      school_type: "university",
      credit_hour_price: 1500,
      max_credits_from_community_college: 10,
      max_credits_from_university: 10,
      minimum_credits_from_school: 10
    )
  ending_u.terms.create!(
    name: "Part-time",
    credit_hour_minimum: 1,
    credit_hour_maximum: 11,
    tuition_cost: 0.0
  )

  degree = Degree.create!(name: "Test Degree", school: ending_u)
  ls_req =
    DegreeRequirement.create!(name: "Liberal Studies", credit_hour_amount: 10, degree: degree)
  major_req =
    DegreeRequirement.create!(name: "Major Requirements", credit_hour_amount: 10, degree: degree)
  elective_req =
    DegreeRequirement.create!(name: "Open Electives", credit_hour_amount: 10, degree: degree)

  ending_ls_mand =
    Course.create!(
      name: "Ending Univ English Comp",
      code: "END-LS1",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 4,
      school: ending_u,
      course_number: 100
    )
  CourseRequirement.create!(course: ending_ls_mand, degree_requirement: ls_req, is_mandatory: true)

  ending_major_mand =
    Course.create!(
      name: "Ending Univ Intro to CS",
      code: "END-CS1",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 4,
      school: ending_u,
      course_number: 200
    )
  CourseRequirement.create!(
    course: ending_major_mand,
    degree_requirement: major_req,
    is_mandatory: true
  )

  ending_elec_mand =
    Course.create!(
      name: "Ending Univ Creative Thinking",
      code: "END-ELEC1",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 4,
      school: ending_u,
      course_number: 300
    )
  CourseRequirement.create!(
    course: ending_elec_mand,
    degree_requirement: elective_req,
    is_mandatory: true
  )

  ending_ls_opt =
    Course.create!(
      name: "Ending Univ World Lit",
      code: "END-LS2",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 3,
      school: ending_u,
      course_number: 101
    )
  CourseRequirement.create!(course: ending_ls_opt, degree_requirement: ls_req, is_mandatory: false)

  ending_ls_opt2 =
    Course.create!(
      name: "Ending Univ Ethics",
      code: "END-LS3",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 4,
      school: ending_u,
      course_number: 102
    )
  CourseRequirement.create!(course: ending_ls_opt2, degree_requirement: ls_req, is_mandatory: false)

  ending_major_opt =
    Course.create!(
      name: "Ending Univ Data Structures",
      code: "END-CS2",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 3,
      school: ending_u,
      course_number: 201
    )
  CourseRequirement.create!(
    course: ending_major_opt,
    degree_requirement: major_req,
    is_mandatory: false
  )

  ending_major_opt2 =
    Course.create!(
      name: "Ending Univ Algorithms",
      code: "END-CS3",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 4,
      school: ending_u,
      course_number: 202
    )
  CourseRequirement.create!(
    course: ending_major_opt2,
    degree_requirement: major_req,
    is_mandatory: false
  )

  ending_elec_opt =
    Course.create!(
      name: "Ending Univ Data Visualization",
      code: "END-ELEC2",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 3,
      school: ending_u,
      course_number: 301
    )
  CourseRequirement.create!(
    course: ending_elec_opt,
    degree_requirement: elective_req,
    is_mandatory: false
  )

  ending_elec_opt2 =
    Course.create!(
      name: "Ending Univ Innovation",
      code: "END-ELEC3",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 3,
      school: ending_u,
      course_number: 302
    )
  CourseRequirement.create!(
    course: ending_elec_opt2,
    degree_requirement: elective_req,
    is_mandatory: false
  )

  # CCC Courses (3 credits each)
  ccc_ls =
    Course.create!(
      name: "CCC English Comp",
      code: "CCC-LS",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 3,
      school: ccc,
      course_number: 400
    )
  ccc_major =
    Course.create!(
      name: "CCC Intro to CS",
      code: "CCC-CS",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 3,
      school: ccc,
      course_number: 401
    )
  ccc_elec =
    Course.create!(
      name: "CCC Public Speaking",
      code: "CCC-ELEC",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 3,
      school: ccc,
      course_number: 402
    )

  # Cheapest University equivalents
  cheap_u_ls =
    Course.create!(
      name: "Cheap U English Comp",
      code: "CHU-LS",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 3,
      school: cheap_u,
      course_number: 400
    )
  cheap_u_major =
    Course.create!(
      name: "Cheap U Intro to CS",
      code: "CHU-CS",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 3,
      school: cheap_u,
      course_number: 401
    )
  cheap_u_elec =
    Course.create!(
      name: "Cheap U Brainstorming",
      code: "CHU-ELEC",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 3,
      school: cheap_u,
      course_number: 402
    )

  exp_u_ls =
    Course.create!(
      name: "Exp U English Comp",
      code: "EXU-LS",
      department: "Liberal Studies",
      category: "Liberal Studies",
      credit_hours: 3,
      school: exp_u,
      course_number: 400
    )
  exp_u_major =
    Course.create!(
      name: "Exp U Intro to CS",
      code: "EXU-CS",
      department: "Computer Science",
      category: "Major Requirements",
      credit_hours: 3,
      school: exp_u,
      course_number: 401
    )
  exp_u_elec =
    Course.create!(
      name: "Exp U Debating",
      code: "EXU-ELEC",
      department: "Open Electives",
      category: "Open Electives",
      credit_hours: 3,
      school: exp_u,
      course_number: 402
    )

  TransferableCourse.create!(from_course: ccc_ls, to_course: ending_ls_mand)
  TransferableCourse.create!(from_course: ccc_major, to_course: ending_major_mand)
  TransferableCourse.create!(from_course: ccc_elec, to_course: ending_elec_mand)

  TransferableCourse.create!(from_course: ccc_ls, to_course: cheap_u_ls)
  TransferableCourse.create!(from_course: cheap_u_ls, to_course: ending_ls_mand)

  TransferableCourse.create!(from_course: ccc_major, to_course: cheap_u_major)
  TransferableCourse.create!(from_course: cheap_u_major, to_course: ending_major_mand)

  TransferableCourse.create!(from_course: ccc_elec, to_course: cheap_u_elec)
  TransferableCourse.create!(from_course: cheap_u_elec, to_course: ending_elec_mand)

  TransferableCourse.create!(from_course: ccc_ls, to_course: exp_u_ls)
  TransferableCourse.create!(from_course: exp_u_ls, to_course: ending_ls_mand)

  TransferableCourse.create!(from_course: ccc_major, to_course: exp_u_major)
  TransferableCourse.create!(from_course: exp_u_major, to_course: ending_major_mand)

  TransferableCourse.create!(from_course: ccc_elec, to_course: exp_u_elec)
  TransferableCourse.create!(from_course: exp_u_elec, to_course: ending_elec_mand)

  # Run the cheapest plan generator:
  generator = PlanServices::CheapestPlanGenerator.new(degree, ccc, ending_u)
  plan = generator.generate_cheapest_plan

  if plan
    puts "Plan generated successfully!"
    puts "Plan ID: #{plan.id}"
    puts "Total Cost: $#{plan.total_cost}"
    puts "Path: #{plan.path.join(" → ")}"
  else
    puts "Failed to generate the plan."
  end
else
  puts "Non-development environment detected. Clearing existing plans and creating sample plans..."
  Plan.destroy_all

  def create_term_assignment(term_number, school_id, name, credit_hours, cost, courses)
    {
      term_number: term_number,
      school_id: school_id,
      name: name,
      credit_hours: credit_hours,
      cost: cost,
      courses: courses
    }
  end

  puts "Creating sample plans..."

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
        [
          "Programming Language Design and Implementation",
          "Software Design",
          "Machine Organization"
        ]
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
    total_cost: 76_020,
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
        [
          "Programming Language Design and Implementation",
          "Software Design",
          "Machine Organization"
        ]
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
        9552.00,
        ["Applied Image Analysis", "Deep Learning", "Software Projects"]
      )
    ],
    transferable_courses: []
  )
  puts "Sample plans created successfully!"
end

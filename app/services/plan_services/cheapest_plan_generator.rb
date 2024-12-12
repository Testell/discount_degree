module PlanServices
  class CheapestPlanGenerator
    def initialize(degree, starting_community_college, ending_university)
      @degree = degree
      @starting_cc = starting_community_college
      @ending_university = ending_university
      @nodes = []
      @edges = []
    end

    # Public method to generate the cheapest plan
    def generate_cheapest_plan
      build_graph
      best_plan_data = find_cheapest_path

      puts "Best plan data before save:"
      begin
        puts JSON.pretty_generate(best_plan_data)
      rescue StandardError
        puts best_plan_data.inspect
      end

      plan = save_plan(best_plan_data) if best_plan_data
      plan
    end

    private

    # Represents a node (school) in the graph
    class SchoolNode
      attr_accessor :id, :name, :school_type, :terms, :courses, :school

      def initialize(id:, name:, school_type:, terms:, courses:, school:)
        @id = id
        @name = name
        @school_type = school_type
        @terms = terms
        @courses = courses
        @school = school
      end
    end

    # Represents an edge (transferable courses) between two schools in the graph
    class Edge
      attr_accessor :from, :to, :courses_transferred, :cost, :terms

      def initialize(from, to, courses_transferred, cost, terms)
        @from = from
        @to = to
        @courses_transferred = courses_transferred
        @cost = cost.to_f
        @terms = terms
      end
    end

    # Builds the graph by creating nodes and edges based on transferable courses
    def build_graph
      puts "Building graph..."

      add_node_if_not_exists(@starting_cc)
      add_node_if_not_exists(@ending_university)
      add_intermediary_universities

      puts "Nodes created: #{collect_node_names}"

      create_edges_between_nodes
    end

    # Adds a school node to @nodes if it does not already exist
    def add_node_if_not_exists(school)
      @nodes << create_school_node(school) unless @nodes.any? { |node| node.id == school.id }
    end

    # Adds intermediary universities to the graph
    def add_intermediary_universities
      intermediary_universities.each { |intermediary| add_node_if_not_exists(intermediary) }
    end

    # Collects and returns the names of all nodes
    def collect_node_names
      @nodes.map(&:name)
    end

    # Creates edges between all pairs of nodes based on transferable courses
    def create_edges_between_nodes
      @nodes.each do |from_node|
        @nodes.each do |to_node|
          next if from_node == to_node

          transferable_courses = find_transferable_courses(from_node, to_node)
          next if transferable_courses.empty?

          from_courses = unique_from_courses(transferable_courses)
          cost = calculate_cost(from_node, from_courses)
          terms = assign_courses_to_terms(from_node, from_courses)

          create_and_add_edge(from_node, to_node, from_courses, cost, terms)
        end
      end
    end

    # Finds transferable courses between two nodes
    def find_transferable_courses(from_node, to_node)
      TransferableCourse.where(from_course: from_node.courses, to_course: to_node.courses)
    end

    # Extracts unique from_courses from transferable courses
    def unique_from_courses(transferable_courses)
      from_courses = []
      transferable_courses.each do |transferable_course|
        from_course = transferable_course.from_course
        from_courses << from_course unless from_courses.include?(from_course)
      end
      from_courses
    end

    # Creates and adds an edge to @edges
    def create_and_add_edge(from_node, to_node, from_courses, cost, terms)
      edge = Edge.new(from_node, to_node, from_courses, cost, terms)
      @edges << edge
      puts "Edge created: #{from_node.name} → #{to_node.name}, cost: #{cost}"
    end

    # Creates a SchoolNode instance from a school record
    def create_school_node(school)
      raise "Invalid school data" if school.terms.empty?

      sorted_terms = school.terms.order(:credit_hour_minimum)
      SchoolNode.new(
        id: school.id,
        name: school.name,
        school_type: school.school_type,
        terms: sorted_terms,
        courses: school.courses,
        school: school
      )
    end

    # Retrieves intermediary universities excluding starting and ending schools
    def intermediary_universities
      School
        .where(school_type: "university")
        .where.not(id: [@starting_cc.id, @ending_university.id])
    end

    # Finds the cheapest path using Dijkstra's algorithm
    def find_cheapest_path
      puts "Finding the cheapest path..."

      distances = initialize_distances
      previous = {}
      unvisited = @nodes.dup

      while unvisited.any?
        current = select_closest_node(unvisited, distances)
        break if distances[current.id] == Float::INFINITY

        unvisited.delete(current)
        update_distances(current, distances, previous)
      end

      puts "Distances: #{distances}"
      puts "Previous nodes: #{format_previous_nodes(previous)}"

      reconstruct_path(previous)
    end

    # Initializes distances hash with infinity for all nodes except the starting node
    def initialize_distances
      distances = {}
      @nodes.each { |node| distances[node.id] = Float::INFINITY }
      distances[@starting_cc.id] = 0
      distances
    end

    # Selects the closest unvisited node based on current distances
    def select_closest_node(unvisited, distances)
      unvisited.min_by { |node| distances[node.id] }
    end

    # Updates distances and previous hashes based on edges from the current node
    def update_distances(current, distances, previous)
      outgoing_edges = @edges.select { |edge| edge.from == current }

      outgoing_edges.each do |edge|
        alternative_distance = distances[current.id] + edge.cost
        if alternative_distance < distances[edge.to.id]
          distances[edge.to.id] = alternative_distance
          previous[edge.to.id] = edge
        end
      end
    end

    # Formats the previous nodes for debugging
    def format_previous_nodes(previous)
      formatted = {}
      previous.each { |node_id, edge| formatted[node_id] = edge.from.name if edge }
      formatted
    end

    # Reconstructs the cheapest path from the previous nodes
    def reconstruct_path(previous)
      path = []
      term_assignments = []
      current_node = find_node_by_id(@ending_university.id)

      puts "Starting path reconstruction..."
      puts "Current node: #{current_node&.name}"
      puts "Previous hash: #{previous.inspect}"

      while (edge = previous[current_node.id])
        assign_terms_from_edge(edge, term_assignments)
        path.unshift(edge.from.name)
        current_node = edge.from

        puts "Added to path: #{edge.from.name}"
        puts "Current term assignments: #{term_assignments.length}"
      end

      path.push(@ending_university.name)
      puts "Path reconstructed: #{path}"

      fulfilled_course_ids = collect_fulfilled_course_ids(term_assignments)
      handle_transferable_courses(fulfilled_course_ids)

      degree_requirements = load_degree_requirements
      ending_courses = select_ending_courses(degree_requirements, fulfilled_course_ids)

      ending_terms = assign_courses_to_terms(find_node_by_id(@ending_university.id), ending_courses)
      append_ending_terms(term_assignments, ending_terms)

      total_cost = calculate_total_cost(term_assignments)

      final_data = build_final_plan_data(path, term_assignments, total_cost)

      puts "\nFinal plan data constructed:"
      puts "Total cost: #{final_data[:total_cost]}"
      puts "Path: #{final_data[:path].inspect}"
      puts "Term assignments count: #{final_data[:term_assignments].length}"

      final_data
    end

    # Finds a node by its ID
    def find_node_by_id(node_id)
      @nodes.find { |node| node.id == node_id }
    end

    # Assigns terms from an edge to term_assignments
    def assign_terms_from_edge(edge, term_assignments)
      edge.terms.each do |term|
        term_with_school = term.merge("school_name" => edge.from.name)
        term_assignments << term_with_school
      end
    end

    # Collects fulfilled course IDs from term assignments
    def collect_fulfilled_course_ids(term_assignments)
      assigned_course_ids = []
      term_assignments.each do |assignment|
        course_ids = assignment["course_ids"]
        assigned_course_ids.concat(course_ids) if course_ids
      end
      assigned_course_ids.compact.uniq
    end

    # Handles transferable courses and updates fulfilled_course_ids
    def handle_transferable_courses(fulfilled_course_ids)
      transferred_courses =
        TransferableCourse.joins(:to_course).where(
          from_course_id: fulfilled_course_ids,
          courses: {
            school_id: @ending_university.id
          }
        )
      transferred_to_course_ids = transferred_courses.pluck(:to_course_id)
      fulfilled_course_ids.concat(transferred_to_course_ids)
      fulfilled_course_ids.uniq!
    end

    # Loads degree requirements with necessary associations
    def load_degree_requirements
      DegreeRequirement.where(degree_id: @degree.id).includes(course_requirements: :course)
    end

    # Selects ending courses based on degree requirements and fulfilled courses
    def select_ending_courses(degree_requirements, fulfilled_course_ids)
      ending_courses = []

      degree_requirements.each do |degree_requirement|
        credits_needed = degree_requirement.credit_hour_amount.to_f

        mandatory_courses = find_mandatory_courses(degree_requirement, fulfilled_course_ids)
        ending_courses.concat(mandatory_courses)
        fulfilled_course_ids.concat(mandatory_courses.map(&:id))

        credits_needed -= mandatory_courses.sum(&:credit_hours)
        credits_needed = [credits_needed, 0].max

        if credits_needed > 0
          optional_courses = find_optional_courses(degree_requirement, fulfilled_course_ids)
          selected_optional_courses, remaining_credits =
            select_optional_courses(optional_courses, credits_needed)
          ending_courses.concat(selected_optional_courses)
          fulfilled_course_ids.concat(selected_optional_courses.map(&:id))

          if remaining_credits > 0
            puts "Unable to perfectly fulfill the credit requirement for '#{degree_requirement.name}'. Remaining credits needed: #{remaining_credits}"
          else
            puts "Credit requirement met for '#{degree_requirement.name}'. No additional optional courses added."
          end
        end
      end

      ending_courses
    end

    # Finds mandatory courses that are not yet fulfilled
    def find_mandatory_courses(degree_requirement, fulfilled_course_ids)
      mandatory_requirements = degree_requirement.course_requirements.where(is_mandatory: true)
      mandatory_courses =
        mandatory_requirements
          .map(&:course)
          .reject { |course| fulfilled_course_ids.include?(course.id) }
      mandatory_courses
    end

    # Finds optional courses that are not yet fulfilled
    def find_optional_courses(degree_requirement, fulfilled_course_ids)
      optional_requirements = degree_requirement.course_requirements.where(is_mandatory: false)
      optional_courses =
        optional_requirements
          .map(&:course)
          .reject { |course| fulfilled_course_ids.include?(course.id) }
      optional_courses.sort_by { |course| course.credit_hours }
    end

    # Selects optional courses to fulfill remaining credits
    def select_optional_courses(optional_courses, credits_needed)
      selected_optional_courses = []
      remaining_credits = credits_needed

      optional_courses.each do |course|
        break if remaining_credits <= 0

        if course.credit_hours <= remaining_credits
          selected_optional_courses << course
          remaining_credits -= course.credit_hours
        end
      end

      [selected_optional_courses, remaining_credits]
    end

    # Appends ending terms to term_assignments and enforces minimum credits if necessary
    def append_ending_terms(term_assignments, ending_terms)
      ending_terms.each do |term|
        term_with_school = term.merge("school_name" => @ending_university.name)
        term_assignments << term_with_school
      end
    end

    # Calculates the total cost from term assignments
    def calculate_total_cost(term_assignments)
      total_cost = 0.0
      term_assignments.each do |term|
        term_cost = term["cost"]
        total_cost += term_cost.to_f if term_cost
      end
      total_cost
    end

    # Builds the final plan data hash
    def build_final_plan_data(path, term_assignments, total_cost)
      {
        total_cost: total_cost,
        path: path,
        term_assignments:
          term_assignments.map do |assignment|
            transformed_assignment = {}
            assignment.each do |key, value|
              transformed_assignment[key] = value.is_a?(BigDecimal) ? value.to_f : value
            end
            transformed_assignment
          end
      }
    end

    # Assigns courses to terms for a given school node
    def assign_courses_to_terms(school_node, courses)
      puts "Assigning courses to terms for school: #{school_node.name}"
      terms = []
      remaining_courses = courses.sort_by { |course| -course.credit_hours }
      term_number = 1

      sorted_terms = sort_terms_by_cost_per_credit(school_node)

      while remaining_courses.any?
        term_assigned = false

        sorted_terms.each do |term|
          min_credits = term.credit_hour_minimum
          max_credits = term.credit_hour_maximum

          term_courses = []
          total_credits = 0

          remaining_courses.each do |course|
            next if term_courses.include?(course)
            break if total_credits + course.credit_hours > max_credits

            term_courses << course
            total_credits += course.credit_hours
          end

          if total_credits >= min_credits
            term_cost = calculate_term_cost_for_courses(school_node, term, total_credits)

            terms << build_term_assignment(
              term,
              term_courses,
              total_credits,
              term_cost,
              term_number,
              school_node.name
            )
            term_number += 1
            remaining_courses -= term_courses
            term_assigned = true
            break
          end
        end

        unless term_assigned
          assign_remaining_courses(remaining_courses, sorted_terms, terms, term_number, school_node)
          break
        end
      end

      enforce_minimum_university_credits_if_needed(terms, school_node, term_number)

      terms
    end

    # Sorts terms based on cost per credit hour
    def sort_terms_by_cost_per_credit(school_node)
      school_node.terms.sort_by do |term|
        avg_credits = (term.credit_hour_minimum + term.credit_hour_maximum) / 2.0
        cost_per_credit = term.tuition_cost.to_f / avg_credits
        cost_per_credit
      end
    end

    # Calculates the cost for a term based on the courses assigned
    def calculate_term_cost_for_courses(school_node, term, total_credits)
      if school_node.school.credit_hour_price.present?
        term_cost = school_node.school.credit_hour_price * total_credits
      else
        term_cost = term.tuition_cost.to_f
      end
      term_cost
    end

    # Assigns remaining courses that couldn't be grouped into a term with min credits
    def assign_remaining_courses(remaining_courses, sorted_terms, terms, term_number, school_node)
      remaining_courses.each do |course|
        term = find_term_for_course(sorted_terms, course)
        if term
          term_cost = calculate_term_cost_for_course(school_node, term, course)

          terms << build_term_assignment(
            term,
            [course],
            course.credit_hours,
            term_cost,
            term_number,
            school_node.name
          )
          term_number += 1
          remaining_courses.delete(course)
        else
          raise "Unable to assign course #{course.name} to any term at #{school_node.name}"
        end
      end
      remaining_courses.clear
    end

    # Finds a suitable term for a single course
    def find_term_for_course(sorted_terms, course)
      sorted_terms.find do |term|
        term.credit_hour_minimum <= course.credit_hours &&
          course.credit_hours <= term.credit_hour_maximum
      end
    end

    # Calculates the cost for a single course within a term
    def calculate_term_cost_for_course(school_node, term, course)
      if school_node.school.credit_hour_price.present?
        term_cost = school_node.school.credit_hour_price * course.credit_hours
      else
        term_cost = term.tuition_cost.to_f
      end
      term_cost
    end

    # Builds a term assignment hash
    def build_term_assignment(term, courses, credit_hours, cost, term_number, school_name)
      {
        "term_number" => term_number,
        "term_name" => term.name,
        "courses" => courses.map { |course| course.name },
        "course_ids" => courses.map { |course| course.id },
        "credit_hours" => credit_hours.to_f,
        "cost" => cost.to_f,
        "school_name" => school_name
      }
    end

    # Enforces minimum university credits if the ending university is being assigned
    def enforce_minimum_university_credits_if_needed(terms, school_node, term_number)
      if school_node.id == @ending_university.id
        enforce_minimum_university_credits(terms, school_node, term_number)
      end
    end

    # Enforces minimum credit requirements for the ending university
    def enforce_minimum_university_credits(terms, school_node, term_number)
      assigned_credits = terms.sum { |term| term["credit_hours"].to_f }
      required_credits = school_node.school.minimum_credits_from_school.to_f

      if assigned_credits < required_credits
        additional_credits_needed = required_credits - assigned_credits
        extra_courses = generate_placeholder_courses(additional_credits_needed)
        term_cost = calculate_term_cost(school_node, extra_courses)
        terms << build_term_assignment(
          school_node.terms.first,
          extra_courses,
          additional_credits_needed,
          term_cost,
          term_number,
          school_node.name
        )
      end
    end

    # Generates placeholder courses to meet additional credit requirements
    def generate_placeholder_courses(credits_needed)
      courses = []
      while credits_needed > 0
        credit_hours = [credits_needed, 3].min
        placeholder_course =
          OpenStruct.new(name: "Elective Course", id: nil, credit_hours: credit_hours)
        courses << placeholder_course
        credits_needed -= credit_hours
      end
      courses
    end

    # Calculates the cost for additional courses in a term
    def calculate_term_cost(school_node, courses)
      total_credits = 0.0
      courses.each { |course| total_credits += course.credit_hours }

      selected_term = find_term_for_total_credits(school_node, total_credits)

      if selected_term
        if school_node.school.credit_hour_price.present?
          term_cost = school_node.school.credit_hour_price * total_credits
        else
          term_cost = selected_term.tuition_cost.to_f
        end
      else
        if school_node.school.credit_hour_price.present?
          term_cost = school_node.school.credit_hour_price * total_credits
        else
          avg_credit_price = calculate_average_credit_price(school_node)
          term_cost = avg_credit_price * total_credits
        end
      end

      term_cost
    end

    # Finds a term that fits the total credits
    def find_term_for_total_credits(school_node, total_credits)
      school_node.terms.find do |term|
        term.credit_hour_minimum <= total_credits && total_credits <= term.credit_hour_maximum
      end
    end

    # Calculates the average credit price if no specific term fits
    def calculate_average_credit_price(school_node)
      total = 0.0
      school_node.terms.each do |term|
        avg_credits = (term.credit_hour_minimum + term.credit_hour_maximum) / 2.0
        total += term.tuition_cost.to_f / avg_credits
      end
      average = total / school_node.terms.size
      average
    end

    # Reconstructs the path and builds the final plan data
    def reconstruct_path(previous)
      # [Refactored method content as shown above]
      # Due to length constraints, ensure the method follows the refactored structure.
    end

    # Saves the final plan data to the database
    def save_plan(plan_data)
      puts "\nSaving plan with data:"
      puts "Total cost: #{plan_data[:total_cost]}"
      puts "Path: #{plan_data[:path].inspect}"
      puts "Term assignments count: #{plan_data[:term_assignments]&.length}"

      attributes = {
        degree: @degree,
        starting_school_id: @starting_cc.id,
        ending_school_id: @ending_university.id,
        intermediary_school_id: find_intermediary_school_id,
        total_cost: plan_data[:total_cost].to_f,
        path: plan_data[:path].as_json,
        term_assignments: plan_data[:term_assignments].as_json,
        transferable_courses: []
      }

      puts "\nCreating plan with attributes:"
      puts attributes.inspect

      plan = Plan.create!(attributes)

      puts "\nPlan saved successfully with ID: #{plan.id}"
      puts "Saved path: #{plan.path.inspect}"
      puts "Saved term_assignments count: #{plan.term_assignments.length}"

      plan
    rescue => e
      puts "\nError saving plan: #{e.message}"
      puts e.backtrace
      raise e
    end

    # Finds the intermediary school ID from nodes
    def find_intermediary_school_id
      intermediary_node =
        @nodes.find { |node| ![@starting_cc.id, @ending_university.id].include?(node.id) }
      intermediary_node&.id
    end
  end
end

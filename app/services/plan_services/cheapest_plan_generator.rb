module PlanServices
  class CheapestPlanGenerator
    # Initializes the generator with the degree, starting community college, and ending university.
    def initialize(degree, starting_community_college, ending_university)
      @degree = degree
      @starting_cc = starting_community_college
      @ending_university = ending_university
      @nodes = []
      @edges = []
    end

    # Generates the cheapest plan by building the graph, finding the cheapest path,
    # and saving the resulting plan.
    def generate_cheapest_plan
      build_graph
      best_plan_data = find_cheapest_path

      return nil if best_plan_data.nil?

      save_plan(best_plan_data)
    end

    private

    # Represents a node in the graph (a school) with related data.
    class SchoolNode
      attr_accessor :id, :name, :school_type, :terms, :courses, :school

      # Initializes a SchoolNode with all related information.
      def initialize(id:, name:, school_type:, terms:, courses:, school:)
        @id = id
        @name = name
        @school_type = school_type
        @terms = terms
        @courses = courses
        @school = school
      end
    end

    # Represents an edge in the graph connecting two schools with associated courses, cost, and terms.
    class Edge
      attr_accessor :from, :to, :courses_transferred, :cost, :terms

      # Initializes an Edge with the originating node, destination node, transferred courses, cost, and terms.
      def initialize(from, to, courses_transferred, cost, terms)
        @from = from
        @to = to
        @courses_transferred = courses_transferred
        @cost = cost.to_f
        @terms = terms
      end
    end

    # Builds the graph by creating nodes for all schools and edges for all transferable paths.
    def build_graph
      if !@nodes.any? { |node| node.id == @starting_cc.id }
        @nodes << create_school_node(@starting_cc)
      end

      if !@nodes.any? { |node| node.id == @ending_university.id }
        @nodes << create_school_node(@ending_university)
      end

      intermediary_universities.each do |intermediary|
        if !@nodes.any? { |node| node.id == intermediary.id }
          @nodes << create_school_node(intermediary)
        end
      end

      @nodes.each do |from_node|
        @nodes.each do |to_node|
          next if from_node == to_node

          transferable_courses =
            TransferableCourse.where(from_course: from_node.courses, to_course: to_node.courses)
          next if transferable_courses.empty?

          from_courses = transferable_courses.map(&:from_course).uniq
          cost = calculate_cost(from_node, from_courses)
          terms = assign_courses_to_terms(from_node, from_courses)
          @edges << Edge.new(from_node, to_node, from_courses, cost, terms)
        end
      end
    end

    # Creates a SchoolNode for a given school.
    def create_school_node(school)
      raise "Invalid school data" if school.terms.empty?

      SchoolNode.new(
        id: school.id,
        name: school.name,
        school_type: school.school_type,
        terms: school.terms.order(:credit_hour_minimum),
        courses: school.courses,
        school: school
      )
    end

    def intermediary_universities
      School
        .where(school_type: "university")
        .where.not(id: [@starting_cc.id, @ending_university.id])
    end

    # Finds the cheapest path using Dijkstra's algo logic to determine
    # the least-cost path from starting community college to ending university.
    def find_cheapest_path
      distances = {}
      previous = {}
      @nodes.each { |node| distances[node.id] = Float::INFINITY }
      distances[@starting_cc.id] = 0

      unvisited = @nodes.dup
      while unvisited.any?
        current = unvisited.min_by { |node| distances[node.id] }
        unvisited.delete(current)

        @edges
          .select { |edge| edge.from == current }
          .each do |edge|
            alt = distances[current.id] + edge.cost
            if alt < distances[edge.to.id]
              distances[edge.to.id] = alt
              previous[edge.to.id] = edge
            end
          end
      end

      reconstruct_path(previous)
    end

    # Reconstructs the path from the stored previous edges and determines which courses have been fulfilled.
    def reconstruct_path(previous)
      path = []
      school_terms = {}
      current_node = @nodes.find { |node| node.id == @ending_university.id }

      return nil if previous[current_node.id].nil?

      while (edge = previous[current_node.id])
        path.unshift(edge.from.name)
        school_terms[edge.from.name] = edge.terms.map do |term|
          term.merge("school_name" => edge.from.name)
        end
        current_node = edge.from
      end

      path.push(@ending_university.name)

      assigned_course_ids =
        school_terms.values.flatten.flat_map { |term| term["course_ids"] }.compact
      transferred_courses =
        TransferableCourse.joins(:to_course).where(
          from_course_id: assigned_course_ids,
          courses: {
            school_id: @ending_university.id
          }
        )
      transferred_to_course_ids = transferred_courses.pluck(:to_course_id)

      fulfilled_course_ids = assigned_course_ids.dup
      fulfilled_course_ids.concat(transferred_to_course_ids)
      fulfilled_course_ids.uniq!

      fulfill_degree_requirements(fulfilled_course_ids, path, school_terms)
    end

    # Determines what additional courses are needed at the ending university to fulfill all degree requirements.
    def fulfill_degree_requirements(fulfilled_course_ids, path, school_terms)
      degree_requirements =
        DegreeRequirement.where(degree_id: @degree.id).includes(course_requirements: :course)

      ending_courses = []
      total_credits = 0

      degree_requirements.each do |degree_requirement|
        credits_needed = degree_requirement.credit_hour_amount.to_f
        requirement_credits = 0

        mandatory_course_requirements =
          degree_requirement.course_requirements.where(is_mandatory: true)
        all_mandatory_courses = mandatory_course_requirements.map(&:course)

        all_mandatory_courses.each do |mc|
          if fulfilled_course_ids.include?(mc.id)
            credits_needed -= mc.credit_hours
            requirement_credits += mc.credit_hours
          end
        end

        missing_mandatory_courses =
          all_mandatory_courses.reject { |course| fulfilled_course_ids.include?(course.id) }
        if missing_mandatory_courses.any?
          ending_courses.concat(missing_mandatory_courses)
          fulfilled_course_ids.concat(missing_mandatory_courses.map(&:id))
          mandatory_credits = missing_mandatory_courses.sum(&:credit_hours)
          credits_needed -= mandatory_credits
          requirement_credits += mandatory_credits
        end

        credits_needed = [credits_needed, 0].max

        if credits_needed > 0
          optional_course_requirements =
            degree_requirement.course_requirements.where(is_mandatory: false)
          optional_courses =
            optional_course_requirements
              .map(&:course)
              .reject { |course| fulfilled_course_ids.include?(course.id) }
              .sort_by(&:credit_hours)
              .reverse

          selected_optional_courses = []
          optional_courses.each do |course|
            if credits_needed > 0
              selected_optional_courses << course
              credits_needed -= course.credit_hours
              requirement_credits += course.credit_hours
              fulfilled_course_ids << course.id
            end
          end

          return nil if requirement_credits < degree_requirement.credit_hour_amount

          ending_courses.concat(selected_optional_courses)
        end

        total_credits += requirement_credits
      end

      ending_terms = assign_courses_to_terms(ending_university_node, ending_courses)
      return nil if ending_terms.nil?

      organized_terms = []
      path.each_with_index do |school_name, i|
        if i < path.length - 1
          terms = school_terms[school_name] || []
          terms.each_with_index do |term, index|
            term = term.dup
            term["term_number"] = index + 1
            organized_terms << term
          end
        end
      end

      ending_terms.each_with_index do |term, index|
        term = term.dup
        term["term_number"] = index + 1
        organized_terms << term.merge("school_name" => @ending_university.name)
      end

      total_cost = organized_terms.sum { |term| term["cost"].to_f }

      {
        total_cost: total_cost,
        path: path,
        term_assignments:
          organized_terms.map do |assignment|
            assignment.transform_values { |v| v.is_a?(BigDecimal) ? v.to_f : v }
          end
      }
    end

    # Assigns the given courses to terms at a specific school, respecting term credit limits.
    def assign_courses_to_terms(school_node, courses)
      terms = []
      remaining_courses = courses.sort_by(&:credit_hours).reverse
      term_number = 1

      term_options =
        school_node.terms.sort_by do |term|
          avg_credits = (term.credit_hour_minimum + term.credit_hour_maximum) / 2.0
          term.tuition_cost.to_f / avg_credits
        end

      while remaining_courses.any?
        term_assigned = false
        term_options.each do |term|
          min_credits = term.credit_hour_minimum
          max_credits = term.credit_hour_maximum

          term_courses = []
          total_credits = 0

          remaining_courses.each do |course|
            if total_credits + course.credit_hours <= max_credits
              term_courses << course
              total_credits += course.credit_hours
            end
          end

          if total_credits >= min_credits
            term_cost =
              if term.tuition_cost.zero?
                (school_node.school.credit_hour_price * total_credits).to_f
              else
                term.tuition_cost.to_f
              end
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

        if !term_assigned
          remaining_courses.dup.each do |course|
            term =
              term_options.find do |t|
                t.credit_hour_minimum <= course.credit_hours &&
                  course.credit_hours <= t.credit_hour_maximum
              end
            return nil if term.nil?

            term_cost =
              if term.tuition_cost.zero?
                (school_node.school.credit_hour_price * course.credit_hours).to_f
              else
                term.tuition_cost.to_f
              end
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
          end
        end
      end

      terms
    end

    def build_term_assignment(term, courses, credit_hours, cost, term_number, school_name)
      {
        "term_number" => term_number,
        "name" => "#{term.name} at #{school_name}",
        "courses" => courses.map { |c| c.name },
        "course_ids" => courses.map { |c| c.id },
        "credit_hours" => credit_hours.to_f,
        "cost" => cost.to_f,
        "school_name" => school_name
      }
    end

    # Calculates the cost of taking specific courses at a given school, checking constraints like credit limits.
    def calculate_cost(school_node, courses)
      if school_node.school.school_type == "community_college"
        total_cc_credits = courses.sum(&:credit_hours)
        cc_limit = @ending_university.max_credits_from_community_college
        return Float::INFINITY if total_cc_credits > cc_limit
      end

      terms = assign_courses_to_terms(school_node, courses)
      return Float::INFINITY if terms.nil?

      total_cost = terms.sum { |term| term["cost"].to_f }

      if school_node.id == @ending_university.id
        total_ending_credits = terms.sum { |t| t["credit_hours"].to_f }
        min_credits = @ending_university.minimum_credits_from_school
        transferred_courses =
          TransferableCourse.where(to_course: Course.where(school: @ending_university)).includes(
            :to_course
          )
        ending_equiv_credits = transferred_courses.sum { |tc| tc.to_course.credit_hours }
        total_credits = total_ending_credits + ending_equiv_credits

        return Float::INFINITY if total_credits < min_credits
      end

      total_cost
    end

    def save_plan(plan_data)
      intermediary = @nodes.find { |n| ![@starting_cc.id, @ending_university.id].include?(n.id) }
      intermediary_id = nil
      intermediary_id = intermediary.id if !intermediary.nil?

      attributes = {
        degree: @degree,
        starting_school_id: @starting_cc.id,
        ending_school_id: @ending_university.id,
        intermediary_school_id: intermediary_id,
        total_cost: plan_data[:total_cost].to_f,
        path: plan_data[:path].as_json,
        term_assignments: plan_data[:term_assignments].as_json,
        transferable_courses: []
      }

      Plan.create!(attributes)
    end

    # Returns the SchoolNode corresponding to the ending university.
    def ending_university_node
      @nodes.find { |node| node.id == @ending_university.id }
    end
  end
end

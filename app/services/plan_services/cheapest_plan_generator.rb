module PlanServices
  class CheapestPlanGenerator
    def initialize(degree, starting_community_college, ending_university)
      @degree = degree
      @starting_cc = starting_community_college
      @ending_university = ending_university
      @nodes = []
      @edges = []
    end
 
    def generate_cheapest_plan
      build_graph
      best_plan_data = find_cheapest_path
      
      puts "Best plan data before save:"
      puts JSON.pretty_generate(best_plan_data) rescue puts best_plan_data.inspect
      
      plan = save_plan(best_plan_data) if best_plan_data
      plan 
    end
 
    private
 
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
 
    def build_graph
      puts "Building graph..."
      @nodes << create_school_node(@starting_cc) unless @nodes.any? { |node| node.id == @starting_cc.id }
      @nodes << create_school_node(@ending_university) unless @nodes.any? { |node| node.id == @ending_university.id }
 
      intermediary_universities.each do |intermediary|
        @nodes << create_school_node(intermediary) unless @nodes.any? { |node| node.id == intermediary.id }
      end
 
      puts "Nodes created: #{@nodes.map(&:name)}"
 
      @nodes.each do |from_node|
        @nodes.each do |to_node|
          next if from_node == to_node
 
          transferable_courses = TransferableCourse.where(from_course: from_node.courses, to_course: to_node.courses)
          next if transferable_courses.empty?
 
          from_courses = transferable_courses.map(&:from_course).uniq
          cost = calculate_cost(from_node, from_courses)
          terms = assign_courses_to_terms(from_node, from_courses)
 
          @edges << Edge.new(from_node, to_node, from_courses, cost, terms)
          puts "Edge created: #{from_node.name} → #{to_node.name}, cost: #{cost}"
        end
      end
    end
 
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
      School.where(school_type: 'university').where.not(id: [@starting_cc.id, @ending_university.id])
    end
 
    def find_cheapest_path
      puts "Finding the cheapest path..."
      distances = {}
      previous = {}
      @nodes.each { |node| distances[node.id] = Float::INFINITY }
      distances[@starting_cc.id] = 0
 
      unvisited = @nodes.dup
 
      until unvisited.empty?
        current = unvisited.min_by { |node| distances[node.id] }
        unvisited.delete(current)
 
        @edges.select { |edge| edge.from == current }.each do |edge|
          alt = distances[current.id] + edge.cost
          if alt < distances[edge.to.id]
            distances[edge.to.id] = alt
            previous[edge.to.id] = edge
          end
        end
      end
 
      puts "Distances: #{distances}"
      puts "Previous nodes: #{previous.transform_values { |edge| edge&.from&.name }}"
 
      reconstruct_path(previous)
    end
 
    def reconstruct_path(previous)
      path = []
      term_assignments = []
      current_node = @nodes.find { |node| node.id == @ending_university.id }
 
      puts "Starting path reconstruction..."
      puts "Current node: #{current_node&.name}"
      puts "Previous hash: #{previous.inspect}"
 
      while (edge = previous[current_node.id])
        term_assignments.concat(edge.terms.map { |term| term.merge('school_name' => edge.from.name) })
        path.unshift(edge.from.name)
        current_node = edge.from
 
        puts "Added to path: #{edge.from.name}"
        puts "Current term assignments: #{term_assignments.length}"
      end
 
      path.push(@ending_university.name)
      puts "Path reconstructed: #{path}"
 
      assigned_course_ids = term_assignments.flat_map { |term| term['course_ids'] }.compact
 
      fulfilled_course_ids = assigned_course_ids.dup
 
      transferred_courses = TransferableCourse.joins(:to_course).where(
        from_course_id: assigned_course_ids,
        courses: { school_id: @ending_university.id }
      )
 
      transferred_to_course_ids = transferred_courses.pluck(:to_course_id)
      fulfilled_course_ids.concat(transferred_to_course_ids)
 
      fulfilled_course_ids.uniq!
 
      degree_requirements = DegreeRequirement.where(degree_id: @degree.id).includes(course_requirements: :course)
 
      ending_courses = []
 
      degree_requirements.each do |degree_requirement|
        credits_needed = degree_requirement.credit_hour_amount.to_f
 
        mandatory_course_requirements = degree_requirement.course_requirements.where(is_mandatory: true)
        mandatory_courses = mandatory_course_requirements.map(&:course).reject { |course| fulfilled_course_ids.include?(course.id) }
 
        ending_courses.concat(mandatory_courses)
        fulfilled_course_ids.concat(mandatory_courses.map(&:id))
 
        credits_needed -= mandatory_courses.sum(&:credit_hours)
        credits_needed = [credits_needed, 0].max
 
        if credits_needed > 0
          optional_course_requirements = degree_requirement.course_requirements.where(is_mandatory: false)
          optional_courses = optional_course_requirements.map(&:course).reject { |course| fulfilled_course_ids.include?(course.id) }
 
          optional_courses = optional_courses.sort_by(&:credit_hours)
 
          selected_optional_courses = []
          optional_courses.each do |course|
            break if credits_needed <= 0
 
            if course.credit_hours <= credits_needed
              selected_optional_courses << course
              credits_needed -= course.credit_hours
              fulfilled_course_ids << course.id
            else
              next
            end
          end
 
          if credits_needed > 0
            puts "Unable to perfectly fulfill the credit requirement for '#{degree_requirement.name}'. Remaining credits needed: #{credits_needed}"
          end
 
          ending_courses.concat(selected_optional_courses)
        else
          puts "Credit requirement met for '#{degree_requirement.name}'. No additional optional courses added."
        end
      end
 
      ending_terms = assign_courses_to_terms(ending_university_node, ending_courses)
 
      term_assignments.concat(ending_terms.map { |term| term.merge('school_name' => @ending_university.name) })
 
      total_cost = term_assignments.sum { |term| term['cost'].to_f }
 
      final_data = {
        total_cost: total_cost,
        path: path,
        term_assignments: term_assignments.map { |assignment|
          assignment.transform_values { |v| v.is_a?(BigDecimal) ? v.to_f : v }
        }
      }
 
      puts "\nFinal plan data constructed:"
      puts "Total cost: #{final_data[:total_cost]}"
      puts "Path: #{final_data[:path].inspect}"
      puts "Term assignments count: #{final_data[:term_assignments].length}"
 
      final_data
    end
 
    def assign_courses_to_terms(school_node, courses)
      puts "Assigning courses to terms for school: #{school_node.name}"
      terms = []
      remaining_courses = courses.sort_by(&:credit_hours).reverse 
      term_number = 1
 
      term_options = school_node.terms.sort_by do |term|
        avg_credits = (term.credit_hour_minimum + term.credit_hour_maximum) / 2.0
        cost_per_credit = term.tuition_cost.to_f / avg_credits
        cost_per_credit
      end
 
      while remaining_courses.any?
        term_assigned = false
 
        term_options.each do |term|
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
            if school_node.school.credit_hour_price.present?
              term_cost = (school_node.school.credit_hour_price * total_credits).to_f
            else
              term_cost = term.tuition_cost.to_f
            end
 
            terms << build_term_assignment(term, term_courses, total_credits, term_cost, term_number, school_node.name)
            term_number += 1
            remaining_courses -= term_courses
            term_assigned = true
            break
          end
        end
 
        unless term_assigned
          remaining_courses.each do |course|
            term = term_options.find { |t| t.credit_hour_minimum <= course.credit_hours && course.credit_hours <= t.credit_hour_maximum }
            if term
              if school_node.school.credit_hour_price.present?
                term_cost = (school_node.school.credit_hour_price * course.credit_hours).to_f
              else
                term_cost = term.tuition_cost.to_f
              end
 
              terms << build_term_assignment(term, [course], course.credit_hours, term_cost, term_number, school_node.name)
              term_number += 1
              remaining_courses.delete(course)
            else
              raise "Unable to assign course #{course.name} to any term at #{school_node.name}"
            end
          end
          remaining_courses.clear
        end
      end
 
      if school_node.id == @ending_university.id
        enforce_minimum_university_credits(terms, school_node, term_number)
      end
 
      terms
    end
 
    def build_term_assignment(term, courses, credit_hours, cost, term_number, school_name)
      {
        'term_number' => term_number,
        'term_name' => term.name,
        'courses' => courses.map(&:name),
        'course_ids' => courses.map(&:id),
        'credit_hours' => credit_hours.to_f,
        'cost' => cost.to_f,
        'school_name' => school_name
      }
    end
 
    def calculate_cost(school_node, courses)
      terms = assign_courses_to_terms(school_node, courses)
      total_cost = terms.sum { |term| term['cost'].to_f }
      total_cost
    end
 
    def save_plan(plan_data)
      puts "\nSaving plan with data:"
      puts "Total cost: #{plan_data[:total_cost]}"
      puts "Path: #{plan_data[:path].inspect}"
      puts "Term assignments count: #{plan_data[:term_assignments]&.length}"
 
      attributes = {
        degree: @degree,
        starting_school_id: @starting_cc.id,
        ending_school_id: @ending_university.id,
        intermediary_school_id: @nodes.find { |n| ![@starting_cc.id, @ending_university.id].include?(n.id) }&.id,
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
 
    def enforce_minimum_university_credits(terms, school_node, term_number)
      assigned_credits = terms.sum { |term| term['credit_hours'].to_f }
      required_credits = school_node.school.minimum_credits_from_school.to_f
 
      if assigned_credits < required_credits
        additional_credits_needed = required_credits - assigned_credits
        extra_courses = generate_placeholder_courses(additional_credits_needed)
        term_cost = calculate_term_cost(school_node, extra_courses)
        terms << build_term_assignment(school_node.terms.first, extra_courses, additional_credits_needed, term_cost, term_number, school_node.name)
      end
    end
 
    def generate_placeholder_courses(credits_needed)
      courses = []
      while credits_needed > 0
        credit_hours = [credits_needed, 3].min 
        courses << OpenStruct.new(name: "Elective Course", id: nil, credit_hours: credit_hours)
        credits_needed -= credit_hours
      end
      courses
    end
 
    def calculate_term_cost(school_node, courses)
      total_credits = courses.sum(&:credit_hours).to_f
      selected_term = school_node.terms.find { |term| term.credit_hour_minimum <= total_credits && total_credits <= term.credit_hour_maximum }
      if selected_term
        if school_node.school.credit_hour_price.present?
          term_cost = (school_node.school.credit_hour_price * total_credits).to_f
        else
          term_cost = selected_term.tuition_cost.to_f
        end
      else
        if school_node.school.credit_hour_price.present?
          avg_credit_price = school_node.school.credit_hour_price.to_f
          term_cost = (total_credits * avg_credit_price).to_f
        else
          avg_credit_price = school_node.terms.map do |term|
            avg_credits = (term.credit_hour_minimum + term.credit_hour_maximum) / 2.0
            term.tuition_cost.to_f / avg_credits
          end.sum / school_node.terms.size
 
          term_cost = (total_credits * avg_credit_price).to_f
        end
      end
      term_cost
    end
 
    def ending_university_node
      @nodes.find { |node| node.id == @ending_university.id }
    end
  end
 end

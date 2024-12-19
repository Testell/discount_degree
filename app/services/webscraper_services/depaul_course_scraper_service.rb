require "nokogiri"
require "open-uri"
require "set"
require "httparty"

module WebscraperServices
  class DepaulCourseScraperService
    class ScrapingError < StandardError
    end

    #Could use comments alsso seems like it cann be dynamic in the future

    DEPARTMENT_URLS = {
      "CSC" => "https://catalog.depaul.edu/course-descriptions/csc/",
      "IS" => "https://catalog.depaul.edu/course-descriptions/is/",
      "DSC" => "https://catalog.depaul.edu/course-descriptions/dsc/",
      "ECT" => "https://catalog.depaul.edu/course-descriptions/ect/",
      "SE" => "https://catalog.depaul.edu/course-descriptions/se/",
      "IT" => "https://catalog.depaul.edu/course-descriptions/it/",
      "HCI" => "https://catalog.depaul.edu/course-descriptions/hci/",
      "PM" => "https://catalog.depaul.edu/course-descriptions/pm/",
      "NET" => "https://catalog.depaul.edu/course-descriptions/net/"
    }.freeze

    DEPARTMENT_MAPPINGS = {
      "CSC" => "Computer Science",
      "IS" => "Information Systems",
      "DSC" => "Data Science",
      "ECT" => "E-Commerce Technology",
      "SE" => "Software Engineering",
      "IT" => "Information Technology",
      "HCI" => "Human-Computer Interaction",
      "PM" => "Project Management",
      "NET" => "Network Engineering"
    }.freeze

    def initialize(school)
      @school = school
      @processed_courses = []
      @processed_departments = Set.new
      @errors = []
    end

    def self.call(school)
      new(school).perform
    end

    def perform
      Rails.logger.info "Starting scraping for school: #{@school.name} (ID: #{@school.id})"

      courses_data = scrape_courses("CSC")
      transform_courses(courses_data)
      load_courses

      Rails.logger.info "Completed scraping for school: #{@school.name}. Processed #{@processed_courses.count} courses with #{@errors.count} errors."

      { processed: @processed_courses.count, errors: @errors }
    rescue ScrapingError => e
      Rails.logger.error "Scraping failed for school: #{@school.name}. Error: #{e.message}"
      { processed: @processed_courses.count, errors: [e.message] }
    end

    private

    class PrerequisiteNode
      attr_accessor :type, :courses

      def initialize(type = :and)
        @type = type
        @courses = []
      end
    end

    def scrape_courses(dept_code)
      return [] if @processed_departments.include?(dept_code)

      Rails.logger.info "Scraping department: #{dept_code} - #{DEPARTMENT_MAPPINGS[dept_code]}"

      @processed_departments.add(dept_code)

      response =
        HTTParty.get(
          DEPARTMENT_URLS[dept_code],
          headers: {
            "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
          }
        )

      unless response.success?
        Rails.logger.error "Failed to fetch courses for department: #{dept_code}"
        raise ScrapingError, "Failed to fetch courses for department: #{dept_code}"
      end

      Rails.logger.info "Successfully connected to catalog for #{dept_code}"

      page = Nokogiri.HTML(response.body)
      department = DEPARTMENT_MAPPINGS[dept_code]
      courses = []

      Rails.logger.info "Processing course blocks for department: #{dept_code}"

      page
        .css(".courseblocktitle")
        .each do |title_block|
          title_text = title_block.text.gsub("\u00A0", " ").strip

          if match =
               title_text.match(
                 /#{dept_code}\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*(\d+(?:-\d+(?:\.\d+)?)?)\s*quarter hours/i
               )
            current_course = {
              code: dept_code,
              department: department,
              course_number: match[1],
              name: match[2].strip,
              credit_hours: convert_credit_hours(match[3]),
              description: get_description(title_block),
              prerequisites: get_prerequisites(title_block)
            }

            courses << current_course
            Rails.logger.info "Parsed course: #{dept_code} #{match[1]}"
          else
            Rails.logger.warn "Failed to parse course block: #{title_text}"
          end
        end

      Rails.logger.info "Total courses found in department #{dept_code}: #{courses.size}"
      courses
    end

    def get_description(title_block)
      desc_block =
        title_block.xpath('following-sibling::p[contains(@class,"courseblockdesc")]').first
      desc_block&.text&.strip
    end

    def get_prerequisites(title_block)
      prereq_block =
        title_block.xpath(
          'following-sibling::p[contains(@class,"courseblockdesc") or contains(@class,"courseblockhours")]/following-sibling::p[contains(@class,"courseblockextra")]'
        ).first
      return [] unless prereq_block && prereq_block.text.downcase.include?("prerequisite")

      prereq_text = prereq_block.text
      Rails.logger.debug "Prerequisite text: #{prereq_text}"

      all_deps = prereq_text.scan(/(?:#{DEPARTMENT_URLS.keys.join("|")})\s+\d+/)
      all_deps.each do |code|
        if match = code.match(/(\w+)\s+(\d+)/)
          dept = match[1]
          if DEPARTMENT_URLS.key?(dept) && !@processed_departments.include?(dept)
            Rails.logger.info "Found prerequisite from #{dept} department, fetching courses..."
            new_courses = scrape_courses(dept)
            transform_courses(new_courses)
          end
        end
      end

      prerequisites =
        prereq_text
          .scan(/(?:#{DEPARTMENT_URLS.keys.join("|")})\s+\d+/)
          .map do |course_code|
            if code_match = course_code.match(/(\w+)\s+(\d+)/)
              { code: code_match[1], number: code_match[2].to_i }
            end
          end
          .compact

      { type: prereq_text.match(/\bor\b/i) ? "or" : "and", courses: prerequisites }
    end

    def convert_credit_hours(hours_text)
      if hours_text.include?("-")
        hours = hours_text.split("-").map(&:to_f).max
      else
        hours = hours_text.to_f
      end
      (hours / 1.5).round(4)
    end

    def transform_courses(courses_data)
      Rails.logger.info "Transforming course data..."

      courses_data.each do |course_data|
        next unless course_data

        transformed_course = {
          code: course_data[:code].upcase,
          department: course_data[:department],
          course_number: course_data[:course_number].to_i,
          name: normalize_course_name(course_data[:name]),
          credit_hours: course_data[:credit_hours],
          description: course_data[:description],
          prerequisites: normalize_prerequisites(course_data[:prerequisites]),
          school_id: @school.id
        }

        if valid_course?(transformed_course)
          @processed_courses << transformed_course
          Rails.logger.debug "Transformed course: #{transformed_course[:code]} #{transformed_course[:course_number]}"
        else
          Rails.logger.warn "Invalid course data: #{transformed_course.inspect}"
        end
      end
    end

    def normalize_course_name(name)
      words = name.strip.downcase.split(/\s+/)
      words
        .map do |word|
          if word.match?(/^[ivxlcdm]+$/i)
            word.upcase
          elsif word.match?(/^[a-z]+$/i)
            word.capitalize
          else
            word
          end
        end
        .join(" ")
    end

    def normalize_prerequisites(prereq_data)
      return [] unless prereq_data.is_a?(Hash) && prereq_data[:courses].present?

      node = PrerequisiteNode.new(prereq_data[:type].to_sym)
      node.courses = prereq_data[:courses]
      [node]
    end

    def valid_course?(course)
      required_fields = %i[code department course_number name credit_hours]
      valid = required_fields.all? { |field| course[field].present? }

      unless valid
        Rails.logger.warn "Course validation failed for #{course[:code]} #{course[:course_number]}"
      end

      valid
    end

    def load_courses
      Rails.logger.info "Loading courses into the database..."
      Course.transaction do
        @processed_courses.each do |course_data|
          prerequisites = course_data.delete(:prerequisites)

          course =
            Course.find_or_initialize_by(
              code: course_data[:code],
              course_number: course_data[:course_number],
              school_id: course_data[:school_id]
            )

          if course.update(course_data)
            course.course_prerequisites.destroy_all

            prerequisites.each do |prereq_node|
              case prereq_node.type
              when :and
                prereq_node.courses.each { |prereq| create_prerequisite(course, prereq, "and") }
              when :or
                prereq_node.courses.each { |prereq| create_prerequisite(course, prereq, "or") }
              end
            end

            Rails.logger.info "Successfully saved course: #{course.code} #{course.course_number}"
          else
            @errors << "Failed to save course #{course_data[:code]} #{course_data[:course_number]}: #{course.errors.full_messages.join(", ")}"
            Rails.logger.error "Failed to save course: #{course.code} #{course.course_number}. Errors: #{course.errors.full_messages.join(", ")}"
          end
        end
      end
    rescue StandardError => e
      @errors << "Database error: #{e.message}"
      Rails.logger.error "Database error occurred: #{e.message}"
      raise e
    end

    def create_prerequisite(course, prereq_data, logic_type)
      prereq_course =
        Course.find_by(
          code: prereq_data[:code],
          course_number: prereq_data[:number],
          school_id: course.school_id
        )

      if prereq_course
        CoursePrerequisite.create!(
          course: course,
          prerequisite: prereq_course,
          logic_type: logic_type
        )
        Rails.logger.info "Created prerequisite: #{prereq_course.code} #{prereq_course.course_number} for #{course.code} #{course.course_number}"
      else
        @errors << "Prerequisite course not found: #{prereq_data[:code]} #{prereq_data[:number]}"
        Rails.logger.warn "Prerequisite course not found: #{prereq_data[:code]} #{prereq_data[:number]} for course #{course.code} #{course.course_number}"
      end
    end
  end
end

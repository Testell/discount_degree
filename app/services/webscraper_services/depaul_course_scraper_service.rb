module WebscraperServices
  class DepaulCourseScraperService
    class ScrapingError < StandardError
    end

    DEPARTMENT_MAPPINGS = { "CSC" => "Computer Science" }.freeze

    def initialize(school)
      @school = school
      @processed_courses = []
      @errors = []
    end

    def self.call(school)
      new(school).perform
    end

    def perform
      courses_data = scrape_courses
      transform_courses(courses_data)
      load_courses

      { processed: @processed_courses.count, errors: @errors }
    end

    private

    class PrerequisiteNode
      attr_accessor :type, :courses

      def initialize(type = :and)
        @type = type # :and, :or
        @courses = []
      end
    end

    def scrape_courses
      puts "Attempting to fetch courses from DePaul catalog..."
      response =
        HTTParty.get(
          "https://catalog.depaul.edu/course-descriptions/csc/",
          headers: {
            "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
            "Accept" => "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"
          }
        )

      raise ScrapingError, "Failed to fetch courses" unless response.success?
      puts "Successfully connected to DePaul catalog"

      page = Nokogiri.HTML(response.body)

      department_match = page.css(".page-title").text.match(/(.+?)\s+\(CSC\)/)
      if department_match
        department = department_match[1].strip
      else
        raise ScrapingError, "Failed to determine department from page title."
      end
      puts "\nDepartment found: #{department}"

      courses = []
      regex = /CSC\s*(\d+)\s*\|\s*([^|]+?)\s*\|\s*(\d+(?:-\d+(?:\.\d+)?)?)\s*quarter hours/i

      page
        .css(".courseblocktitle")
        .each do |title_block|
          title_text = title_block.text
          title_text = title_text.gsub("\u00A0", " ").strip

          hours_block =
            title_block.xpath('following-sibling::p[contains(@class, "courseblockhours")]').first
          hours_text = hours_block ? hours_block.text.gsub("\u00A0", " ").strip : ""

          full_text = [title_text, hours_text].reject(&:empty?).join(" | ")

          puts "\nProcessing title: #{full_text}"
          puts "Debug full_text: #{full_text.inspect}"

          if (match = full_text.match(regex))
            course_number = match[1]
            course_name = match[2].strip
            raw_hours = match[3]

            current_course = {
              code: "CSC",
              department: department,
              course_number: course_number,
              name: course_name,
              credit_hours: convert_credit_hours(raw_hours),
              description: get_description(title_block),
              prerequisites: get_prerequisites(title_block)
            }

            courses << current_course

            puts "Successfully parsed:"
            puts "Code: #{current_course[:code]}"
            puts "Course Number: #{current_course[:course_number]}"
            puts "Name: #{current_course[:name]}"
            puts "Credit Hours: #{current_course[:credit_hours]}"
          else
            puts "WARNING: Failed to parse course block: #{full_text}"
          end
        end

      puts "\nTotal courses found: #{courses.size}"
      courses
    end

    def get_description(title_block)
      desc_block =
        title_block.xpath('following-sibling::p[contains(@class,"courseblockdesc")]').first
      return nil unless desc_block
      desc_block.text.strip
    end

    def get_prerequisites(title_block)
      prereq_block =
        title_block.xpath(
          'following-sibling::p[contains(@class,"courseblockdesc") or contains(@class,"courseblockhours")]/following-sibling::p[contains(@class,"courseblockextra")]'
        ).first

      return [] unless prereq_block && prereq_block.text.downcase.include?("prerequisite")

      prereq_text = prereq_block.text
      prerequisites =
        prereq_text
          .scan(/CSC\s+\d+/)
          .map do |course_code|
            if code_match = course_code.match(/CSC\s+(\d+)/)
              { code: "CSC", number: code_match[1].to_i }
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
      puts "\nTransforming course data..."
      courses_data.each do |course_data|
        transformed_course = {
          code: course_data[:code],
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
          puts "\nTransformed course:"
          puts "#{transformed_course[:code]} #{transformed_course[:course_number]}"
          puts "Name: #{transformed_course[:name]}"
          puts "Credit Hours: #{transformed_course[:credit_hours]}"
          puts "Prerequisites: #{transformed_course[:prerequisites].inspect}"
        else
          puts "\nWARNING: Invalid course data: #{transformed_course.inspect}"
        end
      end
      puts "\nTransformed #{@processed_courses.count} courses"
    end

    def normalize_course_name(name)
      name.strip.gsub(/\s+/, " ")
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
        puts "Course validation #{valid ? "passed" : "failed"} for #{course[:code]} #{course[:course_number]}"
      end
      valid
    end

    def load_courses
      puts "\nLoading courses into database..."
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
            puts "Successfully saved course: #{course.code} #{course.course_number}"
          else
            @errors << "Failed to save course #{course_data[:code]}: #{course.errors.full_messages.join(", ")}"
            puts "ERROR: Failed to save course: #{course_data[:code]} #{course_data[:course_number]}"
          end
        end
      end
    rescue StandardError => e
      @errors << "Database error: #{e.message}"
      puts "ERROR: Database error occurred: #{e.message}"
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
        puts "Created prerequisite: #{prereq_data[:code]} #{prereq_data[:number]} for #{course.code} #{course.course_number}"
      else
        @errors << "Prerequisite course not found: #{prereq_data[:code]} #{prereq_data[:number]}"
        puts "WARNING: Prerequisite course not found: #{prereq_data[:code]} #{prereq_data[:number]}"
      end
    end
  end
end

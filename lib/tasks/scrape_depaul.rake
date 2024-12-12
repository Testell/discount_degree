namespace :scrape do
  desc "Scrape DePaul University CS courses"
  task depaul: :environment do
    puts "Starting DePaul course import..."

    school = School.find_or_create_by!(name: "DePaul University", school_type: "university")

    result = WebscraperServices::DepaulCourseScraperService.call(school)

    puts "Import complete!"
    puts "Processed #{result[:processed]} courses"

    if result[:errors].any?
      puts "\nErrors encountered:"
      result[:errors].each { |error| puts "- #{error}" }
    end
  end
end

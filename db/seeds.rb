# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# Run this only in the development environment
if Rails.env.development?
  admin_email = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
  admin_password = ENV.fetch('ADMIN_PASSWORD', 'password123')

  admin_user = User.find_or_create_by!(email: admin_email) do |user|
    user.username = 'admin'
    user.password = admin_password
    user.password_confirmation = admin_password
    user.role = 'admin'
  end

  puts "Admin user created in development: #{admin_user.email}, role: #{admin_user.role}"
else
  puts "Did not create seeded Admin User"
end

# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Create admin user
admin = User.find_or_initialize_by(email: "admin@example.com")
admin.assign_attributes(
  name: "Admin User",
  password: "password123",
  password_confirmation: "password123",
  role: :admin,
  subscription_status: :active
)
admin.skip_confirmation! if admin.new_record?
admin.save!
puts "Created admin user: #{admin.email}"

# Create sample member (development only)
if Rails.env.development?
  member = User.find_or_initialize_by(email: "member@example.com")
  member.assign_attributes(
    name: "Sample Member",
    password: "password123",
    password_confirmation: "password123",
    role: :member,
    subscription_status: :active
  )
  member.skip_confirmation! if member.new_record?
  member.save!
  puts "Created member user: #{member.email}"

  # Create trialing user
  trialing = User.find_or_initialize_by(email: "trialing@example.com")
  trialing.assign_attributes(
    name: "Trialing User",
    password: "password123",
    password_confirmation: "password123",
    role: :member,
    subscription_status: :trialing,
    trial_ends_at: 7.days.from_now
  )
  trialing.skip_confirmation! if trialing.new_record?
  trialing.save!
  puts "Created trialing user: #{trialing.email}"
end

puts "Seeding completed!"

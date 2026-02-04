# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }
    name { Faker::Name.name }
    confirmed_at { Time.current }
    role { :member }
    subscription_status { :none }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :admin do
      role { :admin }
      subscription_status { :active }
    end

    trait :with_subscription do
      subscription_status { :active }
      stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
      stripe_subscription_id { "sub_#{SecureRandom.alphanumeric(14)}" }
    end

    trait :trialing do
      subscription_status { :trialing }
      trial_ends_at { 7.days.from_now }
      stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
      stripe_subscription_id { "sub_#{SecureRandom.alphanumeric(14)}" }
    end

    trait :past_due do
      subscription_status { :past_due }
      stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
      stripe_subscription_id { "sub_#{SecureRandom.alphanumeric(14)}" }
    end

    trait :canceled do
      subscription_status { :canceled }
      stripe_customer_id { "cus_#{SecureRandom.alphanumeric(14)}" }
    end

    trait :oauth do
      provider { "google_oauth2" }
      uid { SecureRandom.uuid }
    end
  end
end

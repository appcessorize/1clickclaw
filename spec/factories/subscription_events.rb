FactoryBot.define do
  factory :subscription_event do
    user { nil }
    event_type { "MyString" }
    stripe_event_id { "MyString" }
    payload { "" }
    processed_at { "2026-02-04 13:56:42" }
  end
end

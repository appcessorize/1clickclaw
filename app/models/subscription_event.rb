# frozen_string_literal: true

class SubscriptionEvent < ApplicationRecord
  belongs_to :user

  validates :event_type, presence: true
  validates :stripe_event_id, presence: true, uniqueness: true
  validates :payload, presence: true

  scope :unprocessed, -> { where(processed_at: nil) }
  scope :processed, -> { where.not(processed_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def processed?
    processed_at.present?
  end

  def mark_as_processed!
    update!(processed_at: Time.current)
  end
end

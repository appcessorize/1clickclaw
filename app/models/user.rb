# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :trackable, :omniauthable,
         omniauth_providers: [:google_oauth2]

  # Enums
  enum :role, { member: 0, admin: 1 }
  enum :subscription_status, {
    none: 0,
    trialing: 1,
    active: 2,
    past_due: 3,
    canceled: 4,
    unpaid: 5
  }, prefix: :subscription

  # Associations
  has_many :subscription_events, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true
  validates :subscription_status, presence: true

  # Scopes
  scope :admins, -> { where(role: :admin) }
  scope :members, -> { where(role: :member) }
  scope :with_active_subscription, -> { where(subscription_status: [:trialing, :active]) }
  scope :subscribed, -> { where(subscription_status: [:trialing, :active, :past_due]) }

  # OAuth
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      # Skip confirmation for OAuth users with verified emails
      user.skip_confirmation! if auth.info.email_verified
    end
  end

  # Subscription helpers
  def subscribed?
    subscription_trialing? || subscription_active?
  end

  def can_access_dashboard?
    subscribed? || subscription_past_due?
  end

  def trial_active?
    subscription_trialing? && trial_ends_at.present? && trial_ends_at > Time.current
  end

  def trial_expired?
    subscription_trialing? && trial_ends_at.present? && trial_ends_at <= Time.current
  end

  def days_remaining_in_trial
    return 0 unless trial_active?

    ((trial_ends_at - Time.current) / 1.day).ceil
  end

  # Display name helper
  def display_name
    name.presence || email.split("@").first
  end
end

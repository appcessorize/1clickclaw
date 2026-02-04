# frozen_string_literal: true

class BackfillSubscriptionsJob < ApplicationJob
  queue_as :default

  def perform
    User.where.not(stripe_subscription_id: nil).find_each do |user|
      sync_subscription(user)
    rescue Stripe::InvalidRequestError => e
      Rails.logger.error "Failed to sync subscription for user #{user.id}: #{e.message}"
    end
  end

  private

  def sync_subscription(user)
    subscription = Stripe::Subscription.retrieve(user.stripe_subscription_id)

    status = map_status(subscription.status)
    trial_end = subscription.trial_end ? Time.at(subscription.trial_end) : nil

    user.update!(
      subscription_status: status,
      trial_ends_at: trial_end
    )

    Rails.logger.info "Synced subscription for user #{user.id}: #{status}"
  end

  def map_status(stripe_status)
    case stripe_status
    when "trialing"
      :trialing
    when "active"
      :active
    when "past_due"
      :past_due
    when "canceled", "unpaid"
      :canceled
    else
      :none
    end
  end
end

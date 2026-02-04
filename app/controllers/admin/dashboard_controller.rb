# frozen_string_literal: true

module Admin
  class DashboardController < BaseController
    def index
      @stats = {
        total_users: User.count,
        active_subscriptions: User.with_active_subscription.count,
        trialing_users: User.where(subscription_status: :trialing).count,
        canceled_users: User.where(subscription_status: :canceled).count,
        past_due_users: User.where(subscription_status: :past_due).count,
        new_users_this_month: User.where("created_at >= ?", Time.current.beginning_of_month).count
      }

      @recent_users = User.order(created_at: :desc).limit(5)
      @recent_events = SubscriptionEvent.includes(:user).recent.limit(10)
    end
  end
end

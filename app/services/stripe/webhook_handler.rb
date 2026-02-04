# frozen_string_literal: true

module Stripe
  class WebhookHandler
    def initialize(event)
      @event = event
    end

    def process
      case @event.type
      when "checkout.session.completed"
        handle_checkout_session_completed
      when "customer.subscription.created"
        handle_subscription_created
      when "customer.subscription.updated"
        handle_subscription_updated
      when "customer.subscription.deleted"
        handle_subscription_deleted
      when "invoice.payment_failed"
        handle_payment_failed
      when "invoice.payment_succeeded"
        handle_payment_succeeded
      else
        Rails.logger.info "Unhandled Stripe event type: #{@event.type}"
      end
    end

    private

    def handle_checkout_session_completed
      session = @event.data.object
      user = find_user_from_metadata(session)
      return unless user

      subscription = ::Stripe::Subscription.retrieve(session.subscription)
      update_user_subscription(user, subscription)

      log_event(user)
    end

    def handle_subscription_created
      subscription = @event.data.object
      user = find_user_from_subscription(subscription)
      return unless user

      update_user_subscription(user, subscription)
      log_event(user)
    end

    def handle_subscription_updated
      subscription = @event.data.object
      user = find_user_from_subscription(subscription)
      return unless user

      update_user_subscription(user, subscription)
      log_event(user)
    end

    def handle_subscription_deleted
      subscription = @event.data.object
      user = find_user_from_subscription(subscription)
      return unless user

      user.update!(
        subscription_status: :canceled,
        stripe_subscription_id: nil
      )

      log_event(user)
      SubscriptionMailer.subscription_canceled(user).deliver_later
    end

    def handle_payment_failed
      invoice = @event.data.object
      user = find_user_by_customer_id(invoice.customer)
      return unless user

      user.update!(subscription_status: :past_due)
      log_event(user)
      SubscriptionMailer.payment_failed(user).deliver_later
    end

    def handle_payment_succeeded
      invoice = @event.data.object
      user = find_user_by_customer_id(invoice.customer)
      return unless user

      user.update!(subscription_status: :active) if user.subscription_past_due?
      log_event(user)
    end

    def find_user_from_metadata(object)
      user_id = object.metadata&.user_id
      return User.find_by(id: user_id) if user_id

      find_user_by_customer_id(object.customer)
    end

    def find_user_from_subscription(subscription)
      user_id = subscription.metadata&.user_id
      return User.find_by(id: user_id) if user_id

      find_user_by_customer_id(subscription.customer)
    end

    def find_user_by_customer_id(customer_id)
      User.find_by(stripe_customer_id: customer_id)
    end

    def update_user_subscription(user, subscription)
      status = map_subscription_status(subscription.status)
      trial_end = subscription.trial_end ? Time.at(subscription.trial_end) : nil

      user.update!(
        stripe_subscription_id: subscription.id,
        subscription_status: status,
        trial_ends_at: trial_end
      )
    end

    def map_subscription_status(stripe_status)
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

    def log_event(user)
      SubscriptionEvent.create!(
        user: user,
        event_type: @event.type,
        stripe_event_id: @event.id,
        payload: @event.data.object.to_hash,
        processed_at: Time.current
      )
    rescue ActiveRecord::RecordNotUnique
      Rails.logger.info "Duplicate Stripe event: #{@event.id}"
    end
  end
end

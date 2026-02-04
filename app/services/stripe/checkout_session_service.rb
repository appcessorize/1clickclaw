# frozen_string_literal: true

module Stripe
  class CheckoutSessionService
    TRIAL_DAYS = 7

    def initialize(user, options = {})
      @user = user
      @options = options
    end

    def create
      customer_service = CustomerService.new(@user)
      customer = customer_service.find_or_create

      ::Stripe::Checkout::Session.create(session_params(customer))
    end

    private

    def session_params(customer)
      params = {
        customer: customer.id,
        mode: "subscription",
        payment_method_types: ["card"],
        line_items: [{
          price: price_id,
          quantity: 1
        }],
        success_url: success_url,
        cancel_url: cancel_url,
        metadata: {
          user_id: @user.id
        },
        subscription_data: {
          metadata: {
            user_id: @user.id
          }
        }
      }

      # Add trial period if user hasn't had a trial before
      if @options[:with_trial] && !@user.trial_ends_at.present?
        params[:subscription_data][:trial_period_days] = TRIAL_DAYS
      end

      params
    end

    def price_id
      @options[:price_id] || Rails.configuration.stripe[:price_id]
    end

    def success_url
      @options[:success_url] || "#{base_url}/subscriptions/success?session_id={CHECKOUT_SESSION_ID}"
    end

    def cancel_url
      @options[:cancel_url] || "#{base_url}/subscriptions/cancel"
    end

    def base_url
      host = ENV.fetch("APP_HOST", "localhost:3000")
      protocol = ENV.fetch("APP_PROTOCOL", "http")
      "#{protocol}://#{host}"
    end
  end
end

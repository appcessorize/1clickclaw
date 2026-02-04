# frozen_string_literal: true

module Stripe
  class PortalSessionService
    def initialize(user, options = {})
      @user = user
      @options = options
    end

    def create
      raise ArgumentError, "User has no Stripe customer ID" unless @user.stripe_customer_id.present?

      ::Stripe::BillingPortal::Session.create(
        customer: @user.stripe_customer_id,
        return_url: return_url
      )
    end

    private

    def return_url
      @options[:return_url] || "#{base_url}/dashboard"
    end

    def base_url
      host = ENV.fetch("APP_HOST", "localhost:3000")
      protocol = ENV.fetch("APP_PROTOCOL", "http")
      "#{protocol}://#{host}"
    end
  end
end

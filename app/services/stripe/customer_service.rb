# frozen_string_literal: true

module Stripe
  class CustomerService
    def initialize(user)
      @user = user
    end

    def find_or_create
      return retrieve if @user.stripe_customer_id.present?

      create
    end

    def retrieve
      ::Stripe::Customer.retrieve(@user.stripe_customer_id)
    rescue ::Stripe::InvalidRequestError
      create
    end

    def create
      customer = ::Stripe::Customer.create(
        email: @user.email,
        name: @user.name,
        metadata: {
          user_id: @user.id
        }
      )

      @user.update!(stripe_customer_id: customer.id)
      customer
    end

    def update(params = {})
      return unless @user.stripe_customer_id.present?

      ::Stripe::Customer.update(
        @user.stripe_customer_id,
        params
      )
    end
  end
end

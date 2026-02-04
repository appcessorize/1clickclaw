# frozen_string_literal: true

module Webhooks
  class StripeController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_after_action :verify_authorized, if: -> { respond_to?(:verify_authorized) }

    def create
      payload = request.body.read
      sig_header = request.env["HTTP_STRIPE_SIGNATURE"]
      webhook_secret = Rails.configuration.stripe[:webhook_secret]

      begin
        event = Stripe::Webhook.construct_event(payload, sig_header, webhook_secret)
      rescue JSON::ParserError
        Rails.logger.error "Stripe webhook JSON parse error"
        render json: { error: "Invalid payload" }, status: :bad_request
        return
      rescue Stripe::SignatureVerificationError
        Rails.logger.error "Stripe webhook signature verification failed"
        render json: { error: "Invalid signature" }, status: :bad_request
        return
      end

      Rails.logger.info "Processing Stripe event: #{event.type} (#{event.id})"

      handler = Stripe::WebhookHandler.new(event)
      handler.process

      render json: { received: true }, status: :ok
    rescue StandardError => e
      Rails.logger.error "Stripe webhook processing error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      render json: { error: "Webhook processing failed" }, status: :internal_server_error
    end
  end
end

# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!

  def create
    checkout_service = Stripe::CheckoutSessionService.new(
      current_user,
      with_trial: params[:trial].present?
    )

    session = checkout_service.create
    redirect_to session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe error: #{e.message}"
    redirect_to pricing_path, alert: "Unable to start checkout. Please try again."
  end

  def success
    if params[:session_id].present?
      flash[:notice] = "Welcome! Your subscription is now active."
    end
    redirect_to dashboard_path
  end

  def cancel
    redirect_to pricing_path, notice: "Checkout was cancelled."
  end

  def portal
    portal_service = Stripe::PortalSessionService.new(current_user)
    session = portal_service.create

    redirect_to session.url, allow_other_host: true
  rescue ArgumentError => e
    redirect_to dashboard_path, alert: e.message
  rescue Stripe::StripeError => e
    Rails.logger.error "Stripe portal error: #{e.message}"
    redirect_to dashboard_path, alert: "Unable to access billing portal. Please try again."
  end
end

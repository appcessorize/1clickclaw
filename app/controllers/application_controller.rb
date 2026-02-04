# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Devise strong parameters
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Pundit authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    elsif resource.subscribed?
      dashboard_path
    else
      pricing_path
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end
end

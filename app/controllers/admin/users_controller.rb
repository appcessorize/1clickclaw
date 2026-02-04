# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :set_user, only: [:show, :edit, :update, :impersonate, :comp_subscription]

    def index
      @users = User.order(created_at: :desc)

      # Filtering
      @users = @users.where(role: params[:role]) if params[:role].present?
      @users = @users.where(subscription_status: params[:status]) if params[:status].present?
      @users = @users.where("email ILIKE ?", "%#{params[:search]}%") if params[:search].present?

      @users = @users.page(params[:page]).per(20) if @users.respond_to?(:page)
    end

    def show
      @subscription_events = @user.subscription_events.recent.limit(20)
    end

    def edit
    end

    def update
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: "User updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def impersonate
      authorize [:admin, @user], :impersonate?

      sign_in(:user, @user)
      redirect_to dashboard_path, notice: "Now impersonating #{@user.email}"
    end

    def comp_subscription
      authorize [:admin, @user], :comp_subscription?

      @user.update!(
        subscription_status: :active,
        trial_ends_at: nil
      )

      redirect_to admin_user_path(@user), notice: "Subscription comped successfully."
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:name, :email, :role, :subscription_status)
    end
  end
end

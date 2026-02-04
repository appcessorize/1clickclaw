# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :dashboard, :show?
  end
end

# frozen_string_literal: true

class SettingsController < ApplicationController
  before_action :authenticate_user!

  def show
    authorize :settings
  end
end

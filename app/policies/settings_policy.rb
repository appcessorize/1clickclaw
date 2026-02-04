# frozen_string_literal: true

class SettingsPolicy < ApplicationPolicy
  def show?
    user.present?
  end
end

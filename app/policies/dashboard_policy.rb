# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def show?
    user.present? && user.can_access_dashboard?
  end
end

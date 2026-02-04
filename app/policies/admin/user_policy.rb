# frozen_string_literal: true

module Admin
  class UserPolicy < BasePolicy
    def impersonate?
      user&.admin? && user != record
    end

    def comp_subscription?
      user&.admin?
    end
  end
end

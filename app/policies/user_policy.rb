# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.admin?
  end

  def show?
    user.admin? || user == record
  end

  def update?
    user.admin? || user == record
  end

  def destroy?
    user.admin? && user != record
  end

  def impersonate?
    user.admin? && user != record
  end

  def comp_subscription?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end

class UserPolicy < ApplicationPolicy
  def show?
    user == record || admin?
  end

  def save_plan?
    user == record || admin?
  end

  def remove_saved_plan?
    user == record || admin?
  end

  def save_plan_prompt?
    true
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.where(id: user.id)
    end
  end
end

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
      if user.admin?
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end

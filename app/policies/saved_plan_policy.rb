class SavedPlanPolicy < ApplicationPolicy
  def show?
    user == record.user || admin?
  end
  
  def create?
    user.present?
  end

  def destroy?
    user.present? && record.user == user
  end

  class Scope < Scope
    def resolve
      scope.where(user: user)
    end
  end
end

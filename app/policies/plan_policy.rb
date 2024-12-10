class PlanPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def update?
    admin?
  end

  def edit?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      user.admin? ? scope.all : scope.none
    end
  end
end

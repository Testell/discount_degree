class SchoolPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin?
  end

  def new?
    admin?
  end

  def edit?
    admin?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  def scrape_courses?
    admin?
  end

  class Scope < Scope
    def resolve
      admin? ? scope.all : scope.none
    end
  end
end

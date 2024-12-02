class AdminPolicy < ApplicationPolicy
  def initialize(user, _)
    super
  end

  def index?
    admin?
  end

  def create?
    admin?
  end

  def access?
    admin?
  end
end

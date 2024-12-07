class PagePolicy < ApplicationPolicy
  def home?
    true  
  end

  def plan_page?
    true  
  end

  def generate_plan?
    true  
  end

  def show_plan?
    true  
  end
end

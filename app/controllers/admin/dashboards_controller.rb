class Admin::DashboardsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_dashboard

  def show
    daily_visitors_data = Ahoy::Visit.group_by_day(:started_at).distinct.count(:visitor_token)
    source_of_traffic_data =
      Ahoy::Visit
        .where.not(referring_domain: nil)
        .group(:referring_domain)
        .distinct
        .count(:visitor_token)

    favorite_pages_data = Ahoy::Event.where(name: "Ran action").group("properties->>'page'").count

    @daily_visitors_data = daily_visitors_data
    @source_of_traffic_data = source_of_traffic_data
    @favorite_pages_data = favorite_pages_data
  end

  private

  def authorize_dashboard
    authorize :dashboard, :show?
  end
end

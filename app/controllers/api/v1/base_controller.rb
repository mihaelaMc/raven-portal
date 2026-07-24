class Api::V1::BaseController < ApplicationController
  before_action :authenticate_user!

  private

  # Kaminari raises ZeroPerPageOperation on .per(0) (a 500 for whoever sent
  # ?per_page=0), and negative values reach Postgres as a bad LIMIT - clamp
  # instead of trusting the caller.
  def per_page_param(default: 25)
    (params[:per_page].presence || default).to_i.clamp(1, 100)
  end
end

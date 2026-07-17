class Api::V1::ProfilesController < Api::V1::BaseController
  def show
    render json: { user: current_user }, status: :ok
  end
end

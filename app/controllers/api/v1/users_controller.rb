class Api::V1::UsersController < Api::V1::BaseController
  def show
    user = User.find(params[:id])
    authorize user

    render json: { user: user }, status: :ok
  end
end

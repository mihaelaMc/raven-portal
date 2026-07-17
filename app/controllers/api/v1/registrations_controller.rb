class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def respond_with(resource, _opts = {})
    if resource.persisted?
      _, raw_refresh_token = RefreshToken.issue_for(resource)

      render json: {
        message: "Your crawler has entered the dungeon.",
        user: resource,
        refresh_token: raw_refresh_token
      }, status: :ok
    else
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
    end
  end
end

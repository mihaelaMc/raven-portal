class Api::V1::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  # Overridden entirely (not just #respond_with) so a password change doesn't
  # fall through to the signup response below and mint a fresh refresh token -
  # that only makes sense for create, not for editing an existing account.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    resource_updated = update_resource(resource, account_update_params)

    if resource_updated
      render json: { message: "Your details have been updated.", user: resource }, status: :ok
    else
      clean_up_passwords(resource)
      render json: { errors: resource.errors.full_messages }, status: :unprocessable_content
    end
  end

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

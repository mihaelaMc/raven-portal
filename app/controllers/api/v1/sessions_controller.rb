class Api::V1::SessionsController < Devise::SessionsController
  respond_to :json

  # Devise's own verify_signed_out_user check calls warden.user(run_callbacks: false),
  # which never runs the :jwt strategy, so it always looks signed-out for a token-based
  # API. authenticate_user! runs the strategy for real, so it can tell.
  skip_before_action :verify_signed_out_user, only: :destroy
  prepend_before_action :authenticate_user!, only: :destroy

  def destroy
    @user_to_clean_up = current_user
    @user_to_clean_up.refresh_tokens.where(revoked_at: nil).update_all(revoked_at: Time.current)
    super
  end

  private

  def respond_with(resource, _opts = {})
    _, raw_refresh_token = RefreshToken.issue_for(resource)

    AuditLogJob.perform_later(
      actor_id: resource.id,
      subject_id: resource.id,
      action: "login",
      ip_address: request.remote_ip
    )

    render json: {
      message: "The dungeon remembers you.",
      user: resource,
      refresh_token: raw_refresh_token
    }, status: :ok
  end

  def respond_to_on_destroy(non_navigational_status: :no_content)
    AuditLogJob.perform_later(
      actor_id: @user_to_clean_up.id,
      subject_id: @user_to_clean_up.id,
      action: "logout",
      ip_address: request.remote_ip
    )

    render json: { message: "You have left the dungeon." }, status: :ok
  end
end

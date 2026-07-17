class Api::V1::RefreshTokensController < ApplicationController
  def create
    refresh_token = RefreshToken.authenticate(params.require(:refresh_token))

    if refresh_token
      refresh_token.revoke!
      _, raw_refresh_token = RefreshToken.issue_for(refresh_token.user)
      access_token = Warden::JWTAuth::UserEncoder.new.call(refresh_token.user, :user, nil).first

      render json: {
        access_token: access_token,
        refresh_token: raw_refresh_token,
        user: refresh_token.user
      }, status: :ok
    else
      render json: { error: "Invalid or expired refresh token." }, status: :unauthorized
    end
  end
end

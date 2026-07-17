class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :forbidden

  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def forbidden
    render json: { error: "You are not authorized to do that." }, status: :forbidden
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :crawler_name ])
  end
end

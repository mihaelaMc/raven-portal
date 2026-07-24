class Api::V1::UsersController < Api::V1::BaseController
  def index
    authorize User

    users = User.all
    users = users.where("crawler_name ILIKE :q OR email ILIKE :q", q: "%#{User.sanitize_sql_like(params[:q])}%") if params[:q].present?
    users = users.order(:id).page(params[:page]).per(params[:per_page] || 25)

    render json: {
      users: users,
      meta: {
        current_page: users.current_page,
        total_pages: users.total_pages,
        total_count: users.total_count
      }
    }, status: :ok
  end

  def show
    user = User.find(params[:id])
    authorize user

    render json: { user: user }, status: :ok
  end

  def update
    user = User.find(params[:id])
    authorize user

    user.assign_attributes(user_params)
    user.role = role_param if current_user.admin? && role_param.present?

    if user.save
      log_update(user)
      render json: { user: user }, status: :ok
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user

    actor_id = current_user.id
    action = actor_id == user.id ? "account_deleted" : "admin_deleted_user"
    snapshot = { "email" => user.email, "crawler_name" => user.crawler_name, "role" => user.role }

    user.destroy

    AuditLogJob.perform_later(
      actor_id: actor_id,
      subject_id: user.id,
      action: action,
      metadata: snapshot,
      ip_address: request.remote_ip
    )

    head :no_content
  end

  private

  # :role is deliberately kept out of this permit list: only an admin may set it,
  # handled explicitly in #update rather than via mass assignment.
  def user_params
    params.require(:user).permit(:crawler_name, :avatar)
  end

  def role_param
    params.dig(:user, :role)
  end

  def log_update(user)
    changes = user.saved_changes.except("updated_at").transform_values { |(from, to)| { "from" => from, "to" => to } }
    action = current_user.id == user.id ? "profile_updated" : "admin_updated_user"

    AuditLogJob.perform_later(
      actor_id: current_user.id,
      subject_id: user.id,
      action: action,
      metadata: { "changes" => changes, "avatar_updated" => user_params[:avatar].present? },
      ip_address: request.remote_ip
    )
  end
end

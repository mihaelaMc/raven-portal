class Api::V1::AuditLogsController < Api::V1::BaseController
  def index
    authorize AuditLog

    # NB: the filter is `audit_action`, not `action` - `params[:action]` is Rails' own
    # reserved routing key (the current controller action's name, e.g. "index" here),
    # so filtering on `params[:action]` would silently match nothing real ever hits.
    logs = AuditLog.all
    logs = logs.where(action: params[:audit_action]) if params[:audit_action].present?
    logs = logs.where(actor_id: params[:actor_id]) if params[:actor_id].present?
    logs = logs.where(subject_id: params[:subject_id]) if params[:subject_id].present?
    logs = logs.where(created_at: params[:from]..) if params[:from].present?
    logs = logs.where(created_at: ..params[:to]) if params[:to].present?
    logs = logs.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 25)

    render json: {
      audit_logs: logs,
      meta: {
        current_page: logs.current_page,
        total_pages: logs.total_pages,
        total_count: logs.total_count
      }
    }, status: :ok
  end
end

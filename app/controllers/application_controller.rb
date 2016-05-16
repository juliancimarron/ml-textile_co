class ApplicationController < ActionController::Base
  before_action :authenticate_employee

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def authenticate_employee 
    case request.fullpath
    when '/'
    when new_employee_session_path
    else
      redirect_to new_employee_session_path unless employee_signed_in?
    end
  end

  def authorize_employee 
    unless current_employee.admin?
      redirect_to timelogs_url, notice: "You attempted an unauthorized action."
    end
  end

end

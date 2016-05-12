class PagesController < ApplicationController

  # GET /sign_in
  def root_proxy
    if employee_signed_in?
      redirect_to timelogs_path
    else
      redirect_to new_employee_session_path
    end
  end

end

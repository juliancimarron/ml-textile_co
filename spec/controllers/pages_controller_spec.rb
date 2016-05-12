require 'rails_helper'

RSpec.describe PagesController, type: :controller do

  fixtures :employees

  describe "GET #root_proxy" do
    it "redirects to Sign In if user not logged in" do
      get :root_proxy
      expect(request).to redirect_to new_employee_session_path
    end

    it "redirects to timelogs#index if user logged in" do
      sign_in employees(:julian)
      get :root_proxy
      expect(request).to redirect_to timelogs_path
    end
  end

end

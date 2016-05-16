require 'rails_helper'

RSpec.describe "Pages", type: :request do
  include Warden::Test::Helpers
  Warden.test_mode!

  fixtures :employees

  let(:reg_employee) { employees(:john) }
  let(:admin_employee) { employees(:julian) }
  let(:login_admin) do
    logout
    login_as(admin_employee)
  end

  before(:example) { login_as(reg_employee) }

  context 'GET /root_proxy' do 
    it "returns 302 if not logged in" do
      logout
      get root_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_employee_session_path)
      expect(flash[:notice]).to be_nil
    end      

    it "returns 302 as regular employee" do
      get root_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelogs_path)
    end      

    it "returns 302 as admin employee" do
      login_admin
      get root_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelogs_path)
    end
  end

end

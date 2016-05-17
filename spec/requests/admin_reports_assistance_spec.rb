require 'rails_helper'

RSpec.describe "admin/reports/assistance", type: :request do
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

  context 'GET /admin/reports/assistance' do 
    it "returns 302 as regular employee" do
      get admin_reports_assistance_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelogs_path)
    end

    it "returns 200 as admin employee" do
      login_admin
      get admin_reports_assistance_path
      expect(response).to have_http_status(:success)
    end  
  end

end

require 'rails_helper'
require 'support/model_attributes'

RSpec.describe "admin/timelogs/reported_errors", type: :request do
  include_context 'model_attributes'

  include Warden::Test::Helpers
  Warden.test_mode!

  fixtures :employees
  fixtures :timelogs

  let(:reg_employee) { employees(:john) }
  let(:admin_employee) { employees(:julian) }
  let(:login_admin) do
    logout
    login_as(admin_employee)
  end

  before(:example) { login_as(reg_employee) }

  context 'GET /admin/timelogs/reported_errors' do 
    it "returns 302 as regular employee" do
      get admin_timelogs_reported_errors_path
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelogs_path)
    end

    it "returns 200 as admin employee" do
      login_admin
      get admin_timelogs_reported_errors_path
      expect(response).to have_http_status(:success)
    end  
  end

  context 'PUT /admin/timelogs/reported_errors/:id/update' do 
    it "returns 302 as regular employee" do
      put admin_timelogs_reported_error_path(employees(:john).id)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelogs_path)
    end

    it "returns 302 as admin employee" do
      login_admin
      put admin_timelogs_reported_error_path(employees(:john).id)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(admin_timelogs_reported_errors_path)
    end  
  end

end

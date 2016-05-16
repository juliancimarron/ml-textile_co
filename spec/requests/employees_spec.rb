require 'rails_helper'

RSpec.describe "Employees", type: :request do
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

  it 'GET /show not logged' do
    logout
    get employee_path(reg_employee)
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_employee_session_path)
  end

  context 'GET /show' do 
    it "returns 200 as regular employee" do
      get employee_path(reg_employee)
      expect(response).to have_http_status(:success)
    end

    it "returns 200 as admin employee" do
      login_admin
      get employee_path(admin_employee)
      expect(response).to have_http_status(:success)
    end  
  end

end

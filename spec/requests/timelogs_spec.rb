require 'rails_helper'
require 'support/model_attributes'

RSpec.describe "Timelogs", type: :request do
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

  it 'GET /show not logged' do
    logout
    get timelogs_path
    expect(response).to have_http_status(:found)
    expect(response).to redirect_to(new_employee_session_path)
  end

  context 'GET /index' do 
    it "returns 200 as regular employee" do
      get timelogs_path
      expect(response).to have_http_status(:success)
    end

    it "returns 200 as admin employee" do
      login_admin
      get timelogs_path
      expect(response).to have_http_status(:success)
    end  
  end

  context 'GET /show' do 
    it "returns 200 as regular employee" do
      get timelog_path(reg_employee)
      expect(response).to have_http_status(:success)
    end

    it "returns 200 as admin employee" do
      login_admin
      get timelog_path(admin_employee)
      expect(response).to have_http_status(:success)
    end  
  end

  context 'GET /edit' do 
    it "returns 200 as regular employee" do
      get edit_timelog_path(reg_employee)
      expect(response).to have_http_status(:success)
    end

    it "returns 200 as admin employee" do
      login_admin
      get edit_timelog_path(admin_employee)
      expect(response).to have_http_status(:success)
    end  
  end

  context 'PUT /update' do 
    it "returns 302 as regular employee" do
      put timelog_path(reg_employee), {timelog: timelog_valid_attributes}
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelog_path(reg_employee))
    end

    it "returns 302 as admin employee" do
      login_admin
      put timelog_path(admin_employee), {timelog: timelog_valid_attributes}
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelog_path(admin_employee))
    end  
  end

  context 'PATCH /update' do 
    it "returns 302 as regular employee" do
      patch timelog_path(reg_employee), {timelog: timelog_valid_attributes}
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelog_path(reg_employee))
    end

    it "returns 302 as admin employee" do
      login_admin
      patch timelog_path(admin_employee), {timelog: timelog_valid_attributes}
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(timelog_path(admin_employee))
    end  
  end

end

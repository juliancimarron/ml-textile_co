require 'rails_helper'

RSpec.describe "Employees", type: :request do
  xdescribe "GET /employees/1" do
    it "works! (now write some real specs)" do
      get employee_path()
      expect(response).to have_http_status(200)
    end
  end
end

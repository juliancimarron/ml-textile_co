require 'rails_helper'

RSpec.describe "Timesheets", type: :request do
  describe "GET /timesheets" do
    it "works! (now write some real specs)" do
      get timesheets_path
      expect(response).to have_http_status(200)
    end
  end
end

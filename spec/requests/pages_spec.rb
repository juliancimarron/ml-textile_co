require 'rails_helper'

RSpec.describe "Pages", type: :request do

  xdescribe "GET /root_proxy" do
    it "returns 200 http code" do
      get pages_path
      expect(response).to have_http_status(200)
    end
  end

end

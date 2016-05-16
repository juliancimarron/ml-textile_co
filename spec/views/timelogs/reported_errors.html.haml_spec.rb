require 'rails_helper'

RSpec.describe "timelogs/reported_errors", type: :view do

  fixtures :employees
  fixtures :timelogs

  let(:reg_employee) { employees(:john) }

  before(:each) do
    sign_in reg_employee
    @timelogs = [timelogs(:john)]
  end

  describe 'displays main elements to generate Assistance Reports' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'table th', text: 'Date' }
    specify { expect(render).to have_css 'table td', text: reg_employee.full_name }
  end

end

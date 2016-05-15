require 'rails_helper'
require 'support/shared_context'

RSpec.describe "timelogs/assistance", type: :view do
  include_context 'create_timelogs_timesheets'

  fixtures :departments
  fixtures :employees

  let(:employee) { employees(:john) }

  before(:each) do
    sign_in employee
    create_timelogs(Date.new(2016,3,1), Date.new(2016,5,31), employee)
    @timelogs = Timelog.all
  end

  describe 'displays main elements to generate Assistance Reports' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'form[method="get"]', count: 1 }
    specify { expect(render).to have_css 'form input[type="submit"]', count: 1 }
    specify { expect(render).to have_css 'table > thead > tr > th', text: 'Date' }
    specify { expect(render).to have_css 'table > tbody > tr > td', text: @timelogs.first.employee.full_name }
  end

end

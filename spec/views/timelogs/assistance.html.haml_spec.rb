require 'rails_helper'
require 'support/shared_context'

RSpec.describe "timelogs/assistance", type: :view do
  include_context 'create_timelogs'

  fixtures :departments
  fixtures :employees

  let(:employee) { employees(:john) }

  before(:each) do
    sign_in employee
    create_timelogs(Date.new(2016,3,1), Date.new(2016,5,31), employee)
    @report_q = {type: 'tardies', start_date: '2016-01-01', end_date: '2016-05-31'}
    @timelogs = Timelog.all
  end

  describe 'displays main elements to generate Assistance Reports' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'form[method="get"]', count: 1 }
    specify { expect(render).to have_css 'form input[type="submit"]', count: 1 }
    specify { expect(render).to have_css 'table th', text: 'Date' }
    specify { expect(render).to have_css 'table td', text: @timelogs.first.employee.full_name }
  end

end

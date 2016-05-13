require 'rails_helper'

RSpec.describe "timelogs/show", type: :view do

  fixtures :timelogs
  fixtures :timesheets

  before(:each) do
    @timelog = timelogs(:john)
    @timesheet = timesheets(:john)
  end

  describe 'form to enter claim data' do
    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_text Timesheet.print_timesheet_period(@timesheet) }
    specify { expect(render).to have_text @timelog.arrive_datetime.strftime '%l:%M %p' }
  end

end

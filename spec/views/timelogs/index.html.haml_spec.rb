require 'rails_helper'
require 'support/shared_context'

RSpec.describe "timelogs/index", type: :view do
  include_context 'create_timelogs_timesheets'

  fixtures :employees

  describe "renders the signed in employee's timelogs" do
    let(:month) { 5 }
    let(:year) { 2016 }
    let(:workdays) { month_workdays(year, month) }
    let(:employee) { employees(:john) }

    before(:example) do
      sign_in employee

      create_timelogs(Date.new(2016,3,1), Date.new(2016,5,31), employee)
      create_timesheets(Date.new(2016,3,1), Date.new(2016,5,31), employee)

      @timelogs = Timelog.all
      @timesheets = Timesheet.all
      @timesheet = @timesheets.last
      @timesheet_ids = [1,2,3]
      @proc_timelogs = Timelog.process_timelogs @timesheet, employee
    end

    specify { expect(render).to have_css '.top-bar', count: 1 }
    specify { expect(render).to have_css 'form', count: 1 }
    specify { expect(render).to have_css 'tbody > tr', count: workdays }
    specify { expect(render).to have_css 'th', text: 'Minutes' }
    specify { expect(render).to have_text @timelogs.sample[:leave] }
  end
end

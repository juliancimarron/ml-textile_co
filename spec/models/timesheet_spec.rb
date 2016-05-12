require 'rails_helper'
require 'support/model_attributes'

RSpec.describe Timesheet, type: :model do
  include_context 'model_attributes'

  fixtures :employees

  let(:valid_timesheet) { Timesheet.new timesheet_valid_attributes }

  def timesheet_dates_updated(timesheet) 
    time = Time.now
    timesheet.period_start_date = Date.new(time.year, time.month, 1)
    timesheet.period_end_date = Date.new(time.year, time.month, -1)
    timesheet.pay_date = Date.new(time.year, time.month + 1, 7)
    return timesheet
  end

  describe 'employee_id' do
    context 'valid attributes' do 
      it "is a valid id" do
        timesheet = valid_timesheet
        timesheet.employee_id = Employee.first.employee_id
        expect(timesheet).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is an invalid id" do
        timesheet = valid_timesheet
        timesheet.employee_id = 999
        expect(timesheet).to be_invalid
      end

      it "is blank" do
        timesheet = valid_timesheet
        timesheet.employee_id = ''
        expect(timesheet).to be_invalid
      end
    end
  end

  describe 'period_start_date' do
    context 'invalid attributes' do 
      it "is blank" do
        timesheet = timesheet_dates_updated(valid_timesheet)
        timesheet.period_start_date = nil
        expect(timesheet).to be_invalid
      end
    end
  end

  describe 'period_end_date' do
    context 'invalid attributes' do 
      it "period_end_date < period_start_date" do
        time = Time.now
        timesheet = timesheet_dates_updated(valid_timesheet)
        timesheet.period_end_date = Date.new(time.year, time.month - 1, 15)
        expect(timesheet).to be_invalid
      end

      it "is blank" do
        timesheet = timesheet_dates_updated(valid_timesheet)
        timesheet.period_end_date = nil
        expect(timesheet).to be_invalid
      end
    end
  end

  describe 'logged_hrs' do
    context 'valid atributes' do 
      it "integer >= 0" do
        timesheet = valid_timesheet

        timesheet.logged_hrs = 0
        expect(timesheet).to be_valid

        timesheet.logged_hrs = 100
        expect(timesheet).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "integer < 0" do
        timesheet = valid_timesheet
        timesheet.logged_hrs = -5
        expect(timesheet).to be_invalid
      end
    end
  end

  describe 'logged_min' do
    context 'valid atributes' do 
      it "integer >= 0" do
        timesheet = valid_timesheet

        timesheet.logged_min = 0
        expect(timesheet).to be_valid

        timesheet.logged_min = 100
        expect(timesheet).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "integer < 0" do
        timesheet = valid_timesheet
        timesheet.logged_min = -5
        expect(timesheet).to be_invalid
      end
    end
  end

  describe 'pay_date' do
    context 'valid attributes' do 
      it "is an object that responds to :to_date" do
        timesheet = timesheet_dates_updated(valid_timesheet)
        expect(timesheet).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "pay_date < period_end_date" do
        time = Time.now
        timesheet = timesheet_dates_updated(valid_timesheet)
        timesheet.pay_date = Date.new(time.year, time.month - 1, 15)
        expect(timesheet).to be_invalid
      end
    end
  end

end

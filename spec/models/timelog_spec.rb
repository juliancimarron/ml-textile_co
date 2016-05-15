require 'rails_helper'
require 'support/model_attributes'

RSpec.describe Timelog, type: :model do
  include_context 'model_attributes'

  fixtures :timelogs
  fixtures :employees

  let(:valid_timelog) { Timelog.new timelog_valid_attributes }

  shared_examples 'less_than_sec_in_day' do |field|
    it "the number of seconds entered is beyond 1 day" do
      timelog = valid_timelog
      timelog[field] = 25.hours
      expect(timelog).to be_invalid
    end
  end

  describe 'employee_id' do
    context 'valid attributes' do 
      it "is a valid id" do
        timelog = valid_timelog
        timelog.employee_id = Employee.first.id
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is an invalid id" do
        timelog = valid_timelog
        timelog.employee_id = 999
        expect(timelog).to be_invalid
      end

      it "is blank" do
        timelog = valid_timelog
        timelog.employee_id = ''
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'log_date' do
    context 'valid attributes' do 
      it "is an object that responds to :to_date" do
        timelog = valid_timelog
        timelog.log_date = DateTime.now + 2.days
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        timelog = valid_timelog
        timelog.log_date = ''
        expect(timelog).to be_invalid
      end

      it "cannot create duplicate combinations of employee_id and log_date" do
        a = timelogs(:john).attributes
        timelog = Timelog.new(
          employee_id: a[:employee_id], 
          log_date: a[:log_date], 
          arrive_sec: a[:arrive_sec]
        )
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'arrive_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :arrive_sec
    end
  end

  describe 'leave_sec' do
    context 'valid attributes' do
      it "skips tests if claim_leave_sec has a value" do
        timelog = valid_timelog
        timelog.leave_sec = nil
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      let(:test_timelog) do
        timelog = valid_timelog
        timelog.claim_leave_sec = nil # so these tests can run
        return timelog
      end

      it_behaves_like 'less_than_sec_in_day', :arrive_sec

      it "has leave_sec but arrive_sec = nil, claim_arrive_sec = nil" do
        timelog = test_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = nil
        timelog.leave_sec = 17.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < arrive_sec if claim_arrive_sec = nil" do
        timelog = test_timelog
        timelog.claim_arrive_sec = nil
        timelog.arrive_sec = 8.hours
        timelog.leave_sec = timelog.arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < claim_arrive_sec if arrive_sec = nil" do
        timelog = test_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = 8.hours
        timelog.leave_sec = timelog.claim_arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_sec < claim_arrive_sec if both arrive_sec and claim_arrive_sec" do
        timelog = test_timelog
        timelog.arrive_sec = 9.hours  # this would be valid
        timelog.claim_arrive_sec = 18.hours
        timelog.leave_sec = 17.hours # this is invalid
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'claim_arrive_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :claim_arrive_sec
    end
  end

  describe 'claim_leave_sec' do
    context 'invalid attributes' do 
      it_behaves_like 'less_than_sec_in_day', :arrive_sec

      it "has claim_leave_sec but arrive_sec and claim_arrive_sec are nil" do
        timelog = valid_timelog
        timelog.claim_leave_sec = 18.hours
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = nil        
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < arrive_sec if claim_arrive_sec = nil" do
        timelog = valid_timelog
        timelog.claim_arrive_sec = nil
        timelog.arrive_sec = 8.hours
        timelog.claim_leave_sec = timelog.arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < claim_arrive_sec if arrive_sec = nil" do
        timelog = valid_timelog
        timelog.arrive_sec = nil
        timelog.claim_arrive_sec = 9.hours
        timelog.claim_leave_sec = timelog.claim_arrive_sec - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_sec < claim_arrive_sec if both arrive_sec and claim_arrive_sec" do
        timelog = valid_timelog
        timelog.arrive_sec = 9.hours # this would be valid
        timelog.claim_arrive_sec = 18.hours
        timelog.claim_leave_sec = 17.hours # this is invalid
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'claim_status' do
    context 'valid attributes' do 
      it "receives a valid entry" do
        timelog = valid_timelog
        timelog.claim_status = Timelog::CLAIM_STATUS_OPT.first
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank if there is claim data" do
        timelog = valid_timelog
        timelog.claim_arrive_sec = 9.hours
        timelog.claim_status = nil
        expect(timelog).to be_invalid
      end

      it "receives an invalid options" do
        timelog = valid_timelog
        timelog.claim_status = 'invalid_entry'
        expect(timelog).to be_invalid
      end
    end
  end

  describe '.get_correct_moment' do
      it "returns claim if status = pending" do
        timelog = valid_timelog
        timelog.claim_status = 'pending'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end

      it "returns claim if status = approved" do
        timelog = valid_timelog
        timelog.claim_status = 'approved'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end

      it "returns recorded if status = declined" do
        timelog = valid_timelog
        timelog.claim_status = 'declined'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.arrive_sec
      end

      it "returns recorded if status = nil and claim = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.claim_arrive_sec = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.arrive_sec
      end

      it "returns claim if status = nil and recorded = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.arrive_sec = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_sec
      end
  end

  describe '.timelogs_for_index_view' do
    pending
  end
end

require 'rails_helper'
require 'support/model_attributes'

RSpec.describe Timelog, type: :model do
  include_context 'model_attributes'

  fixtures :timelogs
  fixtures :employees

  let(:valid_timelog) { Timelog.new timelog_valid_attributes }

  shared_examples 'date_eq_to_log_date' do |field|
    it "has a base date different to log_date" do
      timelog = valid_timelog
      timelog[field] = (Time.now + 5.days).to_datetime
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
        timelog.log_date = DateTime.now
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        timelog = valid_timelog
        timelog.log_date = ''
        expect(timelog).to be_invalid
      end

      it "is not an object that responds to :to_date" do
        timelog = valid_timelog
        timelog.log_date = Object.new
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'arrive_datetime' do
    context 'invalid attributes' do 
      it_behaves_like 'date_eq_to_log_date', :arrive_datetime
    end
  end

  describe 'leave_datetime' do
    context 'valid attributes' do
      it "skips tests if claim_leave_datetime has a value" do
        timelog = valid_timelog
        timelog.leave_datetime = nil
        expect(timelog).to be_valid
      end
    end

    context 'invalid attributes' do 
      let(:test_timelog) do
        timelog = valid_timelog
        timelog.claim_leave_datetime = nil # so these tests can run
        return timelog
      end

      it_behaves_like 'date_eq_to_log_date', :arrive_datetime

      it "has leave_datetime but arrive_datetime and claim_arrive_datetime are nil" do
        timelog = test_timelog
        timelog.arrive_datetime = nil
        timelog.claim_arrive_datetime = nil
        timelog.leave_datetime = DateTime.now
        expect(timelog).to be_invalid
      end

      it "rejects leave_datetime < arrive_datetime if claim_arrive_datetime = nil" do
        timelog = test_timelog
        timelog.claim_arrive_datetime = nil
        timelog.arrive_datetime = DateTime.now
        timelog.leave_datetime = timelog.arrive_datetime - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_datetime < claim_arrive_datetime if arrive_datetime = nil" do
        timelog = test_timelog
        timelog.arrive_datetime = nil
        timelog.claim_arrive_datetime = DateTime.now
        timelog.leave_datetime = timelog.claim_arrive_datetime - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects leave_datetime < claim_arrive_datetime if both arrive_datetime and claim_arrive_datetime" do
        dt = DateTime.now
        timelog = test_timelog
        timelog.arrive_datetime = dt - 3.hours # this would be valid
        timelog.claim_arrive_datetime = dt
        timelog.leave_datetime = dt - 2.hours # this is invalid
        expect(timelog).to be_invalid
      end
    end
  end

  describe 'claim_arrive_datetime' do
    context 'invalid attributes' do 
      it_behaves_like 'date_eq_to_log_date', :claim_arrive_datetime
    end
  end

  describe 'claim_leave_datetime' do
    context 'invalid attributes' do 
      it_behaves_like 'date_eq_to_log_date', :arrive_datetime

      it "has claim_leave_datetime but arrive_datetime and claim_arrive_datetime are nil" do
        timelog = valid_timelog
        timelog.claim_leave_datetime = DateTime.now
        timelog.arrive_datetime = nil
        timelog.claim_arrive_datetime = nil        
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_datetime < arrive_datetime if claim_arrive_datetime = nil" do
        timelog = valid_timelog
        timelog.claim_arrive_datetime = nil
        timelog.arrive_datetime = DateTime.now
        timelog.claim_leave_datetime = timelog.arrive_datetime - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_datetime < claim_arrive_datetime if arrive_datetime = nil" do
        timelog = valid_timelog
        timelog.arrive_datetime = nil
        timelog.claim_arrive_datetime = DateTime.now
        timelog.claim_leave_datetime = timelog.claim_arrive_datetime - 3.hours
        expect(timelog).to be_invalid
      end

      it "rejects claim_leave_datetime < claim_arrive_datetime if both arrive_datetime and claim_arrive_datetime" do
        dt = DateTime.now
        timelog = valid_timelog
        timelog.arrive_datetime = dt - 3.hours # this would be valid
        timelog.claim_arrive_datetime = dt
        timelog.claim_leave_datetime = dt - 2.hours # this is invalid
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
        timelog.claim_arrive_datetime = DateTime.now
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
        expect(res).to eq timelog.claim_arrive_datetime
      end

      it "returns claim if status = approved" do
        timelog = valid_timelog
        timelog.claim_status = 'approved'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_datetime
      end

      it "returns claim if status = declined" do
        timelog = valid_timelog
        timelog.claim_status = 'declined'
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_datetime
      end

      it "returns recorded if status = nil and claim = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.claim_arrive_datetime = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.arrive_datetime
      end

      it "returns claim if status = nil and recorded = nil" do
        timelog = valid_timelog
        timelog.claim_status = nil
        timelog.arrive_datetime = nil
        res = Timelog.get_correct_moment(:arrive, timelog)
        expect(res).to eq timelog.claim_arrive_datetime
      end
  end
end

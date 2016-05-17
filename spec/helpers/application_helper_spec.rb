require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do

  let(:time) { '7:45 PM' }
  let(:date) { '01-May-2016' }
  let(:new_dt) { DateTime.parse "#{date} #{time}" }

  describe '#class_by_fullpath' do
    context 'has_more_path = false' do 
      it "returns passed class if request.fullpath = clas_path" do
        klass = 'big_font'
        fullpath = '/valid/path/to/resources'
        path = 'valid/path/to/resources'
        res = class_by_fullpath(klass, fullpath, path, false)
        expect(res).to eq klass
      end

      it "returns nil if request.fullpath only partially matches the given path" do
        klass = 'big_font'
        fullpath = '/valid/path/to/resources'
        path = 'this/is/valid/path'
        res = class_by_fullpath(klass, fullpath, path, false)
        expect(res).to be nil
      end

      it "returns nil if request.fullpath starts with given path" do
        klass = 'big_font'
        fullpath = '/valid/path/to/resources'
        path = 'valid/path/'
        res = class_by_fullpath(klass, fullpath, path, false)
        expect(res).to be nil
      end
    end

    context 'has_more_path = true' do 
      it "returns passed class if request.fullpath = clas_path" do
        klass = 'big_font'
        fullpath = '/valid/path/to/resources'
        path = 'valid/path/to/resources'
        res = class_by_fullpath(klass, fullpath, path, true)
        expect(res).to eq klass
      end

      it "returns passed class if request.fullpath starts with given path" do
        klass = 'big_font'
        fullpath = '/valid/path/to/resources'
        path = 'valid/path/'
        res = class_by_fullpath(klass, fullpath, path, true)
        expect(res).to eq klass
      end
    end
  end

  describe '#strftime_formatter' do
    it "returns formatted string per formatter passed" do
      expect( strftime_formatter('%d-%b-%Y', new_dt).strip ).to eq date
      expect( strftime_formatter('%l:%M %p', new_dt).strip ).to eq time
    end

    it "returns nil if object passed does not respond to :strftime" do
      expect( strftime_formatter('%d-%b-%Y', Object.new) ).to be_nil
    end
  end

  describe '#strftime_as_date' do
    it "returns string formatted as 'ddd, dd/mmm/yyyy' and no-zero-padded" do
      test_date = Date.parse date
      expect( strftime_as_date(new_dt) ).to eq test_date.strftime '%a, %d-%b-%Y'
    end
  end

  describe '#strftime_as_time' do
    it "returns string formatted as 'HH:MM AM' and no-zero-padded" do
      expect( strftime_as_time(new_dt).strip ).to eq time
    end
  end

end

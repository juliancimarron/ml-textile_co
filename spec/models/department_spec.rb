require 'rails_helper'

RSpec.describe Department, type: :model do

  describe 'name' do
    context 'valid attributes' do 
      it "takes a string" do
        d = Department.new name: 'New Department'
        expect(d).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        d = Department.new name: ''
        expect(d).to be_invalid
      end
    end
  end

end

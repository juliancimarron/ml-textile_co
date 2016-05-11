require 'rails_helper'
require 'support/model_attributes'

RSpec.describe Employee, type: :model do
  include_context 'model_attributes'

  fixtures :employees
  fixtures :departments

  let(:valid_employee) { Employee.new employee_valid_attributes }

  describe 'first_name' do
    context 'valid attributes' do 
      it "receives a string" do
        e = valid_employee
        e.first_name = 'John'        
        expect(e).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        e = valid_employee
        e.first_name = ''
        expect(e).to be_invalid
      end
    end
  end

  describe 'last_name' do
    context 'valid attributes' do 
      it "receives a string" do
        e = valid_employee
        e.last_name = 'Smith'        
        expect(e).to be_valid
      end
    end

    context 'invalid attributes' do 
      it "is blank" do
        e = valid_employee
        e.last_name = ''
        expect(e).to be_invalid
      end
    end
  end

  describe 'department_id' do
    context 'valid attributes' do
      it "id is in Department" do
        e = valid_employee
        e.department_id = Department.first.id
        expect(e).to be_valid
      end
    end

    context 'invalid attributes' do
      it "id is not in Department" do
        e = valid_employee
        e.department_id = 999
        expect(e).to be_invalid
      end

      it "is not an integer" do
        e = valid_employee
        e.department_id = 'hola'
        expect(e).to be_invalid
      end
    end
  end

end

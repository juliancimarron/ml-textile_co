require 'rails_helper'

RSpec.xdescribe EmployeesController, type: :controller do

  # This should return the minimal set of attributes required to create a valid
  # Employee. As you add validations to Employee, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # EmployeesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe "GET #index" do
    it "assigns all employees as @employees" do
      employee = Employee.create! valid_attributes
      get :index, {}, valid_session
      expect(assigns(:employees)).to eq([employee])
    end
  end

  describe "GET #show" do
    it "assigns the requested employee as @employee" do
      employee = Employee.create! valid_attributes
      get :show, {:id => employee.to_param}, valid_session
      expect(assigns(:employee)).to eq(employee)
    end
  end

  describe "GET #new" do
    it "assigns a new employee as @employee" do
      get :new, {}, valid_session
      expect(assigns(:employee)).to be_a_new(Employee)
    end
  end

  describe "GET #edit" do
    it "assigns the requested employee as @employee" do
      employee = Employee.create! valid_attributes
      get :edit, {:id => employee.to_param}, valid_session
      expect(assigns(:employee)).to eq(employee)
    end
  end

  describe "POST #create" do
    context "with valid params" do
      it "creates a new Employee" do
        expect {
          post :create, {:employee => valid_attributes}, valid_session
        }.to change(Employee, :count).by(1)
      end

      it "assigns a newly created employee as @employee" do
        post :create, {:employee => valid_attributes}, valid_session
        expect(assigns(:employee)).to be_a(Employee)
        expect(assigns(:employee)).to be_persisted
      end

      it "redirects to the created employee" do
        post :create, {:employee => valid_attributes}, valid_session
        expect(response).to redirect_to(Employee.last)
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved employee as @employee" do
        post :create, {:employee => invalid_attributes}, valid_session
        expect(assigns(:employee)).to be_a_new(Employee)
      end

      it "re-renders the 'new' template" do
        post :create, {:employee => invalid_attributes}, valid_session
        expect(response).to render_template("new")
      end
    end
  end

  describe "PUT #update" do
    context "with valid params" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested employee" do
        employee = Employee.create! valid_attributes
        put :update, {:id => employee.to_param, :employee => new_attributes}, valid_session
        employee.reload
        skip("Add assertions for updated state")
      end

      it "assigns the requested employee as @employee" do
        employee = Employee.create! valid_attributes
        put :update, {:id => employee.to_param, :employee => valid_attributes}, valid_session
        expect(assigns(:employee)).to eq(employee)
      end

      it "redirects to the employee" do
        employee = Employee.create! valid_attributes
        put :update, {:id => employee.to_param, :employee => valid_attributes}, valid_session
        expect(response).to redirect_to(employee)
      end
    end

    context "with invalid params" do
      it "assigns the employee as @employee" do
        employee = Employee.create! valid_attributes
        put :update, {:id => employee.to_param, :employee => invalid_attributes}, valid_session
        expect(assigns(:employee)).to eq(employee)
      end

      it "re-renders the 'edit' template" do
        employee = Employee.create! valid_attributes
        put :update, {:id => employee.to_param, :employee => invalid_attributes}, valid_session
        expect(response).to render_template("edit")
      end
    end
  end

  describe "DELETE #destroy" do
    it "destroys the requested employee" do
      employee = Employee.create! valid_attributes
      expect {
        delete :destroy, {:id => employee.to_param}, valid_session
      }.to change(Employee, :count).by(-1)
    end

    it "redirects to the employees list" do
      employee = Employee.create! valid_attributes
      delete :destroy, {:id => employee.to_param}, valid_session
      expect(response).to redirect_to(employees_url)
    end
  end

end

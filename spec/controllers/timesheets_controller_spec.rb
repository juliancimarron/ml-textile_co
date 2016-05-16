require 'rails_helper'

RSpec.describe TimesheetsController, type: :controller do

  # describe "GET #index" do
  #   it "assigns all timesheets as @timesheets" do
  #     timesheet = Timesheet.create! valid_attributes
  #     get :index, {}, valid_session
  #     expect(assigns(:timesheets)).to eq([timesheet])
  #   end
  # end

  # describe "GET #show" do
  #   it "assigns the requested timesheet as @timesheet" do
  #     timesheet = Timesheet.create! valid_attributes
  #     get :show, {:id => timesheet.to_param}, valid_session
  #     expect(assigns(:timesheet)).to eq(timesheet)
  #   end
  # end

  # describe "GET #new" do
  #   it "assigns a new timesheet as @timesheet" do
  #     get :new, {}, valid_session
  #     expect(assigns(:timesheet)).to be_a_new(Timesheet)
  #   end
  # end

  # describe "GET #edit" do
  #   it "assigns the requested timesheet as @timesheet" do
  #     timesheet = Timesheet.create! valid_attributes
  #     get :edit, {:id => timesheet.to_param}, valid_session
  #     expect(assigns(:timesheet)).to eq(timesheet)
  #   end
  # end

  # describe "POST #create" do
  #   context "with valid params" do
  #     it "creates a new Timesheet" do
  #       expect {
  #         post :create, {:timesheet => valid_attributes}, valid_session
  #       }.to change(Timesheet, :count).by(1)
  #     end

  #     it "assigns a newly created timesheet as @timesheet" do
  #       post :create, {:timesheet => valid_attributes}, valid_session
  #       expect(assigns(:timesheet)).to be_a(Timesheet)
  #       expect(assigns(:timesheet)).to be_persisted
  #     end

  #     it "redirects to the created timesheet" do
  #       post :create, {:timesheet => valid_attributes}, valid_session
  #       expect(response).to redirect_to(Timesheet.last)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns a newly created but unsaved timesheet as @timesheet" do
  #       post :create, {:timesheet => invalid_attributes}, valid_session
  #       expect(assigns(:timesheet)).to be_a_new(Timesheet)
  #     end

  #     it "re-renders the 'new' template" do
  #       post :create, {:timesheet => invalid_attributes}, valid_session
  #       expect(response).to render_template("new")
  #     end
  #   end
  # end

  # describe "PUT #update" do
  #   context "with valid params" do
  #     let(:new_attributes) {
  #       skip("Add a hash of attributes valid for your model")
  #     }

  #     it "updates the requested timesheet" do
  #       timesheet = Timesheet.create! valid_attributes
  #       put :update, {:id => timesheet.to_param, :timesheet => new_attributes}, valid_session
  #       timesheet.reload
  #       skip("Add assertions for updated state")
  #     end

  #     it "assigns the requested timesheet as @timesheet" do
  #       timesheet = Timesheet.create! valid_attributes
  #       put :update, {:id => timesheet.to_param, :timesheet => valid_attributes}, valid_session
  #       expect(assigns(:timesheet)).to eq(timesheet)
  #     end

  #     it "redirects to the timesheet" do
  #       timesheet = Timesheet.create! valid_attributes
  #       put :update, {:id => timesheet.to_param, :timesheet => valid_attributes}, valid_session
  #       expect(response).to redirect_to(timesheet)
  #     end
  #   end

  #   context "with invalid params" do
  #     it "assigns the timesheet as @timesheet" do
  #       timesheet = Timesheet.create! valid_attributes
  #       put :update, {:id => timesheet.to_param, :timesheet => invalid_attributes}, valid_session
  #       expect(assigns(:timesheet)).to eq(timesheet)
  #     end

  #     it "re-renders the 'edit' template" do
  #       timesheet = Timesheet.create! valid_attributes
  #       put :update, {:id => timesheet.to_param, :timesheet => invalid_attributes}, valid_session
  #       expect(response).to render_template("edit")
  #     end
  #   end
  # end

  # describe "DELETE #destroy" do
  #   it "destroys the requested timesheet" do
  #     timesheet = Timesheet.create! valid_attributes
  #     expect {
  #       delete :destroy, {:id => timesheet.to_param}, valid_session
  #     }.to change(Timesheet, :count).by(-1)
  #   end

  #   it "redirects to the timesheets list" do
  #     timesheet = Timesheet.create! valid_attributes
  #     delete :destroy, {:id => timesheet.to_param}, valid_session
  #     expect(response).to redirect_to(timesheets_url)
  #   end
  # end

end

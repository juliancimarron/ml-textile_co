json.array!(@employees) do |employee|
  json.extract! employee, :id, :employee_id, :first_name, :last_name, :department_id, :admin
  json.url employee_url(employee, format: :json)
end

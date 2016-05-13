FactoryGirl.define do

  factory :department do
    name 'Development'
  end

  factory :employee do
    first_name FFaker::Name.first_name
    last_name FFaker::Name.first_name
    association :department
    trait(:admin) { admin true }
  end

end

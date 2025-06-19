FactoryBot.define do
  factory :person do
    first_name { "MyString" }
    last_name { "MyString" }
    middle_name { "MyString" }
    email { "MyString" }
    birth_date { "2025-06-19" }
    bio { "MyText" }
  end
end

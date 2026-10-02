FactoryBot.define do
  factory :governance_type do
    name { "Legislature" }
    description { "A lawmaking institution. The body's jurisdiction supplies the level of government." }
    decision_making_process { "Majority vote of the members" }

    trait :court do
      name { "Court" }
      description { "A judicial institution that hears cases and interprets law." }
      decision_making_process { "Decision by the judges of the court" }
    end

    trait :council do
      name { "Council" }
      description { "A local lawmaking institution, such as a city council." }
      decision_making_process { "Majority vote of the members" }
    end

    trait :board do
      name { "Board" }
      description { "A governing board for a school district or special district." }
      decision_making_process { "Majority vote of the board" }
    end

    trait :executive do
      name { "Executive" }
      description { "The institution headed by an elected executive." }
      decision_making_process { "Decision by the executive" }
    end
  end
end

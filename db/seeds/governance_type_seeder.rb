class GovernanceTypeSeeder
  TYPES = [
    {
      name: "Legislature",
      description: "A lawmaking institution. Congress and a state legislature share this type; the body's jurisdiction supplies the level.",
      decision_making_process: "Majority vote of the members"
    },
    {
      name: "Court",
      description: "A judicial institution that hears cases and interprets law.",
      decision_making_process: "Decision by the judges of the court"
    },
    {
      name: "Council",
      description: "A local lawmaking institution, such as a city council.",
      decision_making_process: "Majority vote of the members"
    },
    {
      name: "Board",
      description: "A governing board for a school district or special district. A board is not a branch of government.",
      decision_making_process: "Majority vote of the board"
    },
    {
      name: "Executive",
      description: "The institution headed by an elected executive, such as a president, governor, or county executive.",
      decision_making_process: "Decision by the executive"
    }
  ].freeze

  def self.seed
    TYPES.each do |attrs|
      governance_type = GovernanceType.find_or_initialize_by(name: attrs[:name])
      governance_type.assign_attributes(attrs)

      if governance_type.save
        print "."
      else
        puts "\n❌ Failed to create governance type: #{attrs[:name]}"
        puts "   Errors: #{governance_type.errors.full_messages.join(', ')}"
      end
    end

    puts " #{GovernanceType.count} governance types"
  end
end

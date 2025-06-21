class GovernanceTypeSeeder
  def self.seed
    governance_types = [
      {
        name: "Municipal Legislature",
        description: "Local governing body responsible for city ordinances, budgets, and municipal policy. Typically includes city councils, town councils, and similar bodies.",
        authority_level: "local",
        decision_making_process: "Majority vote of elected council members"
      },
      {
        name: "County Executive",
        description: "County-level executive authority responsible for implementing county policies and managing day-to-day county operations.",
        authority_level: "regional",
        decision_making_process: "Single executive decision-maker"
      },
      {
        name: "County Legislature",
        description: "County-level legislative body responsible for county ordinances, budgets, and regional policy coordination.",
        authority_level: "regional", 
        decision_making_process: "Majority vote of elected commissioners or supervisors"
      },
      {
        name: "State Legislature",
        description: "State-level legislative body responsible for state laws, budgets, and statewide policy. Includes state houses and senates.",
        authority_level: "state",
        decision_making_process: "Bicameral majority vote (typically House and Senate)"
      },
      {
        name: "State Executive",
        description: "State-level executive authority including governors and their administration, responsible for implementing state policy.",
        authority_level: "state",
        decision_making_process: "Executive decision-making with legislative oversight"
      },
      {
        name: "School Board",
        description: "Educational governance body responsible for local school district policies, budgets, and educational standards.",
        authority_level: "local",
        decision_making_process: "Majority vote of elected or appointed board members"
      },
      {
        name: "Special District Board",
        description: "Specialized local governance for specific services like water districts, fire districts, or transit authorities.",
        authority_level: "local",
        decision_making_process: "Board majority vote with specialized expertise requirements"
      },
      {
        name: "Federal Legislature",
        description: "National legislative body responsible for federal laws, budgets, and national policy. Includes Congress, Parliament, etc.",
        authority_level: "federal",
        decision_making_process: "Bicameral majority vote with presidential/prime ministerial involvement"
      },
      {
        name: "Federal Executive",
        description: "National executive authority including presidents, prime ministers, and their administrations.",
        authority_level: "federal", 
        decision_making_process: "Executive decision-making with legislative and judicial oversight"
      }
    ]
    
    governance_types.each do |gt_attrs|
      governance_type = GovernanceType.find_or_create_by(name: gt_attrs[:name]) do |gt|
        gt.description = gt_attrs[:description]
        gt.authority_level = gt_attrs[:authority_level]
        gt.decision_making_process = gt_attrs[:decision_making_process]
      end
      
      if governance_type.persisted?
        print "."
      else
        puts "\n❌ Failed to create governance type: #{gt_attrs[:name]}"
        puts "   Errors: #{governance_type.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{GovernanceType.count} governance types"
  end
end
class TopicSeeder
  def self.seed
    topics = [
      {
        title: "Education",
        description: "Educational systems, policies, and programs that ensure quality learning opportunities, equitable access, and academic achievement for students at all levels from early childhood through higher education."
      },
      {
        title: "Healthcare",
        description: "Public health initiatives, healthcare access, medical services delivery, health insurance policies, disease prevention, and health emergency preparedness that promote community wellness and medical equity."
      },
      {
        title: "Housing & Development",
        description: "Housing policies, affordable housing programs, zoning regulations, urban planning, homelessness services, and community development initiatives that ensure adequate shelter and sustainable growth."
      },
      {
        title: "Transportation",
        description: "Transportation infrastructure, public transit systems, traffic management, pedestrian and bicycle safety, and mobility planning that enables efficient movement of people and goods throughout the community."
      },
      {
        title: "Environment & Sustainability",
        description: "Environmental protection, climate action, conservation programs, pollution control, renewable energy, waste management, and sustainability initiatives that preserve ecosystem health for future generations."
      },
      {
        title: "Public Safety",
        description: "Law enforcement, emergency services, fire protection, crime prevention, disaster preparedness, and community safety programs that protect residents and maintain public order."
      },
      {
        title: "Economic Development",
        description: "Business growth strategies, workforce development, entrepreneurship support, tourism promotion, and economic policies that foster local prosperity, job creation, and financial stability."
      },
      {
        title: "Social Services",
        description: "Welfare programs, disability services, senior care, child protective services, mental health support, and community assistance programs that provide safety nets for vulnerable populations."
      },
      {
        title: "Infrastructure & Technology",
        description: "Public works, utilities, digital infrastructure, cybersecurity, broadband access, government technology services, and infrastructure maintenance that supports modern community functionality."
      },
      {
        title: "Arts, Culture & Recreation",
        description: "Cultural programs, arts funding, historic preservation, recreational facilities, community events, libraries, museums, and cultural initiatives that enrich community life and preserve heritage."
      }
    ]
    
    topics.each do |topic_attrs|
      topic = Topic.find_or_create_by(title: topic_attrs[:title]) do |t|
        t.description = topic_attrs[:description]
      end
      
      if topic.persisted?
        print "."
      else
        puts "\n❌ Failed to create topic: #{topic_attrs[:title]}"
        puts "   Errors: #{topic.errors.full_messages.join(', ')}"
      end
    end
    
    puts " #{Topic.count} topics"
  end
end
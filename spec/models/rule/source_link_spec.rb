require "rails_helper"

RSpec.describe Rule::SourceLink, type: :model do
  subject(:source_link) { build(:rule_source_link) }

  it { is_expected.to belong_to(:linkable) }
  it { is_expected.to validate_presence_of(:lu_unit_id) }
end

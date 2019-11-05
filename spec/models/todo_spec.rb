require 'rails_helper'

RSpec.describe Todo, type: :model do
  it { should have_many(:tasks) }
  it { should belong_to(:user) }

  describe '#title' do
    it { should validate_presence_of(:title) }
  end
end

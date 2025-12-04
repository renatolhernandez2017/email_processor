require 'rails_helper'

RSpec.describe ProcessingLog, type: :model do
  describe "associations" do
    it { should belong_to(:email_file) }
  end
end

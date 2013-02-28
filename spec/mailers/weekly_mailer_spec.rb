require "spec_helper"

describe WeeklyMailer do
  describe "Create Issue" do
    it "creates issue" do
      city = FactoryGirl.create(:city)
      test = WeeklyMailer.issueCreator( city )

    end
  end
end

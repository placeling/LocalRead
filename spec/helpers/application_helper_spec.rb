require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the HomeHelper. For example:
#
# describe HomeHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe ApplicationHelper do
  it "shortens a url after resovling it" do
    short_url = "http://wp.me/p2TGqc-8lP"

    url = ApplicationHelper.short_url( short_url )

    puts url

  end
end

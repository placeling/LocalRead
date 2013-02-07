ab_test "Prompt Options" do
  description "Do we get better results if we always tell people they can unsubscribe anytime?"
  alternatives "", "One-click unsubscribe any time"
  metrics :registration
end
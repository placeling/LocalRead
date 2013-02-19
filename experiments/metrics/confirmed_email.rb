metric "Confirmed Email" do
  description "How many total users with confirmed emails are in the system"

  def values(from, to)
    vals = []
    (from..to).map do |i|
      vals << Subscriber.where(:confirmed_at.lte => i).count
    end

    return vals
  end
end

class ConfirmSteven < Mongoid::Migration
  def self.up
    steven = Subscriber.where({'email'=>'steven.forth@gmail.com'}).first()
    
    if !steven.nil?
      if steven.confirmed_at.nil?
        puts "Not confirmed"
        steven.confirm!
      else
        puts "Already confirmed"
      end
    else
      puts "Couldn't find Steven's email address"
    end
  end

  def self.down

  end
end
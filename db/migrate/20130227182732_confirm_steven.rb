class ConfirmSteven < Mongoid::Migration
  def self.up
    steven = Subscriber.where('email'=>'steven.forth@gmail.com').first()
    steven.confirm!
    steven.save
  end

  def self.down

  end
end
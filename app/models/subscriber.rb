class Subscriber
  include Mongoid::Document
  include Mongoid::Timestamps

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :registerable, :database_authenticatable, :confirmable, :async

  ## Database authenticatable
  field :email,              :type => String, :default => ""
  field :encrypted_password, :type => String, :default => ""

  ## Recoverable

  ## Confirmable
  field :confirmation_token,   :type => String
  field :confirmed_at,         :type => Time
  field :confirmation_sent_at, :type => Time
  field :unconfirmed_email,    :type => String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, :type => Integer, :default => 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    :type => String # Only if unlock strategy is :email or :both
  # field :locked_at,       :type => Time

  ## Token authenticatable
  # field :authentication_token, :type => String

  field :location, :type => Array #meant to be home location, used at signup?
  field :place_json,    :type => String
  field :unsubscribed, :type => Boolean, :default => false

  field :ck, :type => String

  before_validation :dummy_password
  validates_presence_of :location, :message => "need to be selected from list"

  before_save :add_cryptokey

  index({ ck: 1 })
  index({ location: "2d" }, { min: -200, max: 200 })

  def city
    "Vancouver"
  end

  def add_cryptokey
    self.ck = SecureRandom.hex(30)
  end

  def self.find_by_crypto_key(key)
    self.where(:ck => key).first
  end

  def self.ck
    if self[:ck].nil?
      self[:ck] = SecureRandom.hex(30)
    end

    return self[:ck]
  end

  def dummy_password
    self.password = "dummypassword"
  end

  def email_required?
    false
  end

  def weekly_email?
    self.confirmed? && !self.unsubscribed
  end
end

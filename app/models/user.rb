class User < ApplicationRecord
  attr_accessor :remember_token

  before_save { email.downcase! }

  validates :name, presence: true, length: {maximum: 50}
  validates :email, presence: true, length: {maximum: 255},
                    format: {with: URI::MailTo::EMAIL_REGEXP},
                    uniqueness: {case_sensitive: false}
  has_secure_password
  validates :password, presence: true, length: {minimum: 6}, allow_nil: true

  has_many :todos, dependent: :destroy

  class << self
    # Returns the hash digest of the given strign
    def digest(str)
      Digest::SHA1.hexdigest(str)
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def authenticated?(type, token)
    digest = send("#{type}_digest")
    return false unless digest
    self.class.digest(token) == digest
  end

  private

    def remember
      self.remember_token = self.class.new_token
      update_attribute(:remember_digest, self.class.digest(remember_token))
    end

    def forget
      update_attribute(:remember_digest, nil)
    end
end

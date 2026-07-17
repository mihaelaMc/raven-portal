class RefreshToken < ApplicationRecord
  belongs_to :user

  EXPIRATION = 7.days

  def self.issue_for(user)
    raw_token = SecureRandom.hex(32)
    refresh_token = user.refresh_tokens.create!(digest: digest(raw_token), expires_at: EXPIRATION.from_now)
    [ refresh_token, raw_token ]
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token)
  end

  def self.authenticate(raw_token)
    find_by(digest: digest(raw_token))&.then { |token| token if token.active? }
  end

  def active?
    revoked_at.nil? && expires_at.future?
  end

  def revoke!
    update!(revoked_at: Time.current)
  end
end

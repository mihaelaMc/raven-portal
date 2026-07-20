class User < ApplicationRecord
  ALLOWED_AVATAR_TYPES = %w[ image/png image/jpeg image/webp ].freeze
  MAX_AVATAR_SIZE = 5.megabytes

  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :refresh_tokens, dependent: :destroy
  has_one_attached :avatar

  enum :role, { user: 0, admin: 1 }, default: :user

  validates :crawler_name, presence: true
  validate :avatar_valid

  def as_json(options = {})
    super(options.merge(only: %i[ id email crawler_name role created_at ])).merge(
      "avatar_url" => avatar_url
    )
  end

  def avatar_url
    return nil unless avatar.attached?

    Rails.application.routes.url_helpers.rails_blob_url(avatar, only_path: true)
  end

  private

  def avatar_valid
    return unless avatar.attached?

    unless avatar.content_type.in?(ALLOWED_AVATAR_TYPES)
      errors.add(:avatar, "must be a PNG, JPEG, or WEBP image")
    end

    if avatar.byte_size > MAX_AVATAR_SIZE
      errors.add(:avatar, "must be smaller than 5MB")
    end
  end
end

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  has_many :refresh_tokens, dependent: :destroy

  enum :role, { user: 0, admin: 1 }, default: :user

  validates :crawler_name, presence: true

  def as_json(options = {})
    super(options.merge(only: %i[ id email crawler_name role created_at ]))
  end
end

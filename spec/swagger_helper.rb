# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  # Root folder where the generated OpenAPI file lands; Rswag::Api serves from
  # the same folder (config/initializers/rswag_api.rb).
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "Raven Portal API",
        version: "v1",
        description: "JSON API for the Raven Portal dungeon-crawler gameshow. " \
                     "Authenticate via /login or /signup, then send the returned JWT " \
                     "as `Authorization: Bearer <token>`. Access tokens expire after " \
                     "30 minutes; exchange the refresh token at /refresh for a new one."
      },
      paths: {},
      servers: [
        { url: "http://localhost:3000", description: "Development" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: "JWT"
          }
        },
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              email: { type: :string, format: :email },
              crawler_name: { type: :string },
              role: { type: :string, enum: %w[user admin] },
              notify_security_alerts: { type: :boolean },
              created_at: { type: :string, format: "date-time" },
              avatar_url: { type: :string, nullable: true, description: "Path relative to the API origin, null when no avatar is attached" }
            },
            required: %w[id email crawler_name role]
          },
          pagination_meta: {
            type: :object,
            properties: {
              current_page: { type: :integer },
              total_pages: { type: :integer },
              total_count: { type: :integer }
            },
            required: %w[current_page total_pages total_count]
          },
          audit_log: {
            type: :object,
            properties: {
              id: { type: :integer },
              actor_id: { type: :integer, description: "User who performed the action (no FK - survives user deletion)" },
              subject_id: { type: :integer, description: "User the action was performed on" },
              action: { type: :string, enum: AuditLog::ACTIONS },
              metadata: { type: :object, additionalProperties: true },
              ip_address: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id actor_id subject_id action]
          },
          error: {
            type: :object,
            properties: { error: { type: :string } },
            required: %w[error]
          },
          errors: {
            type: :object,
            properties: { errors: { type: :array, items: { type: :string } } },
            required: %w[errors]
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

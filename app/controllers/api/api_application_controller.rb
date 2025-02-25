# frozen_string_literal: true

module Api
  class ApiApplicationController < ActionController::Base
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

    skip_before_action :verify_authenticity_token
    before_action :ensure_json_request

    def ensure_json_request
      if !request.headers["Accept"].match?(/vnd\.api\+json/)
        render body: nil, status: 406
      else
        unless request.get?
          return if /vnd\.api\+json/.match?(request.headers["Content-Type"])

          render body: nil, status: 415
        end
      end
    end

    protected

    def record_not_found
      head :not_found
    end
  end
end

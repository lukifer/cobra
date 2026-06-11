# frozen_string_literal: true

module Api
  module V1
    module Public
      # Base controller for NRDB API Resources.
      class PublicApiController < ActionController::API
        include Graphiti::Rails::Responders

        rescue_from Exception do |e|
          case e
          when ActiveRecord::RecordNotFound, Graphiti::Errors::RecordNotFound
            render_record_not_found(e)
          when ActiveRecord::RecordInvalid
            render_record_invalid(e)
          when Graphiti::Errors::RequiredFilter
            render_required_filter(e)
          when ActionController::ParameterMissing
            render_parameter_missing(e)
          else
            render_internal_server_error(e)
          end
        end

        def show_detailed_exceptions?
          false
        end

        def add_total_stat(params)
          params['stats'] = {} unless params.include?('stats')
          params['stats']['total'] = 'count'
        end

        def current_user
          @current_user ||= load_current_user
        end

        def user_signed_in?
          !!current_user
        end

        def load_current_user
          id = session[:user_id]
          return nil unless id

          User.find_by(id:)
        end

        private

        def render_record_not_found(_exception)
          render json: {
            errors: [
              {
                status: '404',
                title: 'Graphiti::Errors::RecordNotFound',
                detail: 'Specified Record Not Found'
              }
            ]
          }, status: :not_found
        end

        def render_record_invalid(exception)
          render json: {
            errors: [
              {
                status: '422',
                title: 'ActiveRecord::RecordInvalid',
                detail: exception.message
              }
            ]
          }, status: :unprocessable_content
        end

        def render_required_filter(exception)
          render json: {
            errors: [
              {
                status: '422',
                title: 'Invalid request',
                detail: exception.message
              }
            ]
          }, status: :unprocessable_content
        end

        def render_parameter_missing(exception)
          render json: {
            errors: [
              {
                status: '400',
                title: 'ActionController::ParameterMissing',
                detail: exception.message
              }
            ]
          }, status: :bad_request
        end

        def render_internal_server_error(_exception)
          render json: {
            errors: [
              {
                status: '500',
                title: 'Internal Server Error',
                detail: 'The error has been logged so our team can investigate.'
              }
            ]
          }, status: :internal_server_error
        end
      end
    end
  end
end

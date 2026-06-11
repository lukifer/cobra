# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Exception Handling' do
  before do
    original_env_config = Rails.application.method(:env_config)
    allow(Rails.application).to receive(:env_config) do
      original_env_config.call.merge(
        'action_dispatch.show_exceptions' => :all,
        'action_dispatch.show_detailed_exceptions' => false,
        'consider_all_requests_local' => false
      )
    end
  end

  describe 'GET /api/v1/public/tournaments/:id' do
    context 'when the record does not exist' do
      it 'returns a valid JSON API error response' do
        get '/api/v1/public/tournaments/999999'

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(%r{application/(json|vnd\.api\+json)})

        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(json).to have_key('errors')
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first['status']).to eq('404')
        expect(json['errors'].first['title']).to eq('Graphiti::Errors::RecordNotFound')
        expect(json['errors'].first['detail']).to eq('Specified Record Not Found')
      end
    end
  end

  describe 'GET /api/v1/public/tournaments' do
    context 'when a standard error occurs' do
      before do
        allow(TournamentResource).to receive(:all).and_raise(StandardError.new('Something went wrong'))
      end

      it 'returns a 500 JSON API error response' do
        get '/api/v1/public/tournaments'

        expect(response).to have_http_status(:internal_server_error)
        expect(response.content_type).to match(%r{application/(json|vnd\.api\+json)})

        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(json).to have_key('errors')
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first['status']).to eq('500')
        expect(json['errors'].first['title']).to eq('Internal Server Error')
        expect(json['errors'].first['detail']).to eq('The error has been logged so our team can investigate.')
      end
    end

    context 'when a record invalid exception occurs' do
      before do
        # We need a model with errors to construct ActiveRecord::RecordInvalid
        user = User.new
        user.errors.add(:name, 'cannot be blank')
        invalid_err = ActiveRecord::RecordInvalid.new(user)
        allow(TournamentResource).to receive(:all).and_raise(invalid_err)
      end

      it 'returns a 422 JSON API error response' do
        get '/api/v1/public/tournaments'

        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(response).to have_http_status(:unprocessable_content)
        expect(json['errors'].first['status']).to eq('422')
        expect(json['errors'].first['title']).to eq('ActiveRecord::RecordInvalid')
        expect(json['errors'].first['detail']).to include('Validation failed')
      end
    end

    context 'when parameter is missing' do
      before do
        allow(TournamentResource).to receive(:all).and_raise(ActionController::ParameterMissing.new(:some_param))
      end

      it 'returns a 400 JSON API error response' do
        get '/api/v1/public/tournaments'

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(json['errors'].first['status']).to eq('400')
        expect(json['errors'].first['title']).to eq('ActionController::ParameterMissing')
        expect(json['errors'].first['detail']).to include('some_param')
      end
    end
  end
end

# frozen_string_literal: true

module Api
  module V1
    module Public
      # Controller for the Format resource.
      class FormatsController < PublicApiController
        def index
          add_total_stat(params)
          formats = FormatResource.all(params)
          respond_with(formats)
        end

        def show
          format = FormatResource.find(params)
          respond_with(format)
        end
      end
    end
  end
end

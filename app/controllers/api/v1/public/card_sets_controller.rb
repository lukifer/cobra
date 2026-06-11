# frozen_string_literal: true

module Api
  module V1
    module Public
      # Controller for the CardSet resource.
      class CardSetsController < PublicApiController
        def index
          add_total_stat(params)
          card_sets = CardSetResource.all(params)
          respond_with(card_sets)
        end

        def show
          card_set = CardSetResource.find(params)
          respond_with(card_set)
        end
      end
    end
  end
end

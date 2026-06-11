# frozen_string_literal: true

module Api
  module V1
    module Public
      # Controller for the DeckbuildingRestriction resource.
      class DeckbuildingRestrictionsController < PublicApiController
        def index
          add_total_stat(params)
          deckbuilding_restrictions = DeckbuildingRestrictionResource.all(params)
          respond_with(deckbuilding_restrictions)
        end

        def show
          deckbuilding_restriction = DeckbuildingRestrictionResource.find(params)
          respond_with(deckbuilding_restriction)
        end
      end
    end
  end
end

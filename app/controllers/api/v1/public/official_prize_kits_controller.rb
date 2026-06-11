# frozen_string_literal: true

module Api
  module V1
    module Public
      # Controller for the OfficialPrizeKit resource.
      class OfficialPrizeKitsController < PublicApiController
        def index
          add_total_stat(params)
          official_prize_kits = OfficialPrizeKitResource.all(params)
          respond_with(official_prize_kits)
        end

        def show
          official_prize_kit = OfficialPrizeKitResource.find(params)
          respond_with(official_prize_kit)
        end
      end
    end
  end
end

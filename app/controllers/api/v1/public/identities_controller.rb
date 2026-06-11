# frozen_string_literal: true

module Api
  module V1
    module Public
      # Controller for the Identity resource.
      class IdentitiesController < PublicApiController
        def index
          add_total_stat(params)
          base_scope = Identity.deduplicated
          identities = IdentityResource.all(params, base_scope)
          respond_with(identities)
        end

        def show
          identity = IdentityResource.find(params)
          respond_with(identity)
        end
      end
    end
  end
end

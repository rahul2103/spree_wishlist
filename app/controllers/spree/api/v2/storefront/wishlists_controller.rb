module Spree
  module Api
    module V2
      module Storefront
        class WishlistsController < ::Spree::Api::V2::BaseController
          include Spree::Api::V2::CollectionOptionsHelpers

          def index
            wishlists = spree_current_user.wishlists.page(params[:page]).per(params[:per_page])
            render_serialized_payload { serialize_collection(wishlists) }
          end

          def create
            spree_authorize! :create, Spree::Wishlist
            wishlist = Spree::Wishlist.new( wishlist_attributes )
            wishlist.user = spree_current_user
            wishlist.save

            if wishlist.persisted?
              render_serialized_payload { serialize_resource(wishlist) }
            else
              render_error_payload(wishlist.errors.full_messages.join(', '))
            end
          end

          def show
            render_serialized_payload { serialize_resource(resource) }
          end

          def update
            authorize! :update, resource
            resource.update wishlist_attributes

            if resource.errors.empty?
              render_serialized_payload { serialize_resource(resource) }
            else
              render_error_payload(resource.errors.full_messages.join(', '))
            end
          end

          def destroy
            authorize! :destroy, resource
            resource.destroy
            render_serialized_payload { serialize_resource(resource) }
          end

          private

          def wishlist_attributes
            params.require(:wishlist).permit(:name, :is_default, :is_private)
          end

          def resource
            @resource ||= Spree::Wishlist.find_by_access_hash(params[:id])
          end

          def resource_serializer
            ::Spree::V2::Storefront::WishlistSerializer
          end

          def collection_serializer
            ::Spree::V2::Storefront::WishlistSerializer
          end
        end
      end
    end
  end
end
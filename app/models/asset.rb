class Asset < ApplicationRecord
  belongs_to :asset_provision, optional: true
end

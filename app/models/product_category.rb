class ProductCategory < ApplicationRecord
    validates :name, presence: true;
    validates :identifier, uniqueness: true, presence: true;
    validates :description, presence: true;
end

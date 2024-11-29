# frozen_string_literal: true

class RentalVehicle < ApplicationRecord
  belongs_to :rental
  belongs_to :vehicle_detail
end
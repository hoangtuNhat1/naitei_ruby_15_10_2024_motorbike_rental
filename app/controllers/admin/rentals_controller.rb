class Admin::RentalsController < ApplicationController
  include Pagy::Backend
  before_action :authorize_admin
  before_action :set_rental, only: %i[show approve reject rent return]

  def index
    @rentals = Rental.filter_by(params).order(created_at: :desc)

    @pagy, @rentals = pagy(@rentals)
  end

  def show
    @rental_vehicles = @rental.rental_vehicles.includes(:vehicle_detail)
    @vehicle_details = @rental_vehicles.map(&:vehicle_detail)
  end

  def approve
    if @rental.pending?
      @rental.update(status: :approved)
      redirect_to admin_rental_path(@rental), notice: t("views.rentals.update_status.success")
    else
      redirect_to admin_rental_path(@rental), alert: t("views.rentals.update_status.failed")
    end
  end

  def reject
    if @rental.pending? && params[:decline_reason].present?
      @rental.update(status: :rejected, decline_reason: params[:decline_reason])
      redirect_to admin_rental_path(@rental), notice: t("views.rentals.update_status.success")
    else
      redirect_to admin_rental_path(@rental), alert: t("views.rentals.update_status.failed")
    end
  end

  def rent
    if @rental.approved?
      @rental.update(status: :renting)
      redirect_to admin_rental_path(@rental), notice: t("views.rentals.update_status.success")
    else
      redirect_to admin_rental_path(@rental), alert: t("views.rentals.update_status.failed")
    end
  end

  def return
    if @rental.renting?
      now = Time.current
      rate = @rental.total_price / calculate_rental_duration(@rental.start_datetime, @rental.end_datetime)
      duration = calculate_rental_duration(@rental.start_datetime, now)
      real_price = duration * rate
      @rental.update(return_datetime: Time.current)
      @rental.update(total_price: real_price)
      @rental.update(status: :returned)
      redirect_to admin_rental_path(@rental), notice: t("views.rentals.update_status.success")
    else
      redirect_to admin_rental_path(@rental), alert: t("views.rentals.update_status.failed")
    end
  end

  private

  def set_rental
    @rental = Rental.find_by(id: params[:id])
    return unless @rental.nil?

    flash[:error] = t("controller.rentals.not_found")
    redirect_to admin_rentals_path
  end

  def authorize_admin
    return if current_user.admin?

    flash[:error] = t("controller.rentals.unauthorized")
    redirect_to root_path
  end
end

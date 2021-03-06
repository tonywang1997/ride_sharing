class VehiclesController < ApplicationController
  before_action :set_vehicle, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:edit]
  # GET /vehicles
  # GET /vehicles.json
  def index
    @vehicles = Vehicle.all
  end

  # GET /vehicles/1
  # GET /vehicles/1.json
  def show
    @user = User.find(current_user.id)
  end

  # GET /vehicles/new
  def new
    @user = User.find(current_user.id)
    @vehicle = Vehicle.new
  end

  # GET /vehicles/1/edit
  def edit
    @user = User.find(current_user.id)
  end

  # POST /vehicles
  # POST /vehicles.json
  def create
    @vehicle = Vehicle.new(vehicle_params)
    @vehicle.user_id = current_user.id

    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to user_vehicle_path(current_user.id, @vehicle), notice: 'Vehicle was successfully created.' }
        format.json { render :show, status: :created, location: @vehicle }
      else
        format.html { render :new }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /vehicles/1
  # PATCH/PUT /vehicles/1.json
  def update
    respond_to do |format|
      if @vehicle.update(vehicle_params)
        format.html { redirect_to user_vehicle_path(current_user.id, @vehicle), notice: 'Vehicle was successfully updated.' }
        format.json { render :show, status: :ok, location: @vehicle }
      else
        format.html { render :edit }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /vehicles/1
  # DELETE /vehicles/1.json
  def destroy
    @vehicle.destroy
    respond_to do |format|
      format.html { redirect_to vehicles_url, notice: 'Vehicle was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def vehicle_params
      params.require(:vehicle).permit(:license_number, :vehicle_make, :vehicle_model, :vehicle_color, :vehicle_plate)
    end
end

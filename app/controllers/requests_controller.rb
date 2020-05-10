require './app/lib/matcher'

class RequestsController < ApplicationController
  respond_to :js
  # before_action :authorized, only: [:show]
  before_action :set_request, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:show]

  # GET /requests
  # GET /requests.json
  def index
    @requests = Request.unmatched
  end

  def search
    if params[:search]
      puts "start searching"
      @requests = Request.unmatched.search(params[:search])
      if @requests.nil?
        flash.now[:alert] = "Could not find an availability"
      else
        @requests = @requests.page(params[:page])
      end
      respond_to do |format|
        format.js
        format.html
      end
    else
      @requests = Request.unmatched.page(params[:page])
    end
  end

  # GET /requests/1
  # GET /requests/1.json
  def show
    user_id = Make.find_user_id_by_request_id(params[:id])
    rider = nil
    if !user_id.nil?
      rider = User.find_by(id: user_id)
      render 'show', :locals => { :rider => rider } 
    end
  end

  def requestModal
    respond_to do |format|
      format.html
      format.js
    end
  end

  def match
    @request = Request.find(params[:id])
    # @availability.matched_user_id = current_user.id
    # @availability.matched_request_id = -10
    # @availability.availability_status = "waiting"
    if @request.save
      respond_to do |format|
        format.html
        format.js
      end
    else
      flash.now["danger"] = "Request not made"
    end
    # if @availability.save
    #   # render javascript: go to result patial driver id
    #   render 'confirm.html'
    # else
    #   flash.now["danger"] = "Request not made"
    # end
  end

  # GET /requests/new
  def new
    @user = User.find(current_user.id)
    @request = Request.new
  end

  # GET /requests/1/edit
  def edit
  end

  # POST /requests
  # POST /requests.json
  def create
    @request = Request.new(request_params)
    @user = User.find(current_user.id)
    respond_to do |format|
      if @request.save
        user = User.find(current_user.id)
        make = Make.create!(user_id: current_user.id, request_id: @request.id)
        user.makes << make
        @request.makes << make
        @make_id = make.id

        format.html { redirect_to @request, notice: 'Request was successfully created.' }
        format.json { render :show, status: :created, location: @request }
        # matched_id = match
        # format.html { redirect_to @request, :status => 200, notice: 'Request was successfully created.' }
        # format.json { render :show, status: :created, location: @request }
      else
        format.html { render :new }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /requests/1
  # PATCH/PUT /requests/1.json
  def update
    respond_to do |format|
      if @request.update(request_params)
        format.html { redirect_to @request, notice: 'Request was successfully updated.' }
        format.json { render :show, status: :ok, location: @request }
      else
        format.html { render :edit }
        format.json { render json: @request.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /requests/1
  # DELETE /requests/1.json
  def destroy
    @request.destroy
    respond_to do |format|
      format.html { redirect_to requests_url, notice: 'Request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_request
      @request = Request.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def request_params
      params.require(:request).permit(:start_city, :start_street_address, :start_zip, :end_city, :end_street_address, :end_zip, :trip_time, :distance, :highest_price_to_pay, :matched_availability_id, :request_status)
    end

    def match
      unmatched_availabilities = Availability.unmatched.to_a.map(&:serializable_hash)
      matcher = Matcher.new
      matcher.add_item_to_match(@request.id, @request.start_lat, @request.start_lon, @request.end_lat, @request.end_lon, @request.trip_time, @request.highest_price_to_pay)
      matcher.find_all_availabilities(unmatched_availabilities)
      matched_id = matcher.find_best_match
      if !matched_id.nil?
        modify_request(matched_id)
        modify_availability(matched_id)
      end
      return matched_id
    end

    def modify_request matched_id
      @request.matched_availability_id = matched_id
      @request.request_status = "waiting"
      @request.save
    end

    def modify_availability matched_id
      availability = Availability.find(matched_id)
      availability.matched_request_id = @request.id
      availability.availability_status = "waiting"
      availability.save
    end
end

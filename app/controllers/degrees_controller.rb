class DegreesController < ApplicationController
  before_action :set_degree, only: %i[ show edit update destroy ]
  before_action :set_school, only: [:create]

  # GET /degrees or /degrees.json
  def index
    @degrees = Degree.all
  end

  # GET /degrees/1 or /degrees/1.json
  def show
  end

  # GET /degrees/new
  def new
    @degree = Degree.new
  end

  # GET /degrees/1/edit
  def edit
  end

  # POST /degrees or /degrees.json
  def create
    @degree = @school.degrees.build(degree_params)

    respond_to do |format|
      if @degree.save
        format.html { redirect_to degree_url(@degree), notice: "Degree was successfully created." }
        format.json { render :show, status: :created, location: @degree }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @degree.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /degrees/1 or /degrees/1.json
  def update
    respond_to do |format|
      if @degree.update(degree_params)
        format.html { redirect_to degree_url(@degree), notice: "Degree was successfully updated." }
        format.json { render :show, status: :ok, location: @degree }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /degrees/1 or /degrees/1.json
  def destroy
    @degree.destroy!

    respond_to do |format|
      format.html { redirect_to degrees_url, notice: "Degree was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_degree
      @degree = Degree.find(params[:id])
    end

    def set_school
      @school = School.find(params[:school_id])
    end

    # Only allow a list of trusted parameters through.
    def degree_params
      params.require(:degree).permit(:name, :school_id)
    end
end

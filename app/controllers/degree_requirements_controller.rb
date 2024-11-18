class DegreeRequirementsController < ApplicationController
  before_action :set_degree_requirement, only: %i[ show edit update destroy ]

  # GET /degree_requirements or /degree_requirements.json
  def index
    @degree_requirements = DegreeRequirement.all
  end

  # GET /degree_requirements/1 or /degree_requirements/1.json
  def show
  end

  # GET /degree_requirements/new
  def new
    @degree_requirement = DegreeRequirement.new
  end

  # GET /degree_requirements/1/edit
  def edit
  end

  # POST /degree_requirements or /degree_requirements.json
  def create
    @degree_requirement = DegreeRequirement.new(degree_requirement_params)

    respond_to do |format|
      if @degree_requirement.save
        format.html { redirect_to degree_requirement_url(@degree_requirement), notice: "Degree requirement was successfully created." }
        format.json { render :show, status: :created, location: @degree_requirement }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @degree_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /degree_requirements/1 or /degree_requirements/1.json
  def update
    respond_to do |format|
      if @degree_requirement.update(degree_requirement_params)
        format.html { redirect_to degree_requirement_url(@degree_requirement), notice: "Degree requirement was successfully updated." }
        format.json { render :show, status: :ok, location: @degree_requirement }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @degree_requirement.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /degree_requirements/1 or /degree_requirements/1.json
  def destroy
    @degree_requirement.destroy!

    respond_to do |format|
      format.html { redirect_to degree_requirements_url, notice: "Degree requirement was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_degree_requirement
      @degree_requirement = DegreeRequirement.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def degree_requirement_params
      params.require(:degree_requirement).permit(:name, :credit_hour_amount, :degree_id)
    end
end

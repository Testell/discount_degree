class DegreesController < ApplicationController
  before_action { authorize(@degree || Degree) }
  before_action :set_degree, only: %i[show edit update destroy]
  before_action :set_school, only: [:create]

  def index
    @degrees = Degree.all
  end

  def show
    @plans = @degree.plans.order(created_at: :desc)
  end

  def new
    @degree = Degree.new
  end

  def edit
  end

  def create
    @degree = @school.degrees.build(degree_params)

    respond_to do |format|
      if @degree.save
        format.html do
          redirect_to school_path(@school, section: "degrees"),
                      notice: "Degree was successfully created."
        end
        format.json { render :show, status: :created, location: @degree }
      else
        format.html do
          redirect_to school_path(@school, section: "degrees"), status: :unprocessable_entity
        end
        format.json { render json: @degree.errors, status: :unprocessable_entity }
      end
    end
  end

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

  def destroy
    @degree.destroy!

    respond_to do |format|
      format.html { redirect_to degrees_url, notice: "Degree was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_degree
    @degree = Degree.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
  end

  def degree_params
    params.require(:degree).permit(:name, :school_id)
  end
end

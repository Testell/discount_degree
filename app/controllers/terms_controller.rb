class TermsController < ApplicationController
  before_action { authorize(@term || Term) }
  before_action :set_term, only: %i[show edit update destroy]
  before_action :set_school, only: %i[index new create]

  # GET /schools/:school_id/terms
  def index
    @terms = @school.terms
  end

  # GET /terms/1
  def show
  end

  # GET /schools/:school_id/terms/new
  def new
    @term = @school.terms.build
  end

  # GET /terms/1/edit
  def edit
  end

  # POST /schools/:school_id/terms
  def create
    @term = @school.terms.build(term_params)

    respond_to do |format|
      if @term.save
        format.html { redirect_to school_path(@school, section: 'terms'), notice: 'Term was successfully created.' }
        format.json { render :show, status: :created, location: @term }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @term.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  # PATCH/PUT /terms/1
  def update
    respond_to do |format|
      if @term.update(term_params)
        format.html { redirect_to school_path(@term.school, section: 'terms'), notice: 'Term was successfully updated.' }
        format.json { render :show, status: :ok, location: @term }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @term.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /terms/1
  def destroy
    @term.destroy
    respond_to do |format|
      format.html { redirect_to school_path(@term.school, section: 'terms'), notice: 'Term was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_term
    @term = Term.find(params[:id])
  end

  def set_school
    @school = School.find(params[:school_id])
  end

  # Only allow a list of trusted parameters through.
  def term_params
    params.require(:term).permit(:name, :credit_hour_minimum, :credit_hour_maximum, :tuition_cost)
  end
end

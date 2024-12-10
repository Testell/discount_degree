class TermsController < ApplicationController
  before_action { authorize(@term || Term) }
  before_action :set_term, only: %i[show edit update destroy]
  before_action :set_school, only: %i[index new create]

  def index
    @terms = @school.terms
  end

  def show
  end

  def new
    @term = @school.terms.build
  end

  def edit
  end

  def create
    @term = @school.terms.build(term_params)

    respond_to do |format|
      if @term.save
        format.html do
          redirect_to school_path(@school, section: "terms"),
                      notice: "Term was successfully created."
        end
        format.json { render :show, status: :created, location: @term }
        format.js
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @term.errors, status: :unprocessable_entity }
        format.js
      end
    end
  end

  def update
    respond_to do |format|
      if @term.update(term_params)
        format.html do
          redirect_to school_path(@term.school, section: "terms"),
                      notice: "Term was successfully updated."
        end
        format.json { render :show, status: :ok, location: @term }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @term.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @term.destroy
    respond_to do |format|
      format.html do
        redirect_to school_path(@term.school, section: "terms"),
                    notice: "Term was successfully destroyed."
      end
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

  def term_params
    params.require(:term).permit(:name, :credit_hour_minimum, :credit_hour_maximum, :tuition_cost)
  end
end

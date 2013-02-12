class NursesController < ApplicationController
  # GET /nurses
  # GET /nurses.json
  def index
    @nurses = Nurse.asc(:last_name)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @nurses }
    end
  end

  # GET /nurses/1
  # GET /nurses/1.json
  def show
    @nurse = Nurse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @nurse }
    end
  end

  # GET /nurses/new
  # GET /nurses/new.json
  def new
    @nurse = Nurse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @nurse }
    end
  end

  # GET /nurses/1/edit
  def edit
    @nurse = Nurse.find(params[:id])
  end

  # POST /nurses
  # POST /nurses.json
  def create
    @nurse = Nurse.new(params[:nurse])

    respond_to do |format|
      if @nurse.save
        format.html { redirect_to @nurse, notice: 'Nurse was successfully created.' }
        format.json { render json: @nurse, status: :created, location: @nurse }
      else
        format.html { render action: "new" }
        format.json { render json: @nurse.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /nurses/1
  # PUT /nurses/1.json
  def update
    @nurse = Nurse.find(params[:id])

    respond_to do |format|
      if @nurse.update_attributes(params[:nurse])
        format.html { redirect_to @nurse, notice: 'Nurse was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @nurse.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /nurses/1
  # DELETE /nurses/1.json
  def destroy
    @nurse = Nurse.find(params[:id])
    @nurse.destroy

    respond_to do |format|
      format.html { redirect_to nurses_url }
      format.json { head :no_content }
    end
  end

  def add_procedure
    @nurse = Nurse.find(params[:id])
    @completed_proc = CompletedProc.new
    @completed_proc.procedure = Procedure.new

  end
  
  def save_procedure
    @nurse = Nurse.find(params[:id])
    @completed_proc = CompletedProc.new(params[:completed_proc])

    respond_to do |format|      
     if @completed_proc.save && @nurse.completed_procs << @completed_proc
       format.html { redirect_to add_procedure_nurse_path(@nurse), 
        notice: "Procedure '#{@completed_proc.procedure.name}' submitted for validation." }
       format.json { render json: @nurse, status: :updated, location: @nurse }
     else
      format.html { render action: "add_procedure" }
      format.json { render json: @completed_proc.errors, status: :unprocessable_entity }
    end
  end
end

  def options
    @proc = Procedure.find_by(name: params[:proc])
    respond_to do |format|
      format.js
      format.json { render json: @proc.options }
    end
  end

  def pending_validations
    @nurse = Nurse.find(params[:id])
  end

  def validate_procs
   @nurse = Nurse.find(params[:id])
   params[:nurse][:proc_ids].each do |id, value|
    cproc = CompletedProc.find id
    cproc.validated = true
    cproc.save
   end
   redirect_to nurses_url, notice: "procedures validated"
  end
end
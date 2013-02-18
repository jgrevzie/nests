class CompletedProcsController < ApplicationController



  respond_to :html, :xml, except: :options
  respond_to :js

  # GET /completed_procs
  # GET /completed_procs.json
  def index
    respond_with( @completed_procs = CompletedProc.asc(:date_start) )
  end

  # GET /completed_procs/1
  # GET /completed_procs/1.json
  def show
    respond_with( @completed_proc = CompletedProc.find(params[:id]) )
  end

  # GET /completed_procs/new
  # GET /completed_procs/new.json
  def new
    @nurse = Nurse.logged_in_nurse
    @completed_proc = CompletedProc.new 
    respond_with @completed_proc
  end

  # GET /completed_procs/1/edit
  def edit
    respond_with( @completed_proc = CompletedProc.find(params[:id]) )
  end

  # POST /completed_procs
  # POST /completed_procs.json
  def create
    @nurse = Nurse.logged_in_nurse
    @completed_proc = CompletedProc.new(params[:completed_proc])
    if @completed_proc.save && @nurse.completed_procs << @completed_proc
      flash[:notice] = 'Submitted procedure for validation.' 
    end

    respond_with @completed_proc, location: new_completed_proc_path
  end

  # PUT /completed_procs/1
  # PUT /completed_procs/1.json
  def update
    @completed_proc = CompletedProc.find params[:id]
    flash[:notice] = 'Procedure was successfully updated.' \
      if @completed_proc.update_attributes(params[:completed_proc])
    respond_with @completed_proc
  end

  # DELETE /completed_procs/1
  # DELETE /completed_procs/1.json
  def destroy
    @nurse = Nurse.find(params[:id])
    @nurse.destroy
    respond_with @nurse
  end

  def add_procedure
    @nurse = Nurse.find(params[:id])
    @completed_proc = CompletedProc.new
    @completed_proc.procedure = Procedure.new
  end

  def options
    @proc = Procedure.find_by(name: params[:proc])
    respond_with @proc.options
  end
end

class CompletedProcsController < ApplicationController



  before_filter :is_nurse_allowed_here
  skip_before_filter :is_nurse_allowed_here, only: [:index, :new, :options, :create]

  respond_to :html, :xml
  respond_to :js

  def is_nurse_allowed_here
    cp = CompletedProc.find(params[:id])
    # only validators can look at other nurse's procs
    forbid unless logged_in_nurse.validator? or cp.nurse.id==logged_in_nurse.id
  end

  # GET /completed_procs
  # GET /completed_procs.json
  def index
    @nurse = logged_in_nurse
    respond_with( @completed_procs = CompletedProc.asc.and( 
      { nurse: @nurse}, 
      { status: 'pending' } 
    ))
  end

  # GET /completed_procs/1
  # GET /completed_procs/1.json
  def show
    respond_with( @completed_proc = CompletedProc.find(params[:id]) )
  end

  # GET /completed_procs/new
  # GET /completed_procs/new.json
  def new
    @nurse = logged_in_nurse
    @completed_proc = CompletedProc.new 
    @completed_proc.proc = Procedure.new
    respond_with @completed_proc
  end

  # GET /completed_procs/1/edit
  def edit
    @nurse = logged_in_nurse
    @completed_proc = CompletedProc.find(params[:id])
    # regular nurses cannot edit procs that have been validated (there's no gui for it)
    if !@nurse.validator? && @completed_proc.vdated?
      forbid
    else 
      respond_with @completed_proc
    end
  end

  def setup_date_validation(cp)
    # Validators can put in any date they please, regular nurses are constrained.
    cp.check_date = true unless logged_in_nurse.validator?
  end

  # POST /completed_procs
  # POST /completed_procs.json
  def create
    @nurse = logged_in_nurse
    @completed_proc = CompletedProc.new params[:completed_proc]
    setup_date_validation @completed_proc

    # strong_params protects against nurse hackers making completed procs
    if @completed_proc.save(completed_proc_params) && @nurse.completed_procs << @completed_proc
      flash[:notice] = 'Submitted procedure for validation.' 
    end

    respond_with @completed_proc, location: new_completed_proc_path
  end

  # PUT /completed_procs/1
  # PUT /completed_procs/1.json
  def update
    @nurse = logged_in_nurse
    @completed_proc = CompletedProc.find params[:id]

    # A regular nurse may not alter an existing, validated proc
    (forbid ; return) if !@nurse.validator? && @completed_proc.vdated?

    # Is nurse acking a reject?
    # Or is nurse a vn validating or rejecting a proc?
    # Or is nurse legally updating a proc prior to validation?

    ack = params[:commit]=="Acknowledge"
    status = params[:completed_proc][:status]
    if ack
      @completed_proc.ack_reject 
    elsif @nurse.validator? && [CP::VALID, CP::REJECTED].include?(status)
      @completed_proc.set_status status, @nurse
    end
     
    setup_date_validation @completed_proc
                    
    # prevent sneaky nurse hackers from PUTting validated procs (status is protected attribute)
    flash[:notice] = 'Updated proc' if @completed_proc.update_attributes(completed_proc_params)

    if ack
      next_page = home_nurse_path logged_in_nurse
    elsif logged_in_nurse.validator?
      next_page = pending_validations_nurse_path(logged_in_nurse)
    else
      next_page = new_completed_proc_path
    end

    respond_with @completed_proc, location: next_page
  end

  # DELETE /completed_procs/1
  # DELETE /completed_procs/1.json
  def destroy
    @nurse = Nurse.find(params[:id])
    @nurse.destroy
    respond_with @nurse
  end

  def options
    proc = Procedure.where(name: params[:proc]).first
    render partial: 'options', locals: { options: (proc ? proc.options : '')}
  end

  def completed_proc_params
    params.require(:completed_proc)
      .permit(:quantity, :proc, :role, :comments, :date, :quantity, :options, :emergency)
  end
end





class NursesController < ApplicationController

  protect_from_forgery with: :null_session, 
                       :if => Proc.new { |c| c.request.format == 'application/json' }
  before_filter :is_nurse_allowed_here
  skip_before_filter :is_nurse_allowed_here, only: []
  skip_before_filter :verify_authenticity_token, :only => [:send_mail]

  respond_to :html, :xml, :js

  def is_nurse_allowed_here
    forbid unless logged_in_nurse.validator? or params[:id]==logged_in_nurse.id.to_s
  end

  # GET /nurses
  # GET /nurses.json
  def index
    respond_with( @nurses = Nurse.asc(:last_name) )
  end

  # GET /nurses/1
  # GET /nurses/1.json
  def show
    # send user to home page
    respond_with @nurse=Nurse.find(params[:id])
  end

  # GET /nurses/new
  # GET /nurses/new.json
  def new
    respond_with( @nurse = Nurse.new )
  end

  # GET /nurses/1/edit
  def edit
    respond_with( @nurse = Nurse.find(params[:id]) )
  end

  # POST /nurses
  # POST /nurses.json
  def create
    @nurse = Nurse.new(nurse_params)
    flash[:notice] = 'Created Nurse.' if @nurse.save
    respond_with @nurse
  end

  # PUT /nurses/1
  # PUT /nurses/1.json
  def update
    @nurse = Nurse.find(params[:id])
    flash[:notice] = 'Updated Nurse.' if @nurse.update_attributes(nurse_params)
    respond_with @nurse, location: home_nurse_path(@nurse)
  end

  # DELETE /nurses/1
  # DELETE /nurses/1.json
  def destroy
    @nurse = Nurse.find(params[:id])
    @nurse.destroy
    respond_with @nurse
  end

  def send_mail
    @nurse = Nurse.find(params[:id])
    DailyValidations.pending_validations_mail(@nurse).deliver
    redirect_to request.referer
  end
  
  def home
    @nurse = Nurse.find(params[:id]) 
    respond_with @nurse
  end

  def pending_validations
    @nurse = Nurse.find(params[:id]) 
    respond_with @nurse   
  end

  def validate_procs
    @nurse = Nurse.find(params[:id])
    @nurse.validate_by_id params[:proc_ids].keys if params[:proc_ids]
    redirect_to pending_validations_nurse_path(@nurse), notice: "procedures validated"
  end

  def mugshot
    @nurse = Nurse.find params[:id]
    File.open("#{Rails.root}/app/assets/images/nurse.jpeg") {|f| @nurse.mugshot=f} \
      unless @nurse.mugshot
    send_data @nurse.mugshot, type:'image', disposition:'inline'
  end

  def nurse_params
    params.require(:nurse)
      .permit(:name, :comments, :designation, :email, :wants_mail, :mugshot, :dept_id)
  end
end

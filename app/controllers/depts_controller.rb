




class DeptsController < ApplicationController
  respond_to :html, :xml, :js
  # GET /depts
  # GET /depts.json
  def index
    respond_with (@depts = Dept.all)
  end

  # GET /depts/1
  # GET /depts/1.json
  def show
    respond_with (@dept = Dept.find(params[:id]))
  end

  # GET /depts/new
  # GET /depts/new.json
  def new
    respond_with @dept=Dept.new, @nurse=logged_in_nurse
  end

  # GET /depts/1/edit
  def edit
    respond_with @dept = Dept.find(params[:id])
  end

  # POST /depts
  # POST /depts.json
  def create
    @dept = Dept.new params[:dept]

    flash[:notice] = 'Created Dept' if @dept.save
    respond_with @dept
  end

  def upload_submit
    if params[:dept]
      @dept = DeptSpreadsheet.load_dept params[:dept][:spreadsheet].tempfile
      if @dept.save
        flash[:notice] = 'Created Dept' 
        respond_with @dept
      else
        render action: 'upload'
      end
    else
      (@dept = Dept.new).errors[:base] << 'Choose a valid file name.'
      render action: :upload
    end      
  end

  # PUT /depts/1
  # PUT /depts/1.json
  def update
    @dept = Dept.find params[:id]
    flash[:notice] = 'Updated Dept' if @dept.update_attributes(params[:dept])
    respond_with @dept
  end

  # DELETE /depts/1
  # DELETE /depts/1.json
  def destroy
    @dept = Dept.find(params[:id])
    @dept.destroy
    respond_with @dept
  end

  def upload
    respond_with @dept = Dept.new
  end
end

class ReportsController < ApplicationController
  before_action :set_report, only: %i[ show edit update destroy ]
  before_action :ensure_user, only: %i[ edit update destroy ]

  # GET /reports or /reports.json
  def index
    @reports = Report.all
  end

  # GET /reports/1 or /reports/1.json
  def show
  end

  # GET /reports/new
  def new
    @report = Report.new
  end

  # GET /reports/1/edit
  def edit
  end

  # POST /reports or /reports.json
  def create
    @report = current_user.reports.build(report_params)

      if @report.save
        redirect_to report_url(@report), notice: "Report was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
  end

  # PATCH/PUT /reports/1 or /reports/1.json
  def update
    
      if @report.update(report_params)
        redirect_to report_url(@report), notice: "Report was successfully updated." 
      else
        render :edit, status: :unprocessable_entity 
      end
  end

  # DELETE /reports/1 or /reports/1.json
  def destroy
    @report.destroy

    redirect_to reports_url, notice: "Report was successfully destroyed." 
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def report_params
      params.require(:report).permit(:title, :content)
    end

    def ensure_user
      @current_user_reports = current_user.reports
      @target_report = @current_user_reports.find_by(id: params[:id])
      redirect_to report_path(params[:id]), alert: 'You can only edit your own reports.' unless @target_report
    end
end

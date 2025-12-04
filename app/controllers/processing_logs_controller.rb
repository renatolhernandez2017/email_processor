class ProcessingLogsController < ApplicationController
  include Pagy::Backend

  def index
    @pagy, @processing_logs = pagy(ProcessingLog.order(created_at: :desc))
  end

  def show
    @processing_log = ProcessingLog.find(params[:id])
    @email_file = @processing_log.email_file
  end
end

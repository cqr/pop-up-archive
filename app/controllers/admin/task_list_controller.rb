class Admin::TaskListController < Admin::BaseController
  authorize_resource decent_exposure: true
  def index
   @report = Admin::TaskList.new.pending_tasks
  end
end

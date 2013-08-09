class Admin::Reports::PendingTasksController <  Admin::BaseController
  def index
    unless current_user.has_role? :super_admin
      redirect_to ('/')
    end
    @report = []
    tasks = Task.includes(:owner).all

    tasks.each  do |task|
        line  =  Hash.new
        line[:id] = task.id
         line[:type] = task.type

         unless task.owner == nil
           line[:owner_type] = task.owner.class.name
           line[:owner_id] = task.owner_id
           extra = task.owner.class.joins(item: [collection: [collection_grants: :user]]).find(task.owner_id)
           line[:user_email] = extra.collection.collection_grants.first.user.email
           line[:user_id] = extra.collection.collection_grants.first.user.id
           line[:collection_title] = extra.collection.title
           line[:collection_id] = extra.collection.id
           line[:item_id] = extra.item.id
           line[:item_title] =  extra.item.title
         end

       line[:created_at] = task.created_at
       line[:updated_at] = task.updated_at
       line[:status] = task.status
       @report << line
    end

  end
end

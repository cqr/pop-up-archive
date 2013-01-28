class Directory::ItemsController < Directory::BaseController
  expose(:items)
  expose(:item)

  def create
    respond_to do |format|
      if item.save
        format.html { redirect_to item, notice: 'Item was successfully created.' }
        format.json { render json: item, status: :created, location: item }
      else
        format.html { render action: "new" }
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if item.update_attributes(params[:item])
        format.html { redirect_to item, notice: 'Item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: item.errors, status: :unprocessable_entity }
      end
    end
  end
end

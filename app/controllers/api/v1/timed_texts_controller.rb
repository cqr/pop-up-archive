class Api::V1::TimedTextsController < Api::V1::BaseController
  expose(:timed_text)

  def update
    timed_text.save
    respond_with :api, timed_text
  end

end

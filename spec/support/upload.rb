module Upload
  extend ActionDispatch::TestProcess

  def self.file(name, type)
    fixture_file_upload(Rails.root.join('spec','factories', 'files', name), type)
  end
end
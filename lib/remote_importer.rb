require 'net/ftp'

class RemoteImporter
  attr_accessor :collection, :url, :folder, :user,:password, :first_item, :last_item, :count

  def initialize(options={})
    self.first_item = Integer(options[:first_item]) if options.has_key?(:first_item)
    self.last_item = Integer(options[:last_item]) if options.has_key?(:last_item)
    self.folder = options[:folder] if options.has_key?(:folder)
    self.user = options[:user] if options.has_key?(:user)
    self.password = options[:password] if options.has_key?(:password)
    self.collection = Collection.find(options[:collection_id])
    self.folder = nil if self.folder == "nothing"
    self.count = 0
    if options.has_key?(:url)
      self.url = options[:url]
    else
      raise 'url is mandatory'
    end
  end

  def get_ftp_folder
    hash_items = {}
    ftp = Net::FTP.new()
    ftp.connect(self.url, 21)
    ftp.passive = true
    ftp.login(self.user, self.password)
    unless folder == nil
      self.folder = URI.decode(self.folder)
      ftp.chdir(self.folder+"/")
    end

    self.count = 0
    recursive_listing(ftp, self.folder)

    ftp.close
  end

  def is_ftp_file?(ftp, file_name)
    ftp.chdir(file_name)
    ftp.chdir('..')
    false
  rescue
    true
  end

  def recursive_listing(ftp, folder, hash_items)
    #changing to the specific folder
    puts "moving to " + folder
    ftp.chdir(folder+"/")
    list_of_files = ftp.nlst()
    list_of_files.each do |file_name|
      if file_name == ".." or file_name == "."
        next
      end
      if self.is_ftp_file?(ftp, file_name)
        if Utils.is_audio_file?(URI.encode(file_name))
          next unless Utils.is_audio_file?(URI.encode(file_name))
          file_url ="ftp://#{self.user}:#{self.password}@#{self.url}"+URI.encode(folder+"/"+file_name)
          self.count += 1
          next if self.count < self.first_item
          break if self.count > self.last_item
          puts file_url
          
          if Item.where(identifier: file_name[0,5], collection_id: self.collection.id).exists?
            ##retrieve item
            item = Item.where(identifier: file_name[0,5], collection_id: self.collection.id)[0] ##not sure about the brackets -- only want to return one item
            ##we need to check if the audio file is already there iterate over audio files in item to check for file_name
            audio = AudioFile.new
            instance.audio_files << audio
            item.audio_files << audio
            audio.identifier = file_url
            audio.remote_file_url = file_url
            item.save!
            ##need to check to make sure we can save files to items (we know we can save new items, but what about updating them?)
          else
            item = Item.new
            item.collection = self.collection
            item.title = file_name
            item.identifier = file_name[0,5]
            instance = item.instances.build
            instance.digital = true
            audio = AudioFile.new
            instance.audio_files << audio
            item.audio_files << audio
            audio.identifier = file_url
            audio.remote_file_url = file_url
            item.save!
          end
        end
      else
        recursive_listing(ftp, folder+"/"+file_name)
      end
    end
    ftp.chdir("..")
  end


end

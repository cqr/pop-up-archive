require 'net/ftp'

class RemoteImporter
  attr_accessor :collection, :url, :folder, :user,:password, :first_item, :last_item

  def initialize(options={})



    self.first_item = Integer(options[:first_item]) if options.has_key?(:first_item)
    self.last_item = Integer(options[:last_item]) if options.has_key?(:last_item)
    self.folder = options[:folder] if options.has_key?(:folder)
    self.user = options[:user] if options.has_key?(:user)
    self.password = options[:password] if options.has_key?(:password)
    self.collection = Collection.find(options[:collection_id])
    self.folder.gsub!('_',' ')
    self.folder = URI.escape(folder)
    self.folder = nil if self.folder == "nothing"

    if options.has_key?(:url)
      self.url = options[:url]
    else
      raise 'url is mandatory'
    end
  end

  def get_ftp_folder
    ftp = Net::FTP.new()
    ftp.connect(self.url, 21)
    ftp.passive = true
    ftp.login(self.user, self.password)
    unless folder == nil
      ftp.chdir(self.folder+"/")
    end
    list_of_files = ftp.nlst("*")
    puts "list out files in root directory:"
    count = 0
    list_of_files.each do |file|
      ext = (file[-3,3] || "").downcase
      next unless ['aac', 'aif', 'aiff', 'alac', 'flac', 'm4a', 'm4p', 'mp2', 'mp3', 'mp4', 'ogg', 'raw', 'spx', 'wav', 'wma'].include?(ext)
      if folder == nil
        file_url ="ftp://#{self.user}:#{self.password}@#{self.url}/"+URI.encode(file)
      else
        #file_url ="ftp://#{self.user}:#{self.password}@#{self.url}/"+URI.encode(""+folder +"/"+file)
        self.folder.slice! "kswebsite/"
        file_url ="http://#{self.url}/"+URI.encode(folder+"/"+file)
      end

      #file_url = URI.encode_www_form_component(file_url)
      puts file_url
      count += 1
      next if count < self.first_item
      break if count > self.last_item
      item = Item.new
      item.collection        = self.collection
      item.title             = file
      instance = item.instances.build
      instance.digital    = true
      audio = AudioFile.new
      instance.audio_files << audio
      item.audio_files << audio
      audio.identifier        = file_url
      audio.remote_file_url   = file_url
      item.save!
    end
    ftp.close
  end


end
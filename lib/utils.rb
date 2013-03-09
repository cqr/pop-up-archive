require 'excon'

class Utils
	class<<self

		def http_download_file(url, retry_count=10)
      while(!result && (retry_count < retry_max)) do
        connection = Excon.new(url)
        response = connection.request(params)
        if response.status.to_s.start_with?('2')
          result = response.body
        else
          sleep(1)
          retry_count += 1
        end
      end

      if result.length <= 0
        raise "Zero length file from: #{url}"
      end

      result
		end

    def download_private_file(connection, uri, retry_count=10)
      bucket = uri.host
      key = uri.path[1..-1]
      file_name = key.split("/").last

      directory = connection.directories.get(bucket)

      try_count = 0
      file_exists = false
      while !file_exists && try_count < retry_count
        # puts "s3_download_file: try: #{try_count}, checking for #{key} in #{bucket}"
        try_count += 1
        file_exists = directory.files.head(key)

        if !file_exists
          sleep(1)
        end
      end

      if !file_exists
        raise "File not found on s3: #{bucket}: #{key}"
      end

      s3_file = directory.files.get(key)
      result = s3_file.body

      if result.length <= 0
        raise "Zero length file from: #{uri}"
      end

      result
    end

  end
end

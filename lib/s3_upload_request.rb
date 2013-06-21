class S3UploadRequest

  require 'base64'
  require 'digest'

  attr_accessor :date, :upload_id, :key, :chunk, :mime_type,
    :bucket, :signature

  def initialize(data)
    params          = data[:params]
    type            = data[:type]
    @bucket         = data[:bucket]
    @secret         = data[:secret]
    @date           = Time.now.strftime("%a, %d %b %Y %X %Z")
    @upload_id      = params[:upload_id]
    @key            = params[:key]
    @chunk          = params[:chunk]
    @mime_type      = params[:mime_type] || params[:content_type] || 'application/octet-stream'

    if type == :init
      @signature = upload_init_signature
    elsif type == :part
      @signature = upload_part_signature
    elsif type == :complete
      @signature = upload_complete_signature
    elsif type == :list
      @signature = upload_list_signature
    elsif type == :delete
      @signature = upload_delete_signature
    else
      @signature = nil
    end
  end

  def to_h
    {
      :date      => @date,
      :bucket    => @bucket,
      :upload_id => @upload_id,
      :chunk     => @chunk,
      :mime_type => @mime_type,
      :signature => @signature
    }
  end

  private

  def upload_init_signature
    encode("POST\n\n\n\nx-amz-acl:public-read\nx-amz-date:#{@date}\n/#{@bucket}/#{@key}?uploads")
  end

  def upload_part_signature
    encode("PUT\n\n#{@mime_type}\n\nx-amz-date:#{@date}\n/#{@bucket}/#{@key}?partNumber=#{@chunk}&uploadId=#{@upload_id}")
  end

  def upload_complete_signature
    encode("POST\n\n#{@mime_type}\n\nx-amz-date:#{@date}\n/#{@bucket}/#{@key}?uploadId=#{@upload_id}")
  end

  def upload_list_signature
    encode("GET\n\n\n\nx-amz-date:#{@date}\n/#{@bucket}/#{@key}?uploadId=#{@upload_id}")
  end

  def upload_delete_signature
    encode("DELETE\n\n\n\nx-amz-date:#{@date}\n/#{@bucket}/#{@key}?uploadId=#{@upload_id}")
  end

  def encode(data)
    Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', @secret, data))
  end

#   # thanks fog!
#   def signature(params, expires)
#     headers = params[:headers] || {}

#     string_to_sign =
# <<-DATA
# #{params[:method].to_s.upcase}
# #{headers['Content-MD5']}
# #{headers['Content-Type']}
# #{expires}
# DATA

#     amz_headers, canonical_amz_headers = {}, ''
#     for key, value in headers
#       if key[0..5] == 'x-amz-'
#         amz_headers[key] = value
#       end
#     end
#     amz_headers = amz_headers.sort {|x, y| x[0] <=> y[0]}
#     for key, value in amz_headers
#       canonical_amz_headers << "#{key}:#{value}\n"
#     end
#     string_to_sign << canonical_amz_headers


#     query_string = ''
#     if params[:query]
#       query_args = []
#       for key in params[:query].keys.sort
#         if VALID_QUERY_KEYS.include?(key)
#           value = params[:query][key]
#           if value
#             query_args << "#{key}=#{Fog::AWS.escape(value.to_s)}"
#           else
#             query_args << key
#           end
#         end
#       end
#       if query_args.any?
#         query_string = '?' + query_args.join('&')
#       end
#     end

#     canonical_path = (params[:path] || object_to_path(params[:object_name])).to_s
#     canonical_path = '/' + canonical_path if canonical_path[0..0] != '/'
#     if params[:bucket_name]
#       canonical_resource = "/#{params[:bucket_name]}#{canonical_path}"
#     else
#       canonical_resource = canonical_path
#     end
#     canonical_resource << query_string
#     string_to_sign << canonical_resource

#     signed_string = OpenSSL::HMAC.digest('sha1', @secret, string_to_sign)
#     Base64.encode64(signed_string).chomp!
#   end

end

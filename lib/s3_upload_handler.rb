module S3UploadHandler

  def bucket
    raise NotImplementedError.new "please implement a bucket method"
  end

  def secret
    raise NotImplementedError.new "please implement a secret method"
  end

  def chunk_loaded
    # Not implemented yet.
    render json: {}
  end

  def init_signature
    render json: signature_hash(:init)
  end

  def chunk_signature
    render json: signature_hash(:part)
  end

  def end_signature
    render json: signature_hash(:complete)
  end

  def list_signature
    render json: signature_hash(:list)
  end

  def delete_signature
    render json: signature_hash(:delete)
  end

  def all_signatures
    render json: all_signatures_hash
  end

  protected

  def signature_hash(t)
    S3UploadRequest.new(type: t, params: params, bucket: bucket, secret: secret).to_h
  end

  def all_signatures_hash
    list     = S3UploadRequest.new(type: :list, params: params, bucket: bucket, secret: secret)
    complete = S3UploadRequest.new(type: :complete, params: params, bucket: bucket, secret: secret)

    chunk_signatures = {}
    params[:num_chunks].to_i.times do |chunk|
      chunk_number = chunk + 1
      params[:chunk] = chunk_number
      request = S3UploadRequest.new(type: :part, params: params, bucket: bucket, secret: secret)
      chunk_signatures[chunk_number] = [request.signature, request.date]
    end

    hash = {
      list_signature:   [list.signature, list.date],
      end_signature:    [complete.signature, complete.date],
      chunk_signatures: chunk_signatures
    }
  end

end

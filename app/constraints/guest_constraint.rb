class GuestConstraint < Struct.new(:value)
  def matches?(request)
    return (request.session.key?('warden.user.user.key') != value)
  end
end

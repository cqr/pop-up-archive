class MatchAll
  def to_proc
    lambda {|x| x.match_all }
  end
end
# Fix to deal with an ActiveSupport and json/pure incompatibility-
class Fixnum
  def to_json(options = nil)
    to_s
  end
end
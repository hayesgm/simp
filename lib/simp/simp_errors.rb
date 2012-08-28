
module SimpErrors
  
  # Custom errors
  class SimpError < StandardError; end
  class MissingItemError < SimpError; end
  class MisconfigurationError < SimpError; end
  
end
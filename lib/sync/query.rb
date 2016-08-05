# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


module Sync
  
  class Query
    attr_reader :type
    attr_reader :params
    
    def initialize(type, params)
      @type = type
      @params = params
    end
    
    def ==(other)
      type == other.type && params == other.params
    end
    
    def eql?(other)
      self == other
    end
        
  end  
  
end

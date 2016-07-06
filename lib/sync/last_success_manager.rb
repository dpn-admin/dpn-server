# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Sync

  
  # Manages laoding and saving the last time an action completed
  # successfully.
  class LastSuccessManager
    
    # @param [String] name A unique name to describe the action for which
    #   the last success is being managed.  This should be the same 
    #   between runs.
    def initialize(name)
      @name = name
    end
    
    
    # Manage the run time for the action contained within the block. If an
    # uncaught exception is encountered, the last_success will not be 
    # updated.
    #
    # @yield Required block around which the last success will be managed.
    # @yieldparam [Time] last_success The time of the last succcess of this
    #   name+remote_namespace pair.
    # @yieldparam [Time] current_time The time that will become the new 
    #   "last success" if the action finishes successfully.
    def manage(&block)
      current_time = Time.now.utc.change(usec: 0)
      yield run_time.last_success, current_time
      run_time.update!(last_success: current_time)
    end


    private

    def run_time
      @last_success_object ||= RunTime.find_by_name!(@name)
    end


  end
end  
  
  

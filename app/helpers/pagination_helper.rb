# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module PaginationHelper
   def previous_page(current_page_number, page_size)
    return nil if current_page_number <= 1
    url_for params.merge({page: current_page_number-1, page_size: page_size})
  end

  def next_page(current_page_number, last_page_number, page_size)
    return nil if current_page_number >= last_page_number
    url_for params.merge({page: current_page_number+1, page_size: page_size})
  end
end
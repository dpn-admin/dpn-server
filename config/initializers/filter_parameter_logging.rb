# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += [:password]

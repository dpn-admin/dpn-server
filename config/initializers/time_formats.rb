# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Time::DATE_FORMATS[:dpn] = "%Y-%m-%dT%H:%M:%SZ"
Time::DATE_FORMATS[:db] = "%Y-%m-%d %H:%M:%SZ"

def time_from_string(string_time)
  Time.zone.parse(string_time.gsub(/\.[0-9]*Z\Z/, "Z"))
end
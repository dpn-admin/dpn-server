# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


Time::DATE_FORMATS[:dpn] = "%Y-%m-%dT%H:%M:%SZ"

def time_from_string(string_time)
  #DateTime.strptime(string_time, Time::DATE_FORMATS[:dpn]).utc.in_time_zone
  Time.zone.parse(string_time)
end
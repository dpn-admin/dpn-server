# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

module Matchers
  class FuzzyNestedMatcher
    def initialize(expected)
      @expected = expected
      @errors = nil
    end


    def matches?(actual)
      @errors ||= match(actual, @expected)
      return @errors == nil
    end


    def match_primitives(actual, expected)
      if actual.respond_to? :strftime
        actual = actual.round(0)
        expected = expected.round(0)
      end
      unless actual == expected
        "expected #{expected}, got #{actual}"
      end
    end


    def match_hashes(actual, expected)
      unless actual.keys.sort == expected.keys.sort
        extra = (actual.keys-expected.keys).map { |key| "+#{key.to_s}"}
        missing = (expected.keys-actual.keys).map { |key| "-#{key.to_s}"}
        return {"Hash keys mismatch:" => extra + missing}
      end

      errors = {}
      actual.keys.each do |key|
        error = match(actual[key], expected[key])
        if error
          errors[key] = error
        end
      end

      if errors.empty?
        return nil
      else
        return errors
      end
    end


    def match_arrays(actual, expected)
      unless actual.size == expected.size
        return "Actual size #{actual.size}, expected #{expected.size}"
      end
      # errors = [].fill(nil, actual.size)
      errors = []
      actual.each_index do |i|
        error = match(actual[i], expected[i])
        if error
          errors[i] = error
        end
      end
      if errors.empty?
        return nil
      else
        return errors
      end
    end


    def match_active_records(actual, expected)
      return match_hashes(actual.attributes.except(:id), expected.attributes.except(:id))
    end


    def match(actual,expected)
      actual_responds_to = responders(actual)
      expected_responds_to = responders(expected)
      unless actual_responds_to== expected_responds_to
        return "Type mismatch: expected [#{expected_responds_to}], got [#{actual_responds_to}]"
      end
      if actual_responds_to.include? :push
        return match_arrays(actual, expected)
      elsif actual_responds_to.include? :has_key?
        return match_hashes(actual, expected)
      elsif actual.is_a? ActiveRecord::Base
        return match_active_records(actual, expected)
      else
        return match_primitives(actual, expected)
      end



    end


    def responders(obj)
      responds_to = []
      [:each, :push, :has_key?].each do |method|
        if obj.respond_to? method
          responds_to << method
        end
      end
      return responds_to
    end


    def failure_message
      @errors
    end

  end
end

def fuzzy_nested_match(actual)
  Matchers::FuzzyNestedMatcher.new(actual)
end



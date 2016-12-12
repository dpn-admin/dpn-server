
# frozen_string_literal: true
require "rails_helper"
require "fileutils"
require "json"

TMPDIR = File.join File.dirname(__FILE__), "tmp"

# Construct seeds in this way to:
#   1. make them available to the before/after(:all) blocks
#   2. continue to prevent cross-test modification
module SpecSeeds
  class << self
    def simple
      { a: 1, b: 2, c: 3 }
    end

    def complex
      {
        a: { aa: 11 },
        b: [2, 3, 4],
        c: [{ ca: 1, cb: 2 }],
        d: { da: [1, 2, 3] }
      }
    end

    def mixed_keys
      { "a" => 1, b: 2 }
    end
  end
end

describe Db::SeedFileLoader do
  before(:all) do
    dir = File.join(TMPDIR, "test-seeds.d")
    FileUtils.mkdir_p dir
    File.write(File.join(dir, "simple.json"),     SpecSeeds.simple.to_json)
    File.write(File.join(dir, "complex.json"),    SpecSeeds.complex.to_json)
    File.write(File.join(dir, "mixed_keys.json"), SpecSeeds.mixed_keys.to_json)
  end
  after(:all) do
    FileUtils.remove_entry_secure TMPDIR
  end

  let(:simple_seed) { SpecSeeds.simple }
  let(:complex_seed) { SpecSeeds.complex }
  let(:mixed_keys_seed) { SpecSeeds.mixed_keys }
  let(:base_dir) { TMPDIR }
  let(:seed_dir) { File.join base_dir, "test-seeds.d" }
  let(:loader) { described_class.new("test", base_dir) }

  describe "#seed_dir" do
    it "constructs the correct path" do
      expect(loader.seed_dir).to eql(seed_dir)
    end
  end

  describe "#seed_files" do
    let(:seed_files) do
      ["complex.json", "mixed_keys.json", "simple.json"].sort.map do |basename|
        File.join(seed_dir, basename)
      end
    end
    it "returns the seed files in the seed_dir" do
      expect(loader.seed_files).to match_array(seed_files)
    end
  end

  describe "#seed_hashes" do
    let(:symbolized_mixed_keys_seed) { { a: 1, b: 2 } }
    it "yields each hash successively" do
      expect {|spy| loader.seed_hashes(&spy) }
        .to yield_successive_args(complex_seed, symbolized_mixed_keys_seed, simple_seed)
    end
  end
end

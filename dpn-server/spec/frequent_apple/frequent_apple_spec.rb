require 'rails_helper'
require "frequent_apple"
require "json"

class TestResponse
  def initialize(body)
    @body = body
  end

  def [](key)
    return @body[key]
  end

  def body
    return @body.to_json
  end

  def ok?
    true
  end
end

describe FrequentApple do
  describe "::get_and_depaginate" do
    before(:each) do
      @actual_results = []
      @client = double(:client)
    end
    subject { FrequentApple.get_and_depaginate(@client, "p1") {|results| @actual_results += results} }
    context "next not null, results empty" do
      before(:each) do
        responses = [
            TestResponse.new({ next: "p2", results: [1,11,111]}),
            TestResponse.new({ next: "p3", results: [2,22,222]}),
            TestResponse.new({ next: "p4", results: [3,33,333]}),
            TestResponse.new({ next: "p5", results: []})
        ]
        @expected_results = []
        responses.each do |r|
          @expected_results += r[:results]
        end
        allow(@client).to receive(:get).and_return(*responses)
      end

      it "returns the right results" do
        subject()
        expect(@actual_results).to eql(@expected_results)
      end

    end

    context "next null, results not empty" do
      before(:each) do
        responses = [
            TestResponse.new({ next: "p2", results: [1,11,111]}),
            TestResponse.new({ next: "p3", results: [2,22,222]}),
            TestResponse.new({ next: "p4", results: [3,33,333]}),
            TestResponse.new({ next: nil, results: [4,44,444]})
        ]
        @expected_results = []
        responses.each do |r|
          @expected_results += r[:results]
        end
        allow(@client).to receive(:get).and_return(*responses)
      end

      it "returns the right results" do
        subject()
        expect(@actual_results).to eql(@expected_results)
      end

    end
  end

  describe "::last_update" do
    context "dpn time format" do
      before(:each) do
        @now = DateTime.now.utc
        @records = [
            {data: Faker::Code.isbn, updated_at: 4.day.ago.strftime(Time::DATE_FORMATS[:dpn]) },
            {data: Faker::Code.isbn, updated_at: 2.days.ago.strftime(Time::DATE_FORMATS[:dpn]) },
            {data: Faker::Code.isbn, updated_at: 3.days.ago.strftime(Time::DATE_FORMATS[:dpn]) },
            {data: Faker::Code.isbn, updated_at: @now.strftime(Time::DATE_FORMATS[:dpn]) },
            {data: Faker::Code.isbn, updated_at: 4.days.ago.strftime(Time::DATE_FORMATS[:dpn]) }
        ]
      end
      subject { FrequentApple.last_update(@records, Time::DATE_FORMATS[:dpn])}

      it "returns a DateTime instance" do
        expect(subject).to be_a(DateTime)
      end

      it "returns the latest date" do
        expect(subject.to_s).to eql(@now.to_s)
      end
    end
  end


end


# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

describe Sync::CreatorUpdater do
  
  before(:each) do
    @model_class = double(:model_class)
    @model_subclass = double(:model_subclass)

    @typestring = double(:typestring)
    allow(@typestring).to receive(:constantize).and_return @model_subclass

    allow(@model_class).to receive(:find_fields).and_return [:foo, :bar]
    allow(@model_subclass).to receive(:find_fields).and_return [:foo, :bar]

    @model = double(:model)
    @model_hash = { name: "some_name", foo: "some_foo", bar: "some_bar" }
  end


  shared_context "w/o associations" do
    before(:each) do
      allow(@model).to receive(:respond_to?).with(:update_with_associations!).and_return false
      allow(@model).to receive(:update!)
    end
  end


  shared_context "w/ associations" do
    before(:each) do
      allow(@model).to receive(:respond_to?).with(:update_with_associations!).and_return true
      allow(@model).to receive(:update_with_associations!)
    end
  end

  # Use let(:real_model_class)
  shared_context "exists" do 
    before(:each) do
      allow(real_model_class).to receive(:find_by).and_return @model
    end
  end

  # Use let(:real_model_class)
  shared_context "new" do 
    before(:each) do
      allow(real_model_class).to receive(:find_by).and_return nil
      allow(real_model_class).to receive(:new).and_return @model   
    end
  end
  
  shared_context "w/ sti" do
    before(:each) do
      @model_hash[:type] = @typestring
    end
  end
   
  
    
  context "w/ sti" do
    include_context "w/ sti"
    context "w/ associations" do
      include_context "w/ associations"
      ["exists", "new"].each do |existence_context|
        include_context existence_context do
          let(:real_model_class) { @model_subclass }
        end
        
        it "uses the correct search conditions" do
          expect(@model_subclass).to receive(:find_by).with(foo: "some_foo", bar: "some_bar")
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end

        it "creates or updates the record" do
          expect(@model).to receive(:update_with_associations!).with(@model_hash)
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end
        
      end
    end
    context "w/o associations" do
      include_context "w/o associations"
      ["exists", "new"].each do |existence_context|
        include_context existence_context do
          let(:real_model_class) { @model_subclass }
        end

        it "uses the correct search conditions" do
          expect(@model_subclass).to receive(:find_by).with(foo: "some_foo", bar: "some_bar")
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end

        it "creates or updates the record" do
          expect(@model).to receive(:update!).with(@model_hash)
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end
        
      end
    end
  end

  context "w/o sti" do
    context "w/ associations" do
      include_context "w/ associations"
      ["exists", "new"].each do |existence_context|
        include_context existence_context do
          let(:real_model_class) { @model_class }
        end

        it "uses the correct search conditions" do
          expect(@model_class).to receive(:find_by).with(foo: "some_foo", bar: "some_bar")
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end

        it "creates or updates the record" do
          expect(@model).to receive(:update_with_associations!).with(@model_hash)
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end
        
      end
    end
    context "w/o associations" do
      include_context "w/o associations"
      ["exists", "new"].each do |existence_context|
        include_context existence_context do
          let(:real_model_class) { @model_class }
        end
        
        it "uses the correct search conditions" do
          expect(@model_class).to receive(:find_by).with(foo: "some_foo", bar: "some_bar")
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)        
        end
        
        it "creates or updates the record" do
          expect(@model).to receive(:update!).with(@model_hash)
          Sync::CreatorUpdater.new(@model_class).update!(@model_hash)
        end
        
      end
    end
  end
  
  
  
    
end
  
  
  
  
  
  
  
  

  

  

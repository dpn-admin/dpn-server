# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.


require 'rails_helper'

ALL_STATUSES = [ :requested, :rejected, :received, :confirmed, :stored, :cancelled ]

def change!(record, new_status)
  if record.status.to_sym == :requested
    if new_status == :confirmed
      record.fixity_value ||= "somefixityvalue"
      record.bag_valid ||= [true,false].sample
    end
  else
    if [:received, :confirmed, :stored, :cancelled].include?(new_status)
      record.fixity_value ||= "somefixityvalue"
      record.bag_valid ||= [true,false].sample
      unless record.status.to_sym == :received && new_status == :cancelled || new_status == :received
        record.fixity_accept ||= [true,false].sample
      end
    end
  end
  record.status = new_status
end


shared_examples "a statemachine" do |starting_status, allowed_statuses|
  context "status: #{starting_status}" do
    before(:each) do
      @existing_instance = Fabricate(:"replication_transfer_#{starting_status}",
        from_node: @from_node,
        to_node: @to_node,
        bag: Fabricate(:data_bag, admin_node: @from_node)
      )
    end

    disallowed_statuses = ALL_STATUSES - (allowed_statuses + [starting_status])
    disallowed_statuses.each do |status| #disallowed statuses
      context "-> #{status}" do
        before(:each) do
          change!(@existing_instance,status)
          @existing_instance.requester = @requester
        end
        it {expect(@existing_instance).to_not be_valid}
      end
    end

    allowed_statuses.each do |status|
      context "-> #{status}" do
        before(:each) do
          change!(@existing_instance,status)
          @existing_instance.requester = @requester
        end
        it {expect(@existing_instance).to be_valid}
      end
    end
  end
end

describe ReplicationTransfer do
  it "has a valid factory" do
    expect(Fabricate(:replication_transfer)).to be_valid
  end
  
  it "allows you to replicate to yourself" do
    node = Fabricate(:node)
    bag = Fabricate(:data_bag, admin_node: node)
    expect(Fabricate(:replication_transfer, from_node: node, to_node: node)).to be_valid
  end

  describe "replication_id" do
    it "is required" do
      expect(Fabricate.build(:replication_transfer, replication_id: nil)).to_not be_valid
    end
    it "disallows changing" do
      repl = Fabricate(:replication_transfer)
      repl.replication_id = SecureRandom.uuid
      expect(repl.save).to be false
    end
    it "only accepts valid uuids" do
      expect{
        Fabricate(:replication_transfer, replication_id: "someuuid")
      }.to raise_error ActiveRecord::RecordInvalid
    end
    it "does not create a BagMan::Request" do
      expect(Fabricate(:replication_transfer).bag_man_request).to be_nil
    end
  end

  context "create" do
    context "to_node == local_node" do
      let(:record) { Fabricate(:replication_transfer, to_node: Fabricate(:local_node)) }
      it "creates a BagMan::Request" do
        expect(record.bag_man_request).to be_valid
      end
      it "doesn't forget about the BagMan::Request" do
        expect(record.reload.bag_man_request).to be_valid
      end
      it "assigns link to the BagMan::Request source_location" do
        expect(record.link).to eql(record.bag_man_request.source_location)
      end
    end

    context "from_node != local_node" do
      it "requires a replication_id" do
        expect {
          Fabricate(:replication_transfer, replication_id: nil)
        }.to raise_error ActiveRecord::RecordInvalid
      end
      it "does not alter the replication_id" do
        id = SecureRandom.uuid
        record = Fabricate(:replication_transfer, replication_id: id)
        expect(record.replication_id).to eql(id)
      end
    end

    context "from_node==local_node" do
      let(:record) {
        Fabricate(:replication_transfer,
                  replication_id: nil,
                  from_node: Fabricate(:local_node, namespace: Rails.configuration.local_namespace))
      }

      it "does not require a replication_id" do
        expect { record }.to_not raise_error
      end
      it "sets the replication_id to a uuid" do
        expect(record.replication_id).to match /\A[a-f0-9]{8}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{4}\-[a-f0-9]{12}\Z/
      end

    end
  end

  describe "#update" do
    before(:each) do
      @local_node = Fabricate(:local_node, namespace: Rails.configuration.local_namespace)
    end

    it "requires a replication_id" do
      record = Fabricate(:replication_transfer)
      record.replication_id = nil
      expect(record).to_not be_valid
    end


    context "callback" do
      let(:cancelled) { "cancelled" }
      let(:confirmed) { "confirmed" }
      before(:each) do
        # Fabricator sets the fixity_alg for our replication_transfer
        @record = Fabricate(:replication_transfer_received_nil,
                            from_node: @local_node)

        # Grab the first fixity check since we only gen one
        @check = @record.bag.fixity_checks[0]

        # Set the fixity algorithm for the transfer record to be the same as the fixity check
        # @record.fixity_alg = @check.fixity_alg
      end

      context "updates fixity_accept" do
        context "when fixity matches" do
          before(:each) do
            @record.fixity_value = @check.value
            @record.updated_at = 1.minute.ago
            @record.save!
          end
          it "sets fixity_accept to true" do
            expect(@record.reload.fixity_accept).to be true
          end
          it "updates updated_at" do
            expect(@record.reload.updated_at).to be > 1.minute.ago
          end
        end

        context "when fixity wrong" do
          before(:each) do
            @record.fixity_value = SecureRandom.uuid
            @record.updated_at = 1.minute.ago
            @record.save!
          end
          it "sets fixity_accept to false" do
            expect(@record.reload.fixity_accept).to be false
          end
          it "updates updated_at" do
            expect(@record.reload.updated_at).to be > 1.minute.ago
          end
        end
      end

      context "updates status" do
        context "with bag_valid" do
          before(:each) { @record.bag_valid = true}
          context "when fixity matches" do
            before(:each) do
              @record.fixity_value = @check.value
              @record.updated_at = 1.minute.ago
              @record.save!
            end
            it "is confirmed" do
              expect(@record.reload.status).to eq(confirmed)
            end
            it "updates updated_at" do
              expect(@record.reload.updated_at).to be > 1.minute.ago
            end
          end
          context "when fixity wrong" do
            before(:each) do
              @record.fixity_value = SecureRandom.uuid
              @record.updated_at = 1.minute.ago
              @record.save!
            end
            it "is cancelled" do
              expect(@record.reload.status).to eq(cancelled)
            end
            it "updates updated_at" do
              expect(@record.reload.updated_at).to be > 1.minute.ago
            end
          end
        end
        context "with invalid bag" do
          before(:each) { @record.bag_valid = false}
          context "when fixity matches" do
            before(:each) do
              @record.fixity_value = @check.value
              @record.updated_at = 1.minute.ago
              @record.save!
            end
            it "is cancelled" do
              expect(@record.reload.status).to eq(cancelled)
            end
            it "updates updated_at" do
              expect(@record.reload.updated_at).to be > 1.minute.ago
            end
          end
          context "when fixity wrong" do
            before(:each) do
              @record.fixity_value = SecureRandom.uuid
              @record.updated_at = 1.minute.ago
              @record.save!
            end
            it "is cancelled" do
              expect(@record.reload.status).to eq(cancelled)
            end
            it "updates updated_at" do
              expect(@record.reload.updated_at).to be > 1.minute.ago
            end
          end
        end
      end
    end

    context "when from_node==local_node && requester==local_node" do
      before(:each) do
        @from_node = @local_node
        @to_node = Fabricate(:node)
        @requester = @local_node
      end
      it_behaves_like "a statemachine", :requested, [:cancelled]
      it_behaves_like "a statemachine", :rejected, []
      it_behaves_like "a statemachine", :received, [:confirmed, :cancelled]
      it_behaves_like "a statemachine", :confirmed, [:cancelled]
      it_behaves_like "a statemachine", :stored, []
      it_behaves_like "a statemachine", :cancelled, []
    end

    context "when from_node==local_node && requester==to_node" do
      before(:each) do
        @from_node = @local_node
        @to_node = Fabricate(:node)
        @requester = @to_node
      end
      it_behaves_like "a statemachine", :requested, [:rejected, :received, :cancelled]
      it_behaves_like "a statemachine", :rejected, []
      it_behaves_like "a statemachine", :received, [:received, :cancelled]
      it_behaves_like "a statemachine", :confirmed, [:stored, :cancelled]
      it_behaves_like "a statemachine", :stored, []
      it_behaves_like "a statemachine", :cancelled, []
    end

    context "when to_node==local_node && requester==local_node" do
      before(:each) do
        @from_node = Fabricate(:node)
        @to_node = @local_node
        @requester = @local_node
      end
# The following transition, previously prohibited, is now allowed as
# part of fix to https://jira.duraspace.org/browse/DPN-81
#      it_behaves_like "a statemachine", :requested, [:cancelled, :rejected, :received, :confirmed]
      it_behaves_like "a statemachine", :rejected, []
      it_behaves_like "a statemachine", :received, [:confirmed, :cancelled]
      it_behaves_like "a statemachine", :confirmed, [:cancelled, :stored]
      it_behaves_like "a statemachine", :stored, []
      it_behaves_like "a statemachine", :cancelled, []
      it "spawns a BagMan::BagPreserveJob" do
        bag_man_request = Fabricate(:bag_man_request)
        record = Fabricate(:replication_transfer,
          status: :received,
          fixity_value: "fixity_value",
          to_node: @local_node,
          bag_valid: true,
          bag_man_request: bag_man_request)
        record.status = :confirmed
        record.fixity_accept = true
        record.requester = @requester

        expect {
          record.save
        }.to enqueue_a(::BagMan::BagPreserveJob).with(global_id(bag_man_request), bag_man_request.staging_location, Rails.configuration.repo_dir)
      end
    end

    context "when to_node==local_node && requester==to_node" # Duplicate of previous scope

    context "when local_node unimplicated && requester==local_node" do
      before(:each) do
        @from_node = Fabricate(:node)
        @to_node = Fabricate(:node)
        @requester = @local_node
      end
      it_behaves_like "a statemachine", :requested, [:cancelled, :rejected, :received, :confirmed, :stored]
      it_behaves_like "a statemachine", :rejected, []
      it_behaves_like "a statemachine", :received, [:confirmed, :cancelled, :stored]
      it_behaves_like "a statemachine", :confirmed, [:cancelled, :stored]
      it_behaves_like "a statemachine", :stored, []
      it_behaves_like "a statemachine", :cancelled, []
    end

    context "when local_node unimplicated && requester==to_node" do
      before(:each) do
        @from_node = Fabricate(:node)
        @to_node = Fabricate(:node)
        @requester = @to_node
      end
      it_behaves_like "a statemachine", :requested, []
      it_behaves_like "a statemachine", :rejected, []
      it_behaves_like "a statemachine", :received, []
      it_behaves_like "a statemachine", :confirmed, []
      it_behaves_like "a statemachine", :stored, []
      it_behaves_like "a statemachine", :cancelled, []
    end
  end
end

# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

require 'rails_helper'

describe ReplicationTransferUpdater do

  def params(record, changes)
    updated = ReplicationTransferAdapter.from_model(record).to_params_hash
    updated.merge!(changes)
  end

  describe "::build_update" do
    let(:record) { Fabricate(:replication_transfer) }
    it "returns a subclass of ReplicationTransferUpdate" do
      allow(ReplicationTransferUpdater::CancelUpdate).to receive(:matching_update?).and_return true
      expect(described_class.build_update(record,{}).class).to eql(ReplicationTransferUpdater::CancelUpdate)
    end
    it "returns a generic ReplicationTransferUpdate when no specific matches exist" do
      expect(described_class.build_update(record,{}).class).to eql(ReplicationTransferUpdater::ReplicationTransferUpdate)
    end
  end


  describe ReplicationTransferUpdater::ReplicationTransferUpdate do
    describe "#we_requested?" do
      let(:our_transfer) { Fabricate.build(:replication_transfer, from_node: Fabricate.build(:local_node)) }
      let(:their_transfer) { Fabricate.build(:replication_transfer, from_node: Fabricate.build(:node)) }
      it "is true if record.from_node is the local node" do
        expect(described_class.new(our_transfer, nil).we_requested?).to be true
      end
      it "is false if it was created by another" do
        expect(described_class.new(their_transfer, nil).we_requested?).to be false
      end
    end
    describe "#we_replicating?" do
      let(:is_to_node_record) { Fabricate.build(:replication_transfer, to_node: Fabricate.build(:local_node)) }
      let(:is_not_to_node_record) { Fabricate.build(:replication_transfer, to_node: Fabricate.build(:node)) }
      it "is true if record.to_node is the local node" do
        expect(described_class.new(is_to_node_record, nil).we_replicating?).to be true
      end
      it "is false if record.to_node is another node" do
        expect(described_class.new(is_not_to_node_record, nil).we_replicating?).to be false
      end
    end
  end


  describe ReplicationTransferUpdater::CancelUpdate do
    describe "::matching_update?" do
      let(:record) { Fabricate(:replication_transfer, cancelled: false, cancel_reason: nil) }
      let(:changes) { {cancelled: true, cancel_reason: "test", cancel_reason_detail: "test_detail"} }
      it "matches old.cancelled == false, new.cancelled == true" do
        expect(described_class.matching_update?(record, params(record, changes))).to be true
      end
    end

    # Expects let(:record) and let(:changes)
    shared_examples "CancelUpdate#update" do
      let(:update_poro) { described_class.new(record, params(record, changes))  }
      it "cancels the record" do
        update_poro.update
        expect(record.cancelled).to be true
      end
      it "sets the cancel reason" do
        update_poro.update
        expect(record.cancel_reason).to eql("test")
      end
      it "sets the cancel_reason_detail" do
        update_poro.update
        expect(record.cancel_reason_detail).to eql("test_detail")
      end
      it "returns true on success" do
        allow(record).to receive(:cancel!).and_return true
        expect(update_poro.update).to be true
      end
      it "returns false on failure" do
        allow(record).to receive(:cancel!).and_return false
        expect(update_poro.update).to be false
      end
    end

    describe "#update" do
      let(:changes) { {cancelled: true, cancel_reason: "test", cancel_reason_detail: "test_detail"} }
      context "local->other" do
        let(:record) {
          Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node),
            to_node: Fabricate(:node),
            cancelled: false,
            cancel_reason: nil)}
        it_behaves_like "CancelUpdate#update"
      end
      context "local->local" do
        let(:record) {
          Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node),
            to_node: Node.local_node!,
            cancelled: false,
            cancel_reason: nil)}
        it_behaves_like "CancelUpdate#update"
      end
      context "other->other" do
        let(:record) {
          Fabricate(:replication_transfer,
            from_node: Fabricate(:node),
            to_node: Fabricate(:node),
            cancelled: false,
            cancel_reason: nil)}
        it_behaves_like "CancelUpdate#update"
      end
      context "other->local" do
        let(:record) {
          Fabricate(:replication_transfer,
            from_node: Fabricate(:node),
            to_node: Fabricate(:local_node),
            cancelled: false,
            cancel_reason: nil)}
        it_behaves_like "CancelUpdate#update"
      end
    end
  end


  describe ReplicationTransferUpdater::FixityValueUpdate do
    let(:fixity_alg) { Fabricate(:fixity_alg) }
    let(:fixity_value) { "81234823749274982749273948723"}
    let(:bag) {
      bag = Fabricate(:bag)
      bag.message_digests << Fabricate.build(:message_digest, fixity_alg: fixity_alg, value: fixity_value)
      bag.save!
      bag
    }

    describe "::matching_update?" do
      let(:record) { Fabricate(:replication_transfer, bag: bag, fixity_alg: fixity_alg, fixity_value: nil)}
      let(:changes) { {fixity_value: fixity_value} }
      it "matches old.fixity_value == nil, new.fixity_value != nil" do
        expect(described_class.matching_update?(record, params(record, changes))).to be true
      end
    end

    describe "#update" do
      let(:update_poro) { described_class.new(record, params(record, changes)) }
      shared_examples "FixityValueUpdate#update basics" do
        it "updates the record" do
          update_poro.update
          expect(record.fixity_value).to eql(changes[:fixity_value])
        end
        it "returns true on success" do
          allow(record).to receive(:update).and_return true
          expect(update_poro.update).to be true
        end
        it "returns false on failure" do
          allow(record).to receive(:update).and_return false
          expect(update_poro.update).to be false
        end
      end
      shared_examples "FixityValueUpdate#update as nobody" do
        include_examples "FixityValueUpdate#update basics"
        it "does not cancel the record" do
          update_poro.update
          expect(record.cancelled).to be false
        end
        it "does not set store_requested" do
          update_poro.update
          expect(record.store_requested).to be false
        end
      end
      shared_examples "FixityValueUpdate#update as admin success" do
        include_examples "FixityValueUpdate#update basics"
        it "sets store_requested->true" do
          update_poro.update
          expect(record.store_requested).to be true
        end
        it "does not cancel the record" do
          update_poro.update
          expect(record.cancelled).to be false
        end
      end
      shared_examples "FixityValueUpdate#update as admin failure" do
        include_examples "FixityValueUpdate#update basics"
        it "cancels with cancel_reason: fixity_reject" do
          update_poro.update
          expect(record.cancelled).to be true
          expect(record.cancel_reason).to eql("fixity_reject")
        end
        it "cancels with a correct cancel_reason_detail" do
          update_poro.update
          expect(record.cancel_reason_detail)
            .to eql("expected: '#{fixity_value}', got: '#{changes[:fixity_value]}'")
        end
        it "does not set store_requested" do
          update_poro.update
          expect(record.store_requested).to be false
        end
      end

      context "fixity is correct" do
        let(:changes) { { fixity_value: fixity_value} }
        context "local->other" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node), to_node: Fabricate(:node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as admin success"
        end
        context "local->local" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node), to_node: Node.local_node!,
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as admin success"
        end
        context "other->other" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:node), to_node: Fabricate(:node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as nobody"
        end
        context "other->local" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:node), to_node: Fabricate(:local_node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as nobody"
        end
      end
      context "fixity is incorrect" do
        let(:changes) { { fixity_value: "93847238479237490238"} }
        context "local->other" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node), to_node: Fabricate(:node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as admin failure"
        end
        context "local->local" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:local_node), to_node: Node.local_node!,
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as admin failure"
        end
        context "other->other" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:node), to_node: Fabricate(:node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as nobody"
        end
        context "other->local" do
          let(:record) { Fabricate(:replication_transfer,
            from_node: Fabricate(:node), to_node: Fabricate(:local_node),
            bag: bag, fixity_alg: fixity_alg, )}
          it_behaves_like "FixityValueUpdate#update as nobody"
        end
      end
    end

  end


  describe ReplicationTransferUpdater::StoreRequestedUpdate do
    describe "::matching_update?" do
      let(:changes) { {store_requested: true} }
      let(:record) { Fabricate(:replication_transfer, store_requested: false) }
      it "matches old.store_requested == false, new.store_requested == true" do
        expect(described_class.matching_update?(record, params(record, changes))).to be true
      end
    end
    describe "#update" do
      let(:changes) { {store_requested: true} }
      let(:update_poro) { described_class.new(record, params(record, changes)) }
      shared_examples "StoreRequestedUpdate#update basics" do
        it "updates the record" do
          update_poro.update
          expect(record.store_requested).to be true
        end
        it "returns true on success" do
          allow(record).to receive(:update).and_return true
          expect(update_poro.update).to be true
        end
        it "returns false on failure" do
          allow(record).to receive(:update).and_return false
          expect(update_poro.update).to be false
        end
        it "does not cancel the record" do
          update_poro.update
          expect(record.cancelled).to be false
        end
        it "does not set stored" do
          update_poro.update
          expect(record.stored).to be false
        end
      end
      shared_examples "StoreRequestedUpdate#update as replicator" do
        include_examples "StoreRequestedUpdate#update basics"
        it "requests preservation" do
          bag_man_request = double(:bag_man_request)
          allow(record).to receive(:bag_man_request).and_return(bag_man_request)
          expect(bag_man_request).to receive(:okay_to_preserve!)
          update_poro.update
        end
      end
      shared_examples "StoreRequestedUpdate#update as nobody" do
        include_examples "StoreRequestedUpdate#update basics"
        it "does not request preservation" do
          bag_man_request = double(:bag_man_request)
          allow(record).to receive(:bag_man_request).and_return(bag_man_request)
          expect(bag_man_request).to_not receive(:okay_to_preserve!)
          update_poro.update
        end
      end

      context "local->other" do
        let(:record) { Fabricate(:replication_transfer, store_requested: false,
          from_node: Fabricate(:local_node), to_node: Fabricate(:node))}
        it_behaves_like "StoreRequestedUpdate#update as nobody"
      end
      context "local->local" do
        let(:record) { Fabricate(:replication_transfer, store_requested: false,
          from_node: Fabricate(:local_node), to_node: Node.local_node!)}
        it_behaves_like "StoreRequestedUpdate#update as replicator"
      end
      context "other->other" do
        let(:record) { Fabricate(:replication_transfer, store_requested: false,
          from_node: Fabricate(:node), to_node: Fabricate(:node))}
        it_behaves_like "StoreRequestedUpdate#update as nobody"
      end
      context "other->local" do
        let(:record) { Fabricate(:replication_transfer, store_requested: false,
          from_node: Fabricate(:node), to_node: Fabricate(:local_node))}
        it_behaves_like "StoreRequestedUpdate#update as replicator"
      end
    end
  end


  describe ReplicationTransferUpdater::StoredUpdate do
    describe "::matching_update?" do
      let(:record) { Fabricate(:replication_transfer, stored: false) }
      let(:changes) { {stored: true} }
      it "matches old.stored == false, new.stored == true" do
        expect(described_class.matching_update?(record, params(record, changes))).to be true
      end
    end
    describe "#update" do
      let(:changes) { {stored: true} }
      let(:update_poro) { described_class.new(record, params(record, changes)) }
      shared_examples "StoredUpdate#update basics" do
        it "updates the record" do
          update_poro.update
          expect(record.stored).to be true
        end
        it "returns true on success" do
          allow(record).to receive(:update).and_return true
          expect(update_poro.update).to be true
        end
        it "returns false on failure" do
          allow(record).to receive(:update).and_return false
          expect(update_poro.update).to be false
        end
        it "does not cancel the record" do
          update_poro.update
          expect(record.cancelled).to be false
        end
      end
      shared_examples "StoredUpdate#update as admin" do
        include_examples "StoredUpdate#update basics"
        it "adds to_node to the bag's replicating nodes" do
          update_poro.update
          expect(record.bag.replicating_nodes).to include(record.to_node)
        end
      end
      shared_examples "StoredUpdate#update as nobody" do
        include_examples "StoredUpdate#update basics"
        it "does not modify the bag's replicating nodes" do
          update_poro.update
          expect(record.bag.replicating_nodes).to_not include(record.to_node)
        end
      end

      context "local->other" do
        let(:record) { Fabricate(:replication_transfer, stored: false,
          from_node: Fabricate(:local_node), to_node: Fabricate(:node))}
        it_behaves_like "StoredUpdate#update as admin"
      end
      context "local->local" do
        let(:record) { Fabricate(:replication_transfer, stored: false,
          from_node: Fabricate(:local_node), to_node: Node.local_node!)}
        it_behaves_like "StoredUpdate#update as admin"
      end
      context "other->other" do
        let(:record) { Fabricate(:replication_transfer, stored: false,
          from_node: Fabricate(:node), to_node: Fabricate(:node))}
        it_behaves_like "StoredUpdate#update as nobody"
      end
      context "other->local" do
        let(:record) { Fabricate(:replication_transfer, stored: false,
          from_node: Fabricate(:node), to_node: Fabricate(:local_node))}
        it_behaves_like "StoredUpdate#update as nobody"
      end
    end

  end

end

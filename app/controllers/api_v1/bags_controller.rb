require_relative '../../../app/presenters/api_v1/bag_presenter'

class ApiV1::BagsController < ApplicationController
  include Authenticate

  def index
    bags = Bag.all.collect do |bag|
      ApiV1::BagPresenter.new(bag)
    end

    output = {
      :count => bags.size,
      :results => bags
    }

    render json: output
  end


  def show
    bag = Bag.find_by_uuid(params[:uuid])
    if bag.nil?
      render json: {}
    else
      render json: ApiV1::BagPresenter.new(bag)
    end
  end


  # This method is internal
  def create
    if @requester.namespace != Rails.configuration.config.local_namespace
      render json: "Only allowed by local node.", status: 403
    else
      case params[:bag][:bag_type]
        when "D"
          bag = DataBag.new
          bag.rights_bags = RightsBag.where(:uuid => params[:bag][:rights])
          bag.interpretive_bags = InterpretiveBag.where(:uuid => params[:bag][:interpretive])
        when "R"
          bag = RightsBag.new
        when "I"
          bag = InterpretiveBag.new
        else
          throw TypeError, "illegal bag type #{params[:bag][:bag_type]}"
      end

      bag.uuid = params[:bag][:uuid]
      bag.local_id = params[:bag][:local_id]
      bag.size = params[:bag][:size]
      bag.version_family = VersionFamily.find_by_uuid(params[:bag][:first_version_uuid])
      bag.version = params[:bag][:version]
      bag.ingest_node = Node.find_by_namespace(params[:bag][:ingest_node])
      bag.admin_node = Node.find_by_namespace(params[:bag][:admin_node])
      bag.replicating_nodes = Node.where(:namespace => params[:bag][:replicating_nodes])
      bag.save

      params[:bag][:fixities].each do |check|
        fc = FixityCheck.new
        fc.bag = bag
        fc.fixity_alg = FixityAlg.find_by_name(check[:fixity_algorithm])
        fc.value = check[:fixity_value]
        fc.save
        #bag.fixity_checks << fc
      end

      render json: ApiV1::BagPresenter.new(bag)
    end
  end


  # This method is internal
  def update
    if @requester.namespace != Rails.configuration.config.local_namespace
      render json: "Only allowed by local node.", status: 403
    else
      case params[:bag][:bag_type]
      when "D"
        bag = DataBag.find_by_uuid!(params[:bag][:uuid])
        bag.rights_bags = RightsBag.where(:uuid => params[:bag][:rights])
        bag.brightening_bags = InterpretiveBag.where(:uuid => params[:bag][:interpretive])
      when "R"
        bag = RightsBag.new
      when "I"
        bag = InterpretiveBag.new
      else
        throw TypeError, "illegal bag type #{params[:bag][:bag_type]}"
      end

      bag = Bag.find_by_uuid!(params[:bag][:uuid])
      bag.local_id = params[:bag][:local_id]
      bag.admin_node = Node.find_by_namespace(params[:bag][:admin_node])
      bag.replicating_nodes = Node.where(:namespace => params[:bag][:replicating_nodes_nodes])

      params[:bag][:fixities].each do |check|
        bag.fixity_checks << FixityCheck.find_or_create_by(
          :bag_id => bag.id,
          :fixity_alg_id => FixityAlg.find_by_name(check[:fixity_alg]).id,
          :value => check[:fixity_value]
        )
      end

      bag.save
      render json: ApiV1::BagPresenter.new(bag)
    end
  end


end
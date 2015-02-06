require_relative '../../../app/presenters/api_v1/bag_presenter'

class ApiV1::BagsController < ApplicationController
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
    bag = Bag.find_by_uuid!(params[:uuid])
    render json: ApiV1::BagPresenter.new(bag)
  end

  # This method is internal
  def create
    case params[:bag][:type]
    when "data"
      bag = DataBag.new
      bag.rights_bags = RightsBag.where(:uuid => params[:bag][:rights])
      bag.brightening_bags = BrighteningBag.where(:uuid => params[:bag][:brightening])
    when "rights"
      bag = RightsBag.new
    when "brightening"
      bag = BrighteningBag.new
    else
      throw TypeError, "illegal bag type #{params[:bag][:type]}"
    end

    bag.uuid = params[:bag][:uuid]
    bag.local_id = params[:bag][:local_id]
    bag.size = params[:bag][:size]
    bag.version_family = VersionFamily.find_by_uuid(params[:bag][:first_version_uuid])
    bag.version = params[:bag][:version]
    bag.original_node = Node.find_by_namespace(params[:bag][:original_node])
    bag.admin_node = Node.find_by_namespace(params[:bag][:admin_node])
    bag.replicating_nodes = Node.where(:namespace => params[:bag][:repl_nodes])

    params[:bag][:fixities].each do |check|
      fc = FixityCheck.new
      fc.node = Node.find_by_namespace(:params[:author])
      fc.bag = Bag.find_by_uuid(params[:bag][:uuid])
      fc.fixity_alg = FixityAlg.find_by_name(check[:fixity_alg])
      fc.value = check[:fixity_value]
      fc.save
      bag.fixity_checks << fc
    end

    bag.save
    render json: ApiV1::BagPresenter.new(bag)
  end

  # This method is internal
  def update
    case params[:bag][:type]
    when "data"
      bag = DataBag.find_by_uuid!(params[:bag][:uuid])
      bag.rights_bags = RightsBag.where(:uuid => params[:bag][:rights])
      bag.brightening_bags = BrighteningBag.where(:uuid => params[:bag][:brightening])
    when "rights"
      bag = RightsBag.new
    when "brightening"
      bag = BrighteningBag.new
    end

    bag = Bag.find_by_uuid!(params[:bag][:uuid])
    bag.local_id = params[:bag][:local_id]
    bag.admin_node = Node.find_by_namespace(params[:bag][:admin_node])
    bag.replicating_nodes = Node.where(:namespace => params[:bag][:repl_nodes])

    params[:bag][:fixities].each do |check|
      bag.fixity_checks << FixityCheck.find_or_create_by(
        :node_id => Node.find_by_namespace(params[:author]).id,
        :bag_id => bag.id,
        :fixity_alg_id => FixityAlg.find_by_name(check[:fixity_alg]).id,
        :value => check[:fixity_value]
      )
    end

    bag.save
    render json: ApiV1::BagPresenter.new(bag)
  end

end

require_relative '../../../app/presenters/api_v1/member_presenter'

class ApiV1::MembersController < ApplicationController
  include Authenticate
  include Pagination

  local_node_only :create, :update, :destroy
  uses_pagination :index

  def index
    raw = Member.with_name(params[:name])
      .with_email(params[:email])
      .page(@page)
      .per(@page_size)

    @members = raw.collect do |member|
      ApiV1::MemberPresenter.new(member)
    end

    output = {
      :count => raw.size,
      :next => link_to_next_page(raw.total_count),
      :previous => link_to_previous_page,
      :results => @members
    }

    render json: output
  end

  def show
    member = Member.find_by_uuid!(params[:uuid])
    @member = ApiV1::MemberPresenter.new(member)
    render json: @member
  end

  def create
    expected_params = [:uuid, :name, :email]

    unless expected_params.all? {|param| params.has_key?(param)}
      render json: "Illegal member, missing parameters", status: 400 and return
    end
    
    member = Member.new
    member.uuid = params[:uuid]
    member.name = params[:name]
    member.email = params[:email]

    if member.save
      @member = ApiV1::MemberPresenter.new(member)
      render json: @member, content_type: "application/json", status: 201, location: api_v1_member_url(member)
    else 
      if member.errors[:uuid].include?("has already been taken")
        render json: "Duplicate member", status: 409
      else 
        render json: "Invalid member", status: 400
      end
    end
  end

  def update
    # Note: This will ignore any changes in the json to the uuid and name
    #       Not sure if we want to mark those as invalid requests or what
    member = Member.find_by_uuid!(params[:uuid])
    member.email = params[:email]

    if member.changed? && member.save
      render json: ApiV1::MemberPresenter.new(member), status: 200
    else
      render json: {message: "Bad Parameters", errors: member.errors.messages}, status: 400 and return
    end
  end

  def destroy
    if Rails.env.production?
      render nothing: true, status: 403 and return
    end

    member = Member.find_by_uuid!(params[:uuid])
    member.destroy!
    render nothing: true, status: 204
  end

end

class MembersController < ApplicationController
  include Authenticate
  include Pagination
  include Adaptation

  local_node_only :create, :update, :destroy
  uses_pagination :index
  adapt!

  def index
    @members = Member.with_name(params[:name])
      .with_email(params[:email])
      .order(parse_ordering(params[:order_by]))
      .page(@page)
      .per(@page_size)

    render "shared/index", status: 200
  end


  def show
    @member = Member.find_by_member_id!(params[:member_id])
    render "shared/show", status: 200
  end


  def create
    if params[:member_id] && Member.find_by_member_id(params[:member_id]).present?
      render nothing: true, status: 409 and return
    else
      @member = Member.new(create_params(params))
      if @member.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @member = Member.find_by_member_id!(params[:member_id])

    @member.attributes = update_params(params)
    if @member.save
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end
  end


  def destroy
    member = Member.find_by_member_id!(params[:member_id])
    member.destroy!
    render nothing: true, status: 204
  end


  private
  def create_params(params)
    params.permit(Member.attribute_names)
  end

  def update_params(params)
    create_params(params)
  end

end

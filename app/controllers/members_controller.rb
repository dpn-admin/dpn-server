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
    @member = Member.find_by_uuid!(params[:uuid])
    render "shared/show", status: 200
  end


  def create
    if params[:uuid] && Member.find_by_uuid(params[:uuid]).present?
      render nothing: true, status: 409 and return
    else
      @member = Member.new(permitted_params)
      if @member.save
        render "shared/create", status: 201
      else
        render "shared/errors", status: 400
      end
    end
  end


  def update
    @member = Member.find_by_uuid!(params[:uuid])

    @member.attributes = permitted_params
    if @member.save
      render "shared/update", status: 200
    else
      render "shared/errors", status: 400
    end
  end


  def destroy
    member = Member.find_by_uuid!(params[:uuid])
    member.destroy!
    render nothing: true, status: 204
  end


  private
  def permitted_params
    params.permit(Member.attribute_names)
  end


end

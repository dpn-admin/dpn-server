# Copyright (c) 2015 The Regents of the University of Michigan.
# All Rights Reserved.
# Licensed according to the terms of the Revised BSD License
# See LICENSE.md for details.

# Requires a passed block that includes
# let(:existing_record) { the_existing_record }

shared_examples "a successful update" do 
  it "responds with 200" do
    expect(response).to have_http_status(200)
  end
  it "updates the record" do
    expect(existing_record.updated_at.to_s).to_not eql(existing_record.reload.updated_at.to_s)
  end
  it "assigns the correct object to @#{factory}" do
    expect(assigns(factory)).to be_an existing_record.class
    expect(assigns(factory).id).to eql(existing_record.id)
  end
  it "renders json" do
    expect(response.content_type).to eql("application/json")
  end
  it "renders the create template" do
    expect(response).to render_template(:update)
  end
end

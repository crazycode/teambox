require 'spec_helper'

describe ApiV1::UploadsController do
  before do
    make_a_typical_project
    
    @upload = @project.uploads.new({:asset => mock_uploader('semicolons.js', 'application/javascript', "alert('what?!')")})
    @upload.user = @user
    @upload.save!
    
    @page_upload = mock_file(@user, Factory.create(:page, :project_id => @project.id))
    @page = @page_upload.page
  end
  
  describe "#index" do
    it "shows uploads in the project" do
      login_as @user
      
      get :index, :project_id => @project.permalink
      response.should be_success
      
      JSON.parse(response.body).length.should == 2
    end
    
    it "shows uploads on a page" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :page_id => @page.id
      response.should be_success
      
      content = JSON.parse(response.body)
      p content
      content.length.should == 1
      content.first['id'].should == @page_upload.id
    end
    
    it "limits uploads" do
      login_as @user
      
      get :index, :project_id => @project.permalink, :count => 1
      response.should be_success
      
      JSON.parse(response.body).length.should == 1
    end
    
    it "limits and offsets uploads" do
      login_as @user
      
      other_upload = mock_file(@user, @page)
      
      get :index, :project_id => @project.permalink, :since_id => @project.reload.upload_ids[0], :count => 1
      response.should be_success
      
      JSON.parse(response.body).map{|a| a['id'].to_i}.should == [@project.reload.upload_ids[1]]
    end
  end
  
  describe "#show" do
    it "shows an upload" do
      login_as @user
      
      get :show, :project_id => @project.permalink, :id => @upload.id
      response.should be_success
      
      JSON.parse(response.body)['id'].to_i.should == @upload.id
    end
  end
  
  describe "#create" do
    it "should allow participants to create uploads" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :upload => mock_file_params
      response.should be_success
      
      @project.uploads(true).length.should == 3
    end
    
    it "should insert uploads at the top of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :upload => mock_file_params,
           :position => {:slot => 0, :before => true}
      response.should be_success
      
      uid = JSON.parse(response.body)['id']
      @page.slots(true).first.rel_object.id.should == uid
    end
    
    it "should insert uploads at the footer of a page" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :upload => mock_file_params,
           :position => {:slot => -1}
      response.should be_success
      
      uid = JSON.parse(response.body)['id']
      @page.slots(true).last.rel_object.id.should == uid
    end
    
    it "should insert uploads before an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :upload => mock_file_params,
           :position => {:slot => @page_upload.page_slot.id, :before => 1}
      response.should be_success
      
      uid = JSON.parse(response.body)['id']
      @page.uploads.find_by_id(uid).page_slot.position.should == @page_upload.page_slot.reload.position-1
    end
    
    it "should insert uploads after an existing widget" do
      login_as @user
      
      post :create,
           :project_id => @project.permalink,
           :page_id => @page.id,
           :upload => mock_file_params,
           :position => {:slot => @page_upload.page_slot.id, :before => 0}
      response.should be_success
      
      uid = JSON.parse(response.body)['id']
      @page.uploads.find_by_id(uid).page_slot.position.should == @page_upload.page_slot.reload.position+1
    end
    
    it "should not allow observers to create uploads" do
      login_as @observer
      
      post :create,
           :project_id => @project.permalink,
           :upload => mock_file_params
      response.status.should == '401 Unauthorized'
      
      @project.uploads(true).length.should == 2
    end
  end
  
  describe "#destroy" do
    it "should allow participants to destroy an upload" do
      login_as @user
      
      put :destroy, :project_id => @project.permalink, :id => @upload.id
      response.should be_success
      
      @project.uploads(true).length.should == 1
    end
    
    it "should not allow observers to destroy an upload" do
      login_as @observer
      
      put :destroy, :project_id => @project.permalink, :id => @upload.id
      response.status.should == '401 Unauthorized'
      
      @project.uploads(true).length.should == 2
    end
  end
end
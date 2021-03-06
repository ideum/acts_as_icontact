require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ActsAsIcontact::List do
  it "requires name, emailOwnerOnChange, welcomeOnManualAdd, welcomeOnSignupAdd, welcomeMessageId" do
    l = ActsAsIcontact::List.new
    lambda{l.save}.should raise_error(ActsAsIcontact::ValidationError, "Missing required fields: name, emailOwnerOnChange, welcomeOnManualAdd, welcomeOnSignupAdd, welcomeMessageId")
  end
  
  it "uses true and false to assign boolean fields" do
    l = ActsAsIcontact::List.new
    l.emailOwnerOnChange = true
    l.welcomeOnSignupAdd = false
    l.instance_variable_get(:@properties)["emailOwnerOnChange"].should == 1
    l.instance_variable_get(:@properties)["welcomeOnSignupAdd"].should == 0
  end

  it "uses true and false to retrieve boolean fields" do
    l = ActsAsIcontact::List.new
    l.instance_variable_set(:@properties,{"welcomeOnManualAdd" => 1, "emailOwnerOnChange" => 0})
    l.emailOwnerOnChange.should be_false
    l.welcomeOnManualAdd.should be_true
  end
  
  it "can find a list by name" do
    l = ActsAsIcontact::List.find("First Test")
    l.id.should == 444444
  end
  
  context "associations" do
    # Create one good list
    before(:each) do
      @list = ActsAsIcontact::List.first(:name => "First Test")
    end
    
    it "knows its subscribers" do
      @list.subscribers.first.should == ActsAsIcontact::Contact.find(333444)
      @list.subscribers.next.should == ActsAsIcontact::Contact.find(333333)
    end
    
    it "knows its welcome message" do
      @list.welcomeMessage.should == ActsAsIcontact::Message.find(555555)
    end
    
    it "can be subscribed to by a subscriber" do
      conn = mock('Class Connection')
      conn.expects(:post).with(regexp_matches(/444444/) && regexp_matches(/333333/)).returns('{"subscriptions":{}}')
      ActsAsIcontact::Subscription.expects(:connection).returns(conn)
      @list.subscribe(333333)
    end
      
  end
end
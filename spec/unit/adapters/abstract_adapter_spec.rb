require 'monitor'
require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'adapters', 'adapter_shared_spec'))

describe DataMapper::Adapters::AbstractAdapter do

  before do
    @adapter = DataMapper::Adapters::AbstractAdapter.new(:default, 'mock_uri_string')
  end

  it_should_behave_like 'a DataMapper Adapter'

  describe "when handling transactions" do
    before :each do
      @transaction = DataMapper::Transaction.new(@adapter)
    end
    it "should be able to push and pop transactions on the current stack" do
      @adapter.current_transaction.should == nil
      @adapter.within_transaction?.should == false
      @adapter.push_transaction(@transaction)
      @adapter.current_transaction.should == @transaction
      @adapter.within_transaction?.should == true
      @adapter.push_transaction(@transaction)
      @adapter.current_transaction.should == @transaction
      @adapter.within_transaction?.should == true
      @adapter.pop_transaction
      @adapter.current_transaction.should == @transaction
      @adapter.within_transaction?.should == true
      @adapter.pop_transaction
      @adapter.current_transaction.should == nil
      @adapter.within_transaction?.should == false
    end
    it "should let each Thread have its own transaction stack" do
      lock = Monitor.new
      transaction2 = DataMapper::Transaction.new(@adapter)
      @adapter.within_transaction?.should == false
      @adapter.current_transaction.should == nil
      @adapter.push_transaction(transaction2)
      @adapter.within_transaction?.should == true
      @adapter.current_transaction.should == transaction2
      lock.synchronize do
        Thread.new do
          @adapter.within_transaction?.should == false
          @adapter.current_transaction.should == nil
          @adapter.push_transaction(@transaction)
          @adapter.within_transaction?.should == true
          @adapter.current_transaction.should == @transaction
          lock.synchronize do
            @adapter.within_transaction?.should == true
            @adapter.current_transaction.should == @transaction
            @adapter.pop_transaction
            @adapter.within_transaction?.should == false
            @adapter.current_transaction.should == nil
          end
        end
        @adapter.within_transaction?.should == true
        @adapter.current_transaction.should == transaction2
        @adapter.pop_transaction
        @adapter.within_transaction?.should == false
        @adapter.current_transaction.should == nil
      end
    end
  end

  it "should raise NotImplementedError when #create is called" do
    lambda { @adapter.create(:repository, :instance) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #transaction_primitive is called" do
    lambda { @adapter.transaction_primitive }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #read is called" do
    lambda { @adapter.read(:repository, :resource, [:key]) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #update is called" do
    lambda { @adapter.update(:repository, :instance) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #delete is called" do
    lambda { @adapter.delete(:repository, :instance) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #read_one is called" do
    lambda { @adapter.read_one(:repository, :query) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #read_set is called" do
    lambda { @adapter.read_set(:repository, :query) }.should raise_error(NotImplementedError)
  end

  it "should raise NotImplementedError when #delete_set is called" do
    lambda { @adapter.delete_set(:repository, :query) }.should raise_error(NotImplementedError)
  end

end

#require File.dirname(File.expand_path(__FILE__)) + '/spec_helper.rb'

require File.dirname(__FILE__) + '/spec_helper'

class Comment < TinyDS::Base
  #property :ekey, String, :key=>true
  property :num,        :integer
  property :title,      :string
  property :body,       :text
  property :flag,       :integer, :default=>5
  property :new_at,     :time,    :default=>proc{ Time.now }
  property :updated_at, :time
  property :created_at, :time
  property :view_at,    :time
end

class Animal < TinyDS::Base
  property :nickname,   :string
  property :color,      :string
end

class User < TinyDS::Base
  property :nickname,   :string
  property :age,        :integer
  property :favorites,  :list
end

describe TinyDS::Base do
  before :all do
    AppEngine::Testing.install_test_env
    AppEngine::Testing.install_test_datastore
  end

  it "should return class name as kind" do
    Comment.kind.should == "Comment"
  end

  #describe "tx" do
  #  # todo
  #end

  describe :property_definitions do
    it "should convert to Text" do
      text = Comment.property_definitions[:body].to_ds_value("x"*1024)
      text.class.should == com.google.appengine.api.datastore.Text
    end
    it "should correct properties count" do
      Comment.property_definitions.size.should == 8
    end
    it "should initialized with default value" do
      a = Comment.new
      a.flag.should == 5
    end
    it "should default by proc" do
      a = Comment.new
      (Time.now-a.new_at).should <= 2.0
    end
  end

  describe "key" do 
    it "should be got id/name" do
      k1 = AppEngine::Datastore::Key.from_path("Com", 9999)
      a1 = Comment.create({:title=>"ccccc"}, :key=>k1)
      a1.key.inspect.should == "Com(9999)"
      a1.id.should   == 9999
      a1.name.should == nil

      k2 = AppEngine::Datastore::Key.from_path("Com", "9999")
      a2 = Comment.create({:title=>"ccccc"}, :key=>k2)
      a2.key.inspect.should == 'Com("9999")'
      a2.name.should == "9999"
      a2.id.should   == 0
    end
  end

  describe 'create' do
    it "should be saved" do
      a1 = Comment.create(:num=>123, :title=>"hey")

      a2 = Comment.get(a1.key)
      a2.num.should == a1.num
      a2.num.should == 123
      a2.title.should == a1.title
      a2.title.should == "hey"
    end
    it 'should support Text' do
      a1 = Comment.new(:body => "a"*1024)
      a1.save

      a2 = Comment.get(a1.key)
      a2.body.should == "a"*1024
      a2.body.should == a1.body
    end
    it "should support opts[:parent]" do
      a1 = Comment.create({:title=>"ppppp"})
      a2 = Comment.create({:title=>"ccccc"}, :parent=>a1)

      a1 = Comment.get(a1.key)
      a2 = Comment.get(a2.key)
      a2.parent_key.should == a1.key
    end
    it "should support opts[:key]" do
      k1 = AppEngine::Datastore::Key.from_path("Com", 9999)
      a1 = Comment.create({:title=>"ccccc"}, :key=>k1)
      a1.key.inspect.should == "Com(9999)"

      k2 = AppEngine::Datastore::Key.from_path("Com", "9999")
      a2 = Comment.create({:title=>"ccccc"}, :key=>k2)
      a2.key.inspect.should == 'Com("9999")'
    end
    it "should support opts[:id]" do
      a1 = Comment.create({:title=>"ccccc"}, :id=>99999)
      a1.key.inspect.should == 'Comment(99999)'
    end
    it "should support opts[:name]" do
      a1 = Comment.create({:title=>"ccccc"}, :name=>"hello")
      a1.key.inspect.should == 'Comment("hello")'
    end
    it "should support opts[:parent] + opts[:name]" do
      a1 = Comment.create({:title=>"aaaaa"}, :id=>456789)
      a2 = Comment.create({:title=>"ccccc"}, {:parent=>a1, :name=>"hey"})
      a2.key.inspect.should == 'Comment(456789)/Comment("hey")'
    end
    it "should not be new_record" do
      c = Comment.create
      c.new_record?.should_not be_true
    end
  end

  describe "new" do
    it "should keep unsaved attrs" do
      a1 = Comment.new({:title=>"aaa", :num=>444, :body=>"x"*2000})
      a1.title.should == "aaa"
      a1.num.should   == 444
      a1.body.should  == "x"*2000
    end
    it "should be nil" do
      c1 = Comment.new
      c1.title.should == nil
      c1.num.should   == nil
      c1.body.should  == nil
      c1.updated_at.should == nil
      c1.created_at.should == nil

      c2 = Comment.create
      c2.title.should == nil
      c2.num.should   == nil
      c2.body.should  == nil
      c2.updated_at.should be_a_kind_of(Time)
      c2.created_at.should be_a_kind_of(Time)

      c3 = Comment.get(c2.key)
      c3.title.should == nil
      c3.num.should   == nil
      c3.body.should  == nil
      c3.updated_at.should be_a_kind_of(Time)
      c3.created_at.should be_a_kind_of(Time)
    end
    it "should be new_record" do
      c = Comment.new
      c.new_record?.should be_true
    end
  end

  describe "new_from_entity" do
    it "should build from low-entity" do
      ent = Comment.create({:title=>"aaa", :num=>444, :body=>"x"*2000}).entity

      a1 = Comment.new_from_entity(ent)
      a1.title.should == "aaa"
      a1.num.should   == 444
      a1.body.should  == "x"*2000
    end
    it "should not be new_record" do
      ent = Comment.create({:title=>"aaa", :num=>444, :body=>"x"*2000}).entity
      c = Comment.new_from_entity(ent)
      c.new_record?.should_not be_true
    end
  end

  describe "get" do
    it "should saved" do
      k1 = Comment.create({:title=>"aaa", :num=>444, :body=>"x"*2000}).key
      a1 = Comment.get(k1)
      a1.title.should == "aaa"
      a1.num.should   == 444
      a1.body.should  == "x"*2000
    end
    it "should not be new_record" do
      k1 = Comment.create({}).key
      a1 = Comment.get(k1)
      a1.new_record?.should_not be_true
    end
    it "should be got by id" do
      k1 = Comment.create({}).key

      a1 = Comment.get_by_id(k1.id)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_id(k1.id.to_s)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_id(k1.id+1)
      a1.should be_nil

      a1 = Comment.get_by_id!(k1.id)
      a1.key.to_s.should == k1.to_s
      proc{ Comment.get_by_id!(k1.id+1) }.should raise_error(AppEngine::Datastore::EntityNotFound)

      proc{ Comment.get_by_id!("a") }.should raise_error
    end
    it "should be got by name" do
      k1 = Comment.create({}, :name=>"asdfg").key

      a1 = Comment.get_by_name(k1.name)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_name(k1.name+"x")
      a1.should be_nil

      a1 = Comment.get_by_name!(k1.name)
      a1.key.to_s.should == k1.to_s
      proc{ Comment.get_by_name!(k1.name+"x") }.should raise_error(AppEngine::Datastore::EntityNotFound)

      proc{ Comment.get_by_name!(1) }.should raise_error
    end
    it "should be got by id+parent" do
      c0 = Comment.create
      k1 = Comment.create({}, :parent=>c0).key

      a1 = Comment.get_by_id(k1.id, c0)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_id(k1.id.to_s, c0)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_id(k1.id)
      a1.should be_nil
      a1 = Comment.get_by_id(k1.id+1, c0)
      a1.should be_nil

      a1 = Comment.get_by_id!(k1.id, c0)
      a1.key.to_s.should == k1.to_s
      proc{ Comment.get_by_id!(k1.id)       }.should raise_error(AppEngine::Datastore::EntityNotFound)
      proc{ Comment.get_by_id!(k1.id+1, c0) }.should raise_error(AppEngine::Datastore::EntityNotFound)
    end
    it "should be got by name+parent" do
      c0 = Comment.create
      k1 = Comment.create({}, :parent=>c0, :name=>"zzz").key

      a1 = Comment.get_by_name(k1.name, c0)
      a1.key.to_s.should == k1.to_s
      a1 = Comment.get_by_name(k1.name)
      a1.should be_nil
      a1 = Comment.get_by_name(k1.name+"x", c0)
      a1.should be_nil

      a1 = Comment.get_by_name!(k1.name, c0)
      a1.key.to_s.should == k1.to_s
      proc{ Comment.get_by_name!(k1.name)         }.should raise_error(AppEngine::Datastore::EntityNotFound)
      proc{ Comment.get_by_name!(k1.name+"x", c0) }.should raise_error(AppEngine::Datastore::EntityNotFound)
    end
  end

  describe "save" do
    it "should updated" do
      a1 = Comment.create({:title=>"aaa", :num=>444, :body=>"x"*2000})
      k1 = a1.key
      a1.title.should == "aaa"
      a1.num.should   == 444
      a1.body.should  == "x"*2000

      a1.title = "bbb"
      a1.num   = 666
      a1.body  = "y"*4000
      a1.save

      a1.title.should == "bbb"
      a1.num.should   == 666
      a1.body.should  == "y"*4000

      a1 = Comment.get(k1)
      a1.title.should == "bbb"
      a1.num.should   == 666
      a1.body.should  == "y"*4000
    end
    it "should not be new_record after save" do
      a1 = Comment.new(:title=>"zzzz")
      a1.new_record?.should be_true

      a1.save
      a1.new_record?.should be_false

      a1 = Comment.get(a1.key)
      a1.new_record?.should be_false

      a1 = Comment.query.filter(:title, "==", "zzzz").one
      a1.new_record?.should be_false
    end
  end

  describe "auto convert types" do
    it "should convert to string" do
      Comment.new(:title => "zzzz").title.should be_kind_of(String)
      Comment.new(:title => "zzzz").title.should == "zzzz"
      Comment.new(:title => 123   ).title.should be_kind_of(String)
      Comment.new(:title => 123   ).title.should == "123"
      Comment.new(:title => "123" ).title.should be_kind_of(String)
      Comment.new(:title => "123" ).title.should == "123"
      Comment.new(:title => nil   ).title.should be_kind_of(NilClass)
      Comment.new(:title => nil   ).title.should == nil
      Comment.new(                ).title.should be_kind_of(NilClass)
      Comment.new(                ).title.should == nil
    end
    it "should convert to integer" do
      Comment.new(:num => "zzzz").num.should be_kind_of(Integer)
      Comment.new(:num => "zzzz").num.should == 0
      Comment.new(:num => 123   ).num.should be_kind_of(Integer)
      Comment.new(:num => 123   ).num.should == 123
      Comment.new(:num => "123" ).num.should be_kind_of(Integer)
      Comment.new(:num => "123" ).num.should == 123
      Comment.new(:num => nil   ).num.should be_kind_of(NilClass)
      Comment.new(:num => nil   ).num.should == nil
      Comment.new(              ).num.should be_kind_of(NilClass)
      Comment.new(              ).num.should == nil
    end
    it "should convert to text" do
      Comment.new(:body => "zzzz").body.should be_kind_of(String)
      Comment.new(:body => "zzzz").body.should == "zzzz"
      Comment.new(:body => 123   ).body.should be_kind_of(String)
      Comment.new(:body => 123   ).body.should == "123"
      Comment.new(:body => "123" ).body.should be_kind_of(String)
      Comment.new(:body => "123" ).body.should == "123"
      Comment.new(:body => nil   ).body.should be_kind_of(NilClass)
      Comment.new(:body => nil   ).body.should == nil
      Comment.new(               ).body.should be_kind_of(NilClass)
      Comment.new(               ).body.should == nil
    end
    it "should not convert from str/int to time" do
      proc{ Comment.new(:view_at => "zzzz"  ) }.should raise_error
      proc{ Comment.new(:view_at => 123     ) }.should raise_error

      now = Time.now
      Comment.new(:view_at => now).view_at.should == now
      Comment.new(:view_at => nil).view_at.should == nil
      Comment.new(               ).view_at.should == nil
    end
    it "should not convert to array" do
      proc{ User.new(:favorites => "zzzz"  ) }.should raise_error
      proc{ User.new(:favorites => 123     ) }.should raise_error
    end
  end

  describe "query(1) basic" do
    before :all do
      Comment.destroy_all
      raise if Comment.count!=0
      3.times do
        Comment.create(:num=>10, :title=>"BBB")
      end
      5.times do
        Comment.create(:num=>10, :title=>"AAA")
      end
      7.times do
        Comment.create(:num=>50, :title=>"AAA")
      end
    end
    it "should fetched all" do
      Comment.query.count.should == 15
      Comment.query.keys.size.should == 15
      Comment.query.keys.each do |k|
        k.should be_a_kind_of(AppEngine::Datastore::Key)
      end
    end
    it "should fetched by eq" do
      Comment.query.filter(:num,   "==", 10).count.should == 8
      Comment.query.filter(:title, "==", "AAA").all.size.should == 12
      Comment.query.filter(:num,   "==", 10).filter(:title, "==", "AAA").all.size.should == 5
    end
    it "should fetched by eq (hash)" do
      Comment.query.filter(:num=>10).count.should == 8
      Comment.query.filter(:title=>"AAA").all.size.should == 12
      Comment.query.filter(:num=>10).filter(:title=>"AAA").all.size.should == 5
      Comment.query.filter(:num=>10, :title=>"AAA").all.size.should == 5
    end
    it "should fetched by gt/lt" do
      Comment.query.filter(:num, ">=", 20).count.should == 7
      Comment.query.filter(:num, "<=", 20).count.should == 8
      Comment.query.filter(:num, ">=", 20).all.all?{|c| c.num==50 }.should be_true
      Comment.query.filter(:num, "<=", 20).all.all?{|c| c.num==10 }.should be_true
    end
    it "should be sorted" do
      comments = Comment.query.sort(:title).sort(:num).all
      comments[ 0, 5].all?{|c| c.title=="AAA" && c.num==10 }.should be_true
      comments[ 5, 7].all?{|c| c.title=="AAA" && c.num==50 }.should be_true
      comments[12, 3].all?{|c| c.title=="BBB" && c.num==10 }.should be_true

      comments = Comment.query.sort(:num).sort(:title).all
      comments[ 0, 5].all?{|c| c.num==10 && c.title=="AAA" }.should be_true
      comments[ 5, 3].all?{|c| c.num==10 && c.title=="BBB" }.should be_true
      comments[ 8, 7].all?{|c| c.num==50 && c.title=="AAA" }.should be_true
    end
    it "should be limited/offseted" do
      Comment.query.sort(:title).sort(:num).all(:limit=>5).each do |c|
        c.title.should == "AAA"; c.num.should == 10
      end
      Comment.query.sort(:title).sort(:num).all(:offset=>5, :limit=>7).each do |c|
        c.title.should == "AAA"; c.num.should == 50
      end
    end
    it "should not indexed nil as exist value" do
      Comment.destroy_all
      Comment.create(:num=>nil)
      Comment.create(         )
      Comment.count.should == 2
      Comment.query.filter(:num, "<", 0).count.should == 0
    end
  end
  describe "query(2) parent-children" do
    before :all do
      Comment.destroy_all
      raise if Comment.count!=0
      gparent = Comment.create(:title=>"GP")
      parent  = Comment.create({:title=>"P"}, {:parent=>gparent})
      child1  = Comment.create({:title=>"C1", :num=>10}, {:parent=>parent})
      child2  = Comment.create({:title=>"C2", :num=>10}, {:parent=>parent})
      other1  = Comment.create({:title=>"O1"})
      other2  = Comment.create({:title=>"O1", :num=>10})
    end
    it "should fetched all" do
      Comment.query.count.should == 6
    end
    it "should fetch only keys" do
      Comment.query.keys_only.all.all?{|m|
        m.key != nil && m.title==nil
      }.should be_true
      Comment.query.all.all?{|m|
        m.key != nil && m.title!=nil
      }.should be_true
    end
    it "should fetched only children" do
      parent = Comment.query.filter(:title, "==", "P").one
      Comment.query.ancestor(parent).count.should == 3
      Comment.query.ancestor(parent).each{|c| # [P,C1,C2]
        c.key.inspect.index(parent.key.inspect).should == 0
        if c.key!=parent.key
          c.parent_key.to_s.should == parent.key.to_s
        end
      }
      Comment.query.                     filter(:num, "==", 10).count.should == 3
      Comment.query.ancestor(parent).filter(:num, "==", 10).count.should == 2
      Comment.query.ancestor(parent).filter(:num, "==", 10).each{|c| # [C1,C2]
        c.key.inspect.index(parent.key.inspect).should == 0
        c.parent_key.to_s.should == parent.key.to_s
        c.title.should match(/^C/)
      }
    end
  end
  describe "query(3) raise" do
    before :all do
      Comment.destroy_all
      raise if Comment.count!=0
      child1  = Comment.create({:title=>"C1", :num=>10})
      child2  = Comment.create({:title=>"C2", :num=>10})
    end
    it "should raise error from one" do
      proc{
        Comment.query.one
      }.should      raise_error(AppEngine::Datastore::TooManyResults)
      proc{
        Comment.query.filter(:num, "==", 10).one
      }.should     raise_error(AppEngine::Datastore::TooManyResults)
      proc{
        Comment.query.filter(:title, "==", "C1").one
      }.should_not raise_error(AppEngine::Datastore::TooManyResults)
    end
    it "should be raised if filter/sort by invalid property name" do
      proc{
        Comment.query.filter(:aaaa, "==", 123)
      }.should raise_error
      proc{
        Comment.query.sort(:bbbb)
      }.should raise_error
    end
  end

  describe "count" do
    it "should incr 1" do
      c0 = Comment.count
      a1 = Comment.create
      c1 = Comment.count
      c1.should == c0+1
    end
    it "should not incr" do
      c0 = Comment.count
      a1 = Comment.new
      c1 = Comment.count
      c1.should == c0
    end
  end
  describe "#destroy" do
    it "should deleted" do
      k1 = Comment.create({:title=>"aaa", :num=>444, :body=>"x"*2000}).key
      a1 = Comment.get(k1)
      a1.title.should == "aaa"

      a1.destroy

      a1 = Comment.get(k1)
      a1.should be_nil

      proc{
        Comment.get!(k1)
      }.should raise_error(AppEngine::Datastore::EntityNotFound)
    end
  end
  describe ".destroy" do
    it "should deleted " do
       5.times{ Comment.create(:num=>10) }
      10.times{ Comment.create(:num=>20) }
      20.times{ Comment.create(:num=>30) }

      Comment.count.should == 35
      Comment.destroy(Comment.query.keys_only.filter(:num, "==", 10).all)
      Comment.count.should == 30
      Comment.destroy(Comment.query.keys_only.filter(:num, "==", 20).collect{|c| c.key })
      Comment.count.should == 20
      Comment.destroy(Comment.query.keys_only.filter(:num, "==", 30).collect{|c| c.key.to_s })
      Comment.count.should == 0
    end
  end
  describe "destroy_all" do
    it "should destroied all" do
      c1 = Comment.create
      c2 = Comment.create
      Comment.count.should == 2
      Comment.destroy_all
      Comment.count.should == 0
    end
  end
  describe "attributes=" do
    it "should set attrs" do
      a1 = Comment.new
      a1.attributes = {:title=>"x", :num=>3, :body=>"h"*3000}
      a1.title.should == "x"
      a1.num.should   == 3
      a1.body.should  == "h"*3000
    end
  end
  describe "set/get property" do
    it "should set/get" do
      a1 = Comment.new
      a1.title = "EEE"
      a1.title.should == "EEE"
      a1.body  = "XXX"
      a1.body.should  == "XXX"
      a1.num = 777
      a1.num.should == 777
    end
  end
  describe "list property" do
    before :each do
      User.destroy_all
      raise if User.count!=0
    end
    it "should stored list of values" do
      u1 = User.new(:favorites=>["car", "dog", 777])
      u1.favorites.size.should == 3
      u1.favorites.should     include("car")
      u1.favorites.should     include("dog")
      u1.favorites.should     include(777)
      u1.favorites.should_not include(666)

      u1.save
      u1.favorites.size.should == 3
      u1.favorites.should     include("car")
      u1.favorites.should     include("dog")
      u1.favorites.should     include(777)
      u1.favorites.should_not include(666)

      u1 = User.get(u1.key)
      u1.favorites.size.should == 3
      u1.favorites.should     include("car")
      u1.favorites.should     include("dog")
      u1.favorites.should     include(777)
      u1.favorites.should_not include(666)
    end
    it "should raise if not array" do
      proc{
        User.create(:favorites=>"car")
      }.should raise_error
    end
    it "should found by array item query eq" do
      u1 = User.create(:favorites=>["car", "dog", 777])
      u2 = User.create(:favorites=>[       "dog", 777])
      u3 = User.create(:favorites=>["car",        777])
      u4 = User.create(:favorites=>["car", "dog"     ])
      u5 = User.create(:favorites=>["car"            ])
      u6 = User.create(:favorites=>[       "dog"     ])
      u7 = User.create(:favorites=>[              777])
      User.query.filter(:favorites=>"car").all.size.should == 4
      User.query.filter(:favorites=>"dog").all.size.should == 4
      User.query.filter(:favorites=> 777 ).all.size.should == 4
      User.query.filter(:favorites=>"777").all.size.should == 0
#      User.query.filter(:favorites=>"car", :favorites=>"dog").all.size.should == 2
#      User.query.filter(:favorites=>"dog", :favorites=> 777 ).all.size.should == 2
#      User.query.filter(:favorites=>"car", :favorites=> 777 ).all.size.should == 2
      User.query.filter(:favorites=>"car").filter(:favorites=>"dog").all.size.should == 2
      User.query.filter(:favorites=>"dog").filter(:favorites=> 777 ).all.size.should == 2
      User.query.filter(:favorites=>"car").filter(:favorites=> 777 ).all.size.should == 2
      User.query.filter(:favorites=>"car").filter(:favorites=>"dog").filter(:favorites=>777).all.size.should == 1
    end
    it "should be empty list or nil" do
      u0 = User.create()
      u1 = User.create(:favorites=>[])
      u2 = User.create(:favorites=>nil)
      User.query.filter(:favorites, "==", 0).count.should == 0
      User.query.filter(:favorites, "<=", 0).count.should == 0
      User.query.filter(:favorites, ">=", 0).count.should == 0

      User.new(:favorites=>[] ).favorites.should == []
      User.new(:favorites=>nil).favorites.should == []
      User.new(               ).favorites.should == []
    end
    it "should found by array item query range" do
      u0 = User.create(:favorites=>[          ])
      u1 = User.create(:favorites=>[10, 20, 30])
      u2 = User.create(:favorites=>[    20, 30])
      u3 = User.create(:favorites=>[10,     30])
      u4 = User.create(:favorites=>[10, 20    ])
      u5 = User.create(:favorites=>[10        ])
      u6 = User.create(:favorites=>[    20    ])
      u7 = User.create(:favorites=>[        30])

      User.query.filter(:favorites, ">=",  0).count.should == 7

      User.query.filter(:favorites, "<=", 10).count.should == 4
      User.query.filter(:favorites, "<",  10).count.should == 0
      User.query.filter(:favorites, ">=", 10).count.should == 7
      User.query.filter(:favorites, ">",  10).count.should == 6

      User.query.filter(:favorites, "<=", 15).count.should == 4
      User.query.filter(:favorites, "<",  15).count.should == 4
      User.query.filter(:favorites, ">=", 15).count.should == 6
      User.query.filter(:favorites, ">",  15).count.should == 6

      User.query.filter(:favorites, "<=", 20).count.should == 6
      User.query.filter(:favorites, "<",  20).count.should == 4
      User.query.filter(:favorites, ">=", 20).count.should == 6
      User.query.filter(:favorites, ">",  20).count.should == 4
    end
  end
end

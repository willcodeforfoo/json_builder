require 'spec_helper'

describe "JSONBuilder" do
  it "should be a valid with no nesting" do
    json_builder do
      def valid?
        true
      end
      
      name "Garrett Bjerkhoel"
      valid valid?
    end.should == '{"name": "Garrett Bjerkhoel", "valid": true}'
  end
  
  it "should support inline arrays" do
    json_builder do
      name "Garrett Bjerkhoel"
      email "me@garrettbjerkhoel.com"
      urls ["http://github.com", "http://garrettbjerkhoel.com"]
    end.should == '{"name": "Garrett Bjerkhoel", "email": "me@garrettbjerkhoel.com", "urls": ["http://github.com", "http://garrettbjerkhoel.com"]}'
  end
  
  it "should support all datatypes" do
    json_builder do
      integer 1
      mega_integer 100_000_000
      float 13.37
      true_class true
      false_class false
      missing_nil
    end.should == '{"integer": 1, "mega_integer": 100000000, "float": 13.37, "true_class": true, "false_class": false, "missing_nil": null}'
  end
  
  it "should support all dates" do
    json_builder do
      date Date.new(2011, 11, 23)
      date_time DateTime.new(2001, 2, 3, 4, 5, 6)
      timed Time.at(1322427883)
    end.should == '{"date": "2011-11-23", "date_time": "2001-02-03T04:05:06+00:00", "timed": "2011-11-27T13:04:43-08:00"}'
  end
  
  it "should support multiple nestings" do
    json_builder do
      users [1, 2] do |i|
        id i
        likes [1, 2] do |b|
          l b * i
          d "test" do |c|
            c * b
          end
        end
      end
    end.should == '{"users": [{"id": 1, "likes": [{"l": 1, "d": "test"}, {"l": 2, "d": "testtest"}]}, {"id": 2, "likes": [{"l": 2, "d": "test"}, {"l": 4, "d": "testtest"}]}]}'
  end
  
  it "should support custom key names" do
    json_builder do
      def with_method
        "nope"
      end
      
      key :custom_key, 1
      key :with_method, with_method
      key 'as_string', true
      nested do
        key "deep_down", -1
      end
      key with_method, "chuck"
    end.should == '{"custom_key": 1, "with_method": "nope", "as_string": true, "nested": {"deep_down": -1}, "nope": "chuck"}'
  end
  
  it "should support adding hash objects" do
    json_builder do
      hash_test :garrett => true, :london => "Test"
    end.should == '{"hash_test": {"garrett":true,"london":"Test"}}'
  end
  
  it "should support enumerating with each_with_index" do
    json_builder do
      people do
        [{:name => "Kevin"}, {:name => "Sam"}, {:name => "Keri"}].each_with_index do |person, i|
          key "person-#{i}" do
            first_name person[:name]
          end
        end
      end
    end.should == '{"people": {"person-0": {"first_name": "Kevin"}}, {"person-1": {"first_name": "Sam"}}, {"person-2": {"first_name": "Keri"}}}'
  end
end

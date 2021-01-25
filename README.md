# ProtoRecord

ProtoRecord provides a simple way to build Protocol buffer messages from ActiveRecord objects based on the stubs generated by protocol buffer compiler.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'proto_record'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install proto_record

## Usage

To make use of ProtoRecord you need have some messages defined in a `.proto` file and the stubs generated using using the protocol buffer compiler, for more information follow the [gRPC Ruby basic tutorial](https://grpc.io/docs/languages/ruby/basics).

For our exmpale we will use the following message:
```proto
message PathMessage {
  string name = 1;
  string description = 2;
}
```
With the stubs generated all you have to do is to include the `ProtoRecord` module and define a `proto_message` for your ActiveRecord object.
```ruby
class Path < ActiveRecord::Base
  include ProtoRecord

  # 'PathMessage' will be used when resolving the object.
  proto_message :path_message
end
```
After including the module and defining a mesasge, a `to_proto` method would be added to instances of `Path`. Calling `to_proto` will return a message of type `PathMessage` that is built from the instance using only the fields defined on the message. A very simple scenario would be getting getting all `Path`s from the DB and returning them as messages. This would look something like:
```ruby
Path.all.map(&:to_proto)
```

#### Nested Mesasge
ProtoRecord also resolves nested messages, so if we have the following schema:
```proto
message PathMessage {
  string name = 1;
  string description = 2;
  repeated FeatureMessage features = 3;
}

message FeatureMessage {
  string name = 1;
}
```
And relation defined like this:
```ruby
class Path < ActiveRecord::Base
  include ProtoRecord

  proto_message :path_message

  has_many :features
end

class Feature < ActiveRecord::Base
  include ProtoRecord

  # 'FeatureMessage' will be used when resolving the object.
  proto_message :feature_message

  belongs_to :path
end
```
Then invocking `to_proto` on an instance of `Path` will also create messages for all associated `features`.

#### Regular Classes
ProtoRecord will also handle the creation messages for non ActiveRecord objects that define a `proto_message`. The only differene is that you would need define a `fields_resolver` that will point to a method that returns a hash representation of the class which will be used to instantiate the message.
So with a message like this:
```proto
message PointMessage {
  int32 x = 1;
  int32 y = 2;
}
```
And class that implements `Point`:
```ruby
class Point
  include ProtoRecord

  # 'PointMessage' will be created with the hash returned form the `:to_h` method.
  proto_message :point_message, :fields_resolver => :to_h

  def initialize(x: nil, y: nil)
    @x = x
    @y = y
  end

  def to_h
    {
      x: @x,
      y: @y
    }
  end
end
```
In cases when you don't want to define a message for class (e.g the class just represents a repeated message), you can simply define a `to_proto` method which will be invoked when creating the message.
```ruby
class Points
  attr_reader :points

  def initialize(points: [])
    @points = points
  end

  def to_proto
    @points.map(&:to_proto)
  end
end
```
* Notice that you don't need to include `ProtoRecord` or define a `proto_message` in cases like this.

#### Dates
Protocol Buffer messages don't support sending dates, `ProtoRecord` will transform all types of dates into `Time` by calling `to_time` on them. In your `.proto` file you will need to add the following:
```proto
import "google/protobuf/timestamp.proto";

message ObjectWithDateMessage {
  google.protobuf.Timestamp created_at = 1;
}
```

## TODO
- [] Support custom field transformation.
- [] Add a `from_proto` for creating and updating records.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/proto_record. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/proto_record/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ProtoRecord project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/proto_record/blob/master/CODE_OF_CONDUCT.md).

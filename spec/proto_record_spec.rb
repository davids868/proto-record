# frozen_string_literal: true

require "spec_helper"

describe ProtoRecord do
  it "has a version number" do
    expect(ProtoRecord::VERSION).not_to be nil
  end

  describe "including ProtoRecord" do
    context "when not included" do
      it "shouldn't define proto_message on the class" do
        expect(Path).not_to respond_to(:proto_message)
      end

      it "shouldn't define to_proto on the instance" do
        expect(Path.new).not_to respond_to(:to_proto)
      end
    end

    context "when included" do
      before { Path.include(ProtoRecord) }

      it "should define proto_message on the class" do
        expect(Path).to respond_to(:proto_message)
      end

      it "should define to_proto on the instance" do
        expect(Path.new).to respond_to(:to_proto)
      end
    end
  end

  describe "proto_message" do
    before { Path.include(ProtoRecord) }

    context "when not defined" do
      it "should not have a proto_message" do
        expect(Path.proto_message).to eq(nil)
      end

      it "should raise an error when calling to_proto on an instance" do
        expect { Path.new.to_proto }.to raise_error(ProtoRecord::MissingProtoMessage)
      end
    end

    context "when defined" do
      let(:proto_message) { PathMessage }
      let(:classifiable_messages) { [PathMessage, :path_message, "PathMessage"] }

      before { Path.proto_message(proto_message) }

      it "should return the proto_message for all classifiable messages" do
        classifiable_messages.each do |message|
          Path.proto_message(message)
          expect(Path.proto_message).to eq(proto_message)
        end
      end

      it "should not raise an error when calling to_proto on an instance" do
        expect { Path.new.to_proto }.not_to raise_error
      end

      it "should return an empty hash when not provided" do
        expect(Path.proto_options).to eq({})
      end

      context "provided options to proto_message" do
        let(:options) { { fields_resolver: :to_h } }
        before { Path.proto_message(proto_message, options) }

        it "should return the provided options" do
          expect(Path.proto_options).to eq(options)
        end
      end
    end
  end

  describe "to_proto" do
    let(:path_proto_message) { PathMessage }
    let(:feature_proto_message) { FeatureMessage }
    let(:point_proto_message) { PointMessage }
    let(:point_proto_options) { { fields_resolver: :to_h } }
    let(:path_args) { { name: "Path to glory", description: "A very complicated path" } }
    let(:feature_args) { { name: "The feature" } }
    let(:point_args) { { x: 42, y: 13 } }

    let(:path) { Path.create(path_args) }
    let(:feature) { Feature.create(feature_args) }
    let(:point) { Point.new(**point_args) }

    before { Path.include(ProtoRecord) }
    before { Feature.include(ProtoRecord) }
    before { Point.include(ProtoRecord) }

    before { Path.proto_message(path_proto_message) }
    before { Feature.proto_message(feature_proto_message) }
    before { Point.proto_message(point_proto_message, point_proto_options) }

    context "resolving active record objects" do
      it "returns the correct message class" do
        expect(path.to_proto).to be_a(path_proto_message)
      end

      it "resolves the record attributes correctly" do
        expect(path.to_proto).to eq(path_proto_message.new(path_args))
      end
    end

    context "resolving nested messgaes" do
      it "resolves associations and class attributes recursively" do
        feature.update_attribute(:point, point_args)
        feature.update_attribute(:points, { points: [point] })
        path.update_attribute(:features, [feature])

        point_message = point_proto_message.new(point_args)
        feature_message = feature_proto_message.new(feature_args.merge(point: point_message, points: [point_message]))
        path_message = path_proto_message.new(path_args.merge(features: [feature_message]))

        expect(path.to_proto).to eq(path_message)
      end
    end

    context "resolving dates" do
      let(:path_with_timestamp_message) { PathWithTimestampsMessage }

      before { Path.proto_message(path_with_timestamp_message) }
      after { Path.proto_message(path_proto_message) }

      it "resolves the dates attributes correctly" do
        path_with_timestamp_args = { name: path[:name], created_at: path[:created_at].to_time }
        expect(path.to_proto).to eq(path_with_timestamp_message.new(path_with_timestamp_args))
      end
    end

    context "resolving regular classes" do
      it "shoud return message of the correct class" do
        expect(point.to_proto).to be_a(point_proto_message)
      end

      it "should throw an error if a regular class and fields_resolver is missing" do
        Point.proto_message(point_proto_message, {})
        expect { point.to_proto }.to raise_error(ProtoRecord::MissingFieldsResolver)
      end
    end

    context "resolving when to_proto defined without a message" do
      it "should return a resolved message based on to_proto implementation" do
        points = Points.new(points: [point])
        expect(points.to_proto).to eq [point_proto_message.new(point_args)]
      end
    end
  end
end

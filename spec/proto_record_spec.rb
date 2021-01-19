# frozen_string_literal: true

RSpec.describe ProtoRecord do
  it "has a version number" do
    expect(ProtoRecord::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end

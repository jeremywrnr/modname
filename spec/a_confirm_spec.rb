# frozen_string_literal: true

# Test confirm? method without override

require 'spec_helper'

describe 'Modder.confirm?' do
  it 'should return true for y input' do
    allow($stdin).to receive(:gets).and_return("y\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be true
  end

  it 'should return true for yes input' do
    allow($stdin).to receive(:gets).and_return("yes\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be true
  end

  it 'should return true for Y input' do
    allow($stdin).to receive(:gets).and_return("Y\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be true
  end

  it 'should return false for n input' do
    allow($stdin).to receive(:gets).and_return("n\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be false
  end

  it 'should return false for empty input' do
    allow($stdin).to receive(:gets).and_return("\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be false
  end

  it 'should return false for no input' do
    allow($stdin).to receive(:gets).and_return("no\n")
    allow($stdout).to receive(:write)
    expect(Modder.confirm?).to be false
  end
end

require 'spec_helper'

describe ApplicationHelper do
  describe "colorizes" do
    it "green a RUNNING state" do
      status = helper.colorize_state("RUNNING")
      status.should include("state-green")
    end

    it "orange a FLAPPING state" do
      status = helper.colorize_state("FLAPPING")
      status.should include("state-orange")
    end

    it "red a STOPPED state" do
      status = helper.colorize_state("STOPPED")
      status.should include("state-red")
    end
  end

  describe "returns a vendor" do
    it "image tag when vendor image exists" do
      image = helper.find_vendor_image("redis")
      image.should include("redis.png")
    end

    it "text when vendor image does not exists" do
      image = helper.find_vendor_image("DB2")
      image.should eql("DB2")
    end
  end

  describe "for an app returns" do
    it "a red N/A health when app info is empty" do
      app = {}
      health = helper.health(app)
      health.should include("state-red")
      health.should include("N/A")
    end

    it "a red STOPPED health when app state is STOPPED" do
      app = {}
      app[:state] = "STOPPED"
      health = helper.health(app)
      health.should include("state-red")
      health.should include("STOPPED")
    end

    it "a red 0% health when app state is STARTED and all instances are stopped" do
      app = {}
      app[:state] = "STARTED"
      app[:runningInstances] = 0
      app[:instances] = 2
      health = helper.health(app)
      health.should include("state-red")
      health.should include("0%")
    end

    it "an orange 50% health when app state is STARTED and half instances are running" do
      app = {}
      app[:state] = "STARTED"
      app[:runningInstances] = 1
      app[:instances] = 2
      health = helper.health(app)
      health.should include("state-orange")
      health.should include("Running at 50%")
    end

    it "a green RUNNING health when app state is STARTED and all instances are running" do
      app = {}
      app[:state] = "STARTED"
      app[:runningInstances] = 2
      app[:instances] = 2
      health = helper.health(app)
      health.should include("state-green")
      health.should include("RUNNING")
    end

    it "a red N/A health when app is RUNNING" do
      app = {}
      app[:state] = "RUNNING"
      app[:runningInstances] = 1
      app[:instances] = 1
      health = helper.health(app)
      health.should include("state-red")
      health.should include("N/A")
    end
  end

  describe "for an use and limit numbers" do
    it "returns a percentage" do
      pct = helper.pct(5.to_f, 10.to_f)
      pct.should eql(50.0)
    end
  end

  describe "returns a size formatted to" do
    it "bytes" do
      size = helper.pretty_size(1024 / 2)
      size.should eql("512 b")
    end

    it "Kilobytes" do
      size = helper.pretty_size((1024 * 1024) / 2)
      size.should eql("512.0 Kb")
    end

    it "Megabytes" do
      size = helper.pretty_size((1024 * 1024 * 1024) / 2)
      size.should eql("512.0 Mb")
    end

    it "Gigabytes" do
      size = helper.pretty_size(1024 * 1024 * 1024)
      size.should eql("1.0 Gb")
    end
  end

  describe "returns an uptime number" do
    it "formatted to days, hours, minutes, seconds" do
      uptime = helper.uptime_string(90061)
      uptime.should eql("1d:1h:1m:1s")
    end
  end
end
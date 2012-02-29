require 'spec_helper'

describe Utils do
  describe 'FiberedIterator' do
    describe 'each method' do
      it 'raises an exception when argument is not an array' do
        expect {
          results = []
          Utils::FiberedIterator.each("a") do |num|
            results.push num
          end
        }.to raise_exception(I18n.t('utils.argument_not_array'))
      end

      it 'can iterate an array NOT using EM and Fibers' do
        results = []
        Utils::FiberedIterator.each(1..5) do |num|
          results.push num
        end
        results.should == (1..5).to_a
        results.size.should == 5
      end

      it 'can iterate an array using EM and Fibers' do
        EM.synchrony do
          results = []
          Utils::FiberedIterator.each(1..5) do |num|
            results.push num
          end
          results.should == (1..5).to_a
          results.size.should == 5
          EM.stop
        end
      end

      it 'raises an exception when yielding from root fiber using EM and Fibers' do
        expect {
          EM.run do
            results = []
            Utils::FiberedIterator.each(1..5) do |num|
              results.push num
            end
            EM.stop
          end
        }.to raise_exception
      end

      it 'propagates an exception using EM and Fibers' do
        expect {
          EM.synchrony do
            Utils::FiberedIterator.each(1..5) do |num|
              raise "Error"
            end
            EM.stop
          end
        }.to raise_exception("Error")
      end
    end

    describe 'map method' do
      it 'raises an exception when argument is not an array' do
        expect {
          results = Utils::FiberedIterator.map("a") do |num|
            num
          end
        }.to raise_exception(I18n.t('utils.argument_not_array'))
      end

      it 'can iterate an array NOT using EM and Fibers' do
        results = Utils::FiberedIterator.map(1..5) do |num|
          num
        end
        results.should == (1..5).to_a
        results.size.should == 5
      end

      it 'can iterate an array using EM and Fibers' do
        EM.synchrony do
          results = Utils::FiberedIterator.map(1..5) do |num|
            num
          end
          results.should == (1..5).to_a
          results.size.should == 5
          EM.stop
        end
      end

      it 'raises an exception when yielding from root fiber using EM and Fibers' do
        expect {
          EM.run do
            results = Utils::FiberedIterator.map(1..5) do |num|
              num
            end
            EM.stop
          end
        }.to raise_exception
      end

      it 'propagates an exception using EM and Fibers' do
        expect {
          EM.synchrony do
            results = Utils::FiberedIterator.map(1..5) do |num|
              raise "Error"
            end
            EM.stop
          end
        }.to raise_exception("Error")
      end
    end
  end

  describe 'GitUtil' do
    describe 'git_binary method' do
      it 'can check if Git binary exists' do
        git_exists = Utils::GitUtil.git_binary()
        git_exists.should be_true
      end
    end

    describe 'git_clone method' do
      before(:each) do
        @gitrepo = "git://github.com/frodenas/cf-sinatra-sample.git"
        @gitbranch = "master"
        @repodir = Rails.root.join("tmp").join("app-bits").join("cf-sinatra-sample").to_s
      end

      after(:each) do
        FileUtils.rm_rf(@repodir, :secure => true)
      end

      it 'raises an exception when gitrepo is blank' do
        expect {
          Utils::GitUtil.git_clone("", @gitbranch, @repodir)
        }.to raise_exception(I18n.t('utils.gitrepo_blank'))
      end

      it 'raises an exception when gitbranch is blank' do
        expect {
          Utils::GitUtil.git_clone(@gitrepo, "", @repodir)
        }.to raise_exception(I18n.t('utils.gitbranch_blank'))
      end

      it 'raises an exception when repodir is blank' do
        expect {
          Utils::GitUtil.git_clone(@gitrepo, @gitbranch, "")
        }.to raise_exception(I18n.t('utils.repodir_blank'))
      end

      it 'can clone a Git repository NOT using EM' do
        Utils::GitUtil.git_clone(@gitrepo, @gitbranch, @repodir)
      end

      it 'can clone a Git repository using EM' do
        EM.synchrony do
          Utils::GitUtil.git_clone(@gitrepo, @gitbranch, @repodir)
          EM.stop
        end
      end
    end

    describe 'git_uri_valid? method' do
      it 'returns false if url is an invalid URI' do
        git_exists = Utils::GitUtil.git_uri_valid?("http:")
        git_exists.should be_false
      end

      it 'returns false if url is a valid Git URI repository' do
        git_exists = Utils::GitUtil.git_uri_valid?("http://github.com/user/repo.git")
        git_exists.should be_false
      end

      it 'returns true if url is a valid Git URI repository' do
        git_exists = Utils::GitUtil.git_uri_valid?("git://github.com/user/repo.git")
        git_exists.should be_true
      end
    end
  end

  describe 'ZipUtil' do
    describe 'pack_files method' do
      before(:each) do
        @zipfile = Rails.root.join("tmp").join("app-bits").join("cf-sinatra-sample.zip").to_s
        @file = Rails.root.join("spec").join("fixtures").join("cf-sinatra-sample.rb").to_s
        @files = [] << {:fn => @file, :zn => "cf-sinatra-sample.rb"}
      end

      after(:each) do
        FileUtils.rm_f(@zipfile)
      end

      it 'raises an exception when zipfile is blank' do
        expect {
          Utils::ZipUtil.pack_files("", @files)
        }.to raise_exception(I18n.t('utils.zipfile_blank'))
      end

      it 'raises an exception when argument is not an array' do
        expect {
          Utils::ZipUtil.pack_files(@zipfile, "cf-sinatra-sample.rb")
        }.to raise_exception(I18n.t('utils.argument_not_array'))
      end

      it 'raises an exception when files list is empty' do
        expect {
          Utils::ZipUtil.pack_files(@zipfile, [])
        }.to raise_exception(I18n.t('utils.files_empty'))
      end

      it 'can pack files NOT using EM defer block' do
        Utils::ZipUtil.pack_files(@zipfile, @files)
      end

      it 'can pack files using EM defer block' do
        EM.synchrony do
          Utils::ZipUtil.pack_files(@zipfile, @files)
          EM.stop
        end
      end

      it 'propagates an exception using EM and Fibers' do
        expect {
          @files = [] << {:fn => @file, :zn => "/cf-sinatra-sample.rb"}
          EM.synchrony do
            Utils::ZipUtil.pack_files(@zipfile, @files)
            EM.stop
          end
        }.to raise_exception(Zip::ZipEntryNameError)
      end
    end
  end
end
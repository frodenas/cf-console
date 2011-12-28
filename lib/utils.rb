module Utils
  module GitUtil
    def self.git_binary()
      git_binary = ENV['PATH'].split(':').map { |p| File.join(p, 'git') }.find { |p| File.exist?(p) } || nil
    end

    def self.git_clone(gitrepo, gitbranch, repodir)
      FileUtils.rm_rf(repodir, :secure => true)
      git_binary = git_binary()
      raise "Unable to find git binary." if git_binary.nil?
      stdout = `#{git_binary} --git-dir=#{repodir} clone --quiet --branch=#{gitbranch} #{gitrepo} #{repodir} 2>&1`
      raise "Unable to clone the repository. Git error " + $?.exitstatus.to_s if $?.to_i != 0
    end

    def self.git_uri_valid?(uri)
      uri_regex = Regexp.new("^git://[a-z0-9]+([-.]{1}[a-z0-9]+)*.[a-z]{2,5}(([0-9]{1,5})?/.*)?.git$", Regexp::IGNORECASE)
      if uri =~ uri_regex
        Addressable::URI.parse(uri)
        return true
      end
      false
    rescue Addressable::URI::InvalidURIError
      false
    end
  end

  module ZipUtil
    require 'zip/zip'
    def self.pack_files(zipfile, files)
      FileUtils.rm_f(zipfile)
      Zip::ZipFile::open(zipfile, true) do |zf|
        files.each do |f|
          zf.add(f[:zn], f[:fn])
        end
      end
    end
  end
end
namespace :assets do
  begin
    require 'sprite_factory'
  rescue LoadError
    $stderr.puts "SpriteFactory gem is required to generate sprite images and css"
    exit 1
  else
    desc "Recreate sprite images and css"
    task :resprite => :environment do
      SpriteFactory.layout = :packed
      SpriteFactory.library = :chunkypng
      SpriteFactory.report = true
      SpriteFactory.run!('app/assets/images/icons', :output_style => 'app/assets/stylesheets/icons.scss') do |icons|
        output = []
        icons.each do |name, metadata|
          output << "img." + name.to_s + " { " + metadata[:style].gsub(/url\(icons.png\)/, "image_url('icons.png')") + " }"
        end
        output.join("\n")
      end
      SpriteFactory.run!('app/assets/images/vendor_images', :output_style => 'app/assets/stylesheets/vendor_images.scss') do |vendor_images|
        output = []
        vendor_images.each do |name, metadata|
          output << "img." + name.to_s + " { " + metadata[:style].gsub(/url\(vendor_images.png\)/, "image_url('vendor_images.png')") + " }"
        end
        output.join("\n")
      end
    end
  end
end
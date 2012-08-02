# Put all your default configatron settings here.

# Branding
configatron.brand.logo = "cflogo.png"
configatron.brand.title = "CF Console"
configatron.brand.author = "Ferran Rodenas"

# Sets the available Cloud Foundry providers showed at login page.
# Admits dynamic parameters for the Cloud Controller URL.
# Just put the parameter (only one) between brackets "{}" and the login page will ask the user for that parameter.
configatron.available_targets = []
configatron.available_targets << ["Local CloudFoundry", "http://api.vcap.me"]
configatron.available_targets << ["AppFog (AWS service)", "http://api.aws.af.cm"]
configatron.available_targets << ["AppFog (HP Cloud service)", "http://api.hp.af.cm"]
configatron.available_targets << ["AppFog (Joyent service)", "http://api.joyent.af.cm"]
configatron.available_targets << ["AppFog (Rackspace service)", "http://api.rackspace.af.cm"]
configatron.available_targets << ["HP Cloud Services", "http://api.cloudfoundry.hpcloud.com/"]
configatron.available_targets << ["Iron Foundry", "http://api.gofoundry.net"]
configatron.available_targets << ["Stackato Sandbox", "https://api.stacka.to"]
configatron.available_targets << ["VMware CloudFoundry", "http://api.cloudfoundry.com"]
configatron.available_targets << ["VMware Micro CloudFoundry", "http://api.{Domain}.cloudfoundry.me"]
configatron.available_targets << ["Other", "{Cloud Controller URL}"]

# Deploy from options.
configatron.deploy_from.git_available = true

# Sets the concurrency for the reactor parallel iterator (EM::Iterator).
configatron.reactor_iterator.concurrency = 50

# Sets if we must suggest an URL based on the CF target url when creating a new application.
configatron.suggest.app.url = true

# Set which vendor images are included in vendor_images.png sprite.
configatron.sprites.vendor_images = [
  "aspdotnet", "aspdotnet40", "django", "erlangR14B02", "grails", "java", "java7", "java_web", "lift",
  "mongodb", "mssql", "mysql", "neo4j", "node", "node06", "node08", "otp_rebar", "perl", "perl514", "play", "php",
  "postgresql", "python", "python26", "python27", "python32", "rabbitmq", "rails3", "redis", "ruby18", "ruby19",
  "sinatra", "spring"
]

# Set which language translations are available.
configatron.languages.available = ["en", "es", "ca"]
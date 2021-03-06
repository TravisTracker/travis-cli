require 'thor'

$stdout.sync = true

module Travis
  autoload :Keychain, 'travis/keychain'

  class Cli < Thor
    autoload :Config,    'travis/cli/config'
    autoload :Deploy,    'travis/cli/deploy'
    autoload :Helper,    'travis/cli/helper'
    autoload :SecureKey, 'travis/cli/secure_key'

    namespace 'travis'

    desc 'config', 'Sync config between keychain, app and local working directory'
    method_option :backup,  :aliases => '-b', :type => :boolean, :default => false

    def config(remote)
      Config.new(shell, remote, options).invoke
    end

    desc 'deploy', 'Deploy to the given remote'
    method_option :migrate, :aliases => '-m', :type => :boolean, :default => false
    method_option :configure, :aliases => '-c', :type => :boolean, :default => false

    def deploy(remote)
      Deploy.new(shell, remote, options).invoke
    end

    desc 'encrypt <slug> <secret>', 'Encrypt string for a repository'
    def encrypt(slug, secret)
      puts "\nAbout to encrypt '#{secret}' for '#{slug}'\n\n"

      encrypted = nil
      begin
        encrypted = SecureKey.new(slug).encrypt(secret)
      rescue SecureKey::FetchKeyError
        abort 'There was an error while fetching public key, please check if you entered correct slug'
      end

      puts "Please add the following to your .travis.yml file:"
      puts ""
      puts "  secure: \"#{Base64.encode64(encrypted).strip.gsub("\n", "\\n")}\""
      puts ""
    end
  end
end

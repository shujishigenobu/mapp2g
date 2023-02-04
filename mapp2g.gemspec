# frozen_string_literal: true

require_relative "lib/mapp2g/version"

Gem::Specification.new do |spec|
  spec.name = "mapp2g"
  spec.version = Mapp2g::VERSION
  spec.authors = ["Shuji Shigenobu"]
  spec.email = ["sshigenobu@gmail.com"]

  spec.summary = "mapp2g is the tool to map protein sequences to genome references in a splicing-aware way. "
  spec.description = "mapp2g is a bioinformatics software, which map and align protein sequences (amino acid sequences) to genome references in a splicing-aware way. mapp2g alignment pipeline employs exonerate and tBLASTn."
  spec.homepage = "https://github.com/shujishigenobu/mapp2g"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

#  spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/shujishigenobu/mapp2g"
  spec.metadata["changelog_uri"] = "https://github.com/shujishigenobu/mapp2g"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end

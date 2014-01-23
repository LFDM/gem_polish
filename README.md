# GemPolish

Further polishes your Bundler gem skeleton.

## Installation

    $ gem install gem_polish

## Usage

Provides two executables to improve your Bundler gem skeleton.

- polish_gem

Is meant to be used inside a newly created gem (`bundle gem GEM_NAME`)
Available options:

| Option | Alias | Result |
| ------ | ----- | ------ |
| --description | -d | Takes a string and writes it to the gemspec and the README |
| --rspec_configuration | -r | Adds additional rspec configuration, check `lib/templates` |
| --travis | -t | Takes several ruby versions travis will use |
| --coverage | -c | Adds coveralls to your gem |
| --badges | -b | Adds badges to your README, supports badge fury, gemnasium, travis, coveralls and code climate |

## Contributing

1. Fork it ( http://github.com/<my-github-username>/gem_polish/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

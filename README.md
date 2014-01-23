# GemPolish

Further polishes your Bundler gem skeleton.

## Installation

    $ gem install gem_polish

## Usage

Provides two executables to improve your Bundler gem skeleton.

- polish_gem

Is meant to be used inside the directory a newly created gem (`bundle gem GEM_NAME`)
Available options:

|      Option      | Alias | Result |
|:---------------- |:-----:| ------ |
| `--description`    | `-d` | Takes a string and writes it to the gemspec and the README |
| `--rspec_conf`     | `-r` | Adds additional rspec configuration, check `lib/templates` |
| `--travis`         | `-t` | Takes several ruby versions travis will use |
| `--coverage`       | `-c` | Adds coveralls to your gem |
| `--badges`         | `-b` | Adds badge fury, gemnasium, travis, coveralls and code climate and/or badges to your README |
| `--git_user`       | `-g` | Git user name used to link to your badges. Defaults to the information inside of your `.gitconfig` |
| `--no_default`     | `-n` | Disables all default values provided in your `.gem_polish.yml` file |

Unless `--no_default` is set, `polish_gem` will look into your home
directory for a `.gem_polish.yml` file, that can provide default values
for gem polishing. Check the `examples` folder for its formatting.

Here's an example of the syntax:
```
# inside a new gem called test
polish_gem -nc -d 'a test gem' -t 1.9.3 jruby-1.7.8 -b travis coveralls
```
This would polish the test gem with coveralls support,
circumventing the `.gem_polish.yml` file, adding the description,
using two ruby versions for travis and adding two badges to the
README file. 


* create_gem

Combines gem creation and polishing:
``` 
create_gem my_new_gem
```
This will create the new gem `my_new_gem`. Arguments of `polish_gem` can be passed to override defaults or provide a description.
```
create_gem my_new_gem -d 'Does nothing so far'
```
At the moment he `bundle gem` command is invoked with `-t rspec` to
provide the `rspec` test framework by default.

## Contributing

1. Fork it ( http://github.com/LFDM/gem_polish/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

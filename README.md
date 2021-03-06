# NodeMutation

NodeMutation provides a set of APIs to rewrite node source code.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'node_mutation'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install node_mutation

## Usage

1. initialize the NodeMutation instance:

```ruby
require 'node_mutation'

mutation = NodeMutation.new(source)
```

2. call the rewrite apis:

```ruby
# append the code to the current node.
mutation.append node, 'include FactoryGirl::Syntax::Methods'
# delete source code of the child ast node
mutation.delete node, :dot, :message, and_comma: true
# insert code to the ast node.
mutation.insert node, 'URI.', at: 'beginning'
# insert code next to the ast node.
mutation.insert_after node, '{{arguments.first}}.include FactoryGirl::Syntax::Methods'
# prepend code to the ast node.
mutation.prepend node, '{{arguments.first}}.include FactoryGirl::Syntax::Methods'
# remove source code of the ast node
mutation.remove(node: Node)
# replace child node of the ast node with new code
mutation.replace node, :message, with: 'test'
# replace the ast node with new code
mutation.replace_with node, 'create {{arguments}}'
# wrap node within a block, class or module
mutation.wrap node, with: 'module Foo'
```

3. process actions and write the new source code to file:

```ruby
result = mutation.process
# if it makes any change to the source
result.affected?
# if any action is conflicted
result.conflicted
# return the new source if it is affected
result.new_source
```

## Write Adapter

Different parsers, like parse and ripper, will generate different AST nodes, to make NodeMutation work for them all,
we define an [Adapter](https://github.com/xinminlabs/node-mutation-ruby/blob/main/lib/node_mutation/adapter.rb) interface,
if you implement the Adapter interface, you can set it as NodeMutation's adapter.

```typescript
NodeMutation.configure({ adapter: ParserAdapter.new })
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/xinminlabs/node_mutation.

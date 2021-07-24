# Test-Driven way of fighting N + 1 queries

RSpec matcher to control number of SQL queries executed by a block of code.

It wraps [the answer at Stack Overflow][stack-answer] by [Ryan Bigg][ryan-bigg], which based on Active Support [Notification][notification] and [Instrumentation][instrumentation] mechanisms.

For motivation and details see my [blog post "Fighting the Hydra of N+1 queries" in the Martian Chronicles][hydra].

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Code Climate][codeclimate-badger]][codeclimate]

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

## Installation

```ruby
# Gemfile
gem "rspec-sqlimit"
```

## Usage

The gem defines matcher `exceed_query_limit` that takes maximum number of SQL requests to be made inside the block.

```ruby
require "rspec-sqlimit"

RSpec.describe "N+1 safety" do
  it "doesn't send unnecessary requests to db" do
    expect { User.create }.not_to exceed_query_limit(1)
  end
end
```

The above specification fails with the following description:

```
Failure/Error: expect { User.create }.not_to exceed_query_limit(1)

 Expected to run maximum 1 queries
 The following 3 queries were invoked:
    1) begin transaction (0.045 ms)
    2) INSERT INTO "users" DEFAULT VALUES (0.19 ms)
    3) commit transaction (148.935 ms)
```

You can restrict the matcher using regex:

```ruby
require "rspec-sqlimit"

RSpec.describe "N+1 safety" do
  it "doesn't send unnecessary requests to db" do
    expect { User.create }.not_to exceed_query_limit(1).with(/^INSERT/)
  end
end
```

This time test passes.

When a specification with a restriction fails, you'll see an error as follows:

```ruby
require "rspec-sqlimit"

RSpec.describe "N+1 safety" do
  it "doesn't send unnecessary requests to db" do
    expect { User.create name: "Joe" }.not_to exceed_query_limit(0).with(/^INSERT/)
  end
end
```

```
Failure/Error: expect { User.create }.not_to exceed_query_limit(0).with(/INSERT/)

  Expected to run maximum 0 queries that match (?-mix:INSERT)
  The following 1 queries were invoked among others (see mark ->):
     1) begin transaction (0.072 ms)
  -> 2) INSERT INTO "users" ("name") VALUES (?); ["Joe"] (0.368 ms)
     3) commit transaction (147.559 ms)
```

In the last example you can see that binded values are shown after the query following the Rails convention.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[codeclimate-badger]: https://img.shields.io/codeclimate/github/nepalez/rspec-sqlimit.svg?style=flat
[codeclimate]: https://codeclimate.com/github/nepalez/rspec-sqlimit
[gem-badger]: https://img.shields.io/gem/v/rspec-sqlimit.svg?style=flat
[gem]: https://rubygems.org/gems/rspec-sqlimit
[gemnasium-badger]: https://img.shields.io/gemnasium/nepalez/rspec-sqlimit.svg?style=flat
[gemnasium]: https://gemnasium.com/nepalez/rspec-sqlimit
[travis-badger]: https://img.shields.io/travis/nepalez/rspec-sqlimit/master.svg?style=flat
[travis]: https://travis-ci.org/nepalez/rspec-sqlimit
[stack-answer]: http://stackoverflow.com/a/5492207/1869912
[ryan-bigg]: http://ryanbigg.com/
[notification]: http://api.rubyonrails.org/classes/ActiveSupport/Notifications.html
[instrumentation]: http://guides.rubyonrails.org/active_support_instrumentation.html
[hook]: http://guides.rubyonrails.org/active_support_instrumentation.html#sql-active-record
[hydra]: https://evilmartians.com/chronicles/fighting-the-hydra-of-n-plus-one-queries

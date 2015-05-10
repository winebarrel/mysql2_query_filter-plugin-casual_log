# Mysql2QueryFilter::Plugin::CasualLog

Plug-in that colorize the bad query for [Mysql2QueryFilter](https://github.com/winebarrel/mysql2_query_filter).

Porting of [MySQLCasualLog.pm](https://gist.github.com/kamipo/839e8a5b6d12bddba539).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2_query_filter-plugin-casual_log'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql2_query_filter-plugin-casual_log

## Usage

```ruby
require 'mysql2_query_filter'

Mysql2QueryFilter.configure do |filter|
  filter.plugin :casual_log, database: 'mysql'
end

Mysql2QueryFilter.enable!

client = Mysql2::Client.new(host: 'localhost', username: 'root', database: 'mysql')
client.query('SELECT * FROM user')
# => # SELECT * FROM user
#    ---
#               id: 1
#      select_type: SIMPLE
#            table: user
#             type: ALL # <- red/bold
#    possible_keys:
#              key:
#          key_len:
#              ref:
#             rows: 4
#            Extra:
```

![](http://i.gyazo.com/66a769f30eab5ff56655977d42a30f4d.png)

## Retated links

* http://kamipo.github.io/talks/20140711-mysqlcasual6

require 'yaml'
require 'mysql2_query_filter'
require 'term/ansicolor'

module Mysql2QueryFilter::Plugin
  class CasualLog < Filter
    Mysql2QueryFilter.register(:casual_log, self)

    REGEXPS = {
      'select_type' => Regexp.union(
        /DEPENDENT\sUNION/,
        /DEPENDENT\sSUBQUERY/,
        /UNCACHEABLE\sUNION/,
        /UNCACHEABLE\sSUBQUERY/
      ),
      'type' =>  Regexp.union(
        /index/,
        /ALL/
      ),
      'possible_keys' => Regexp.union(
        /NULL/
      ),
      'key' => Regexp.union(
        /NULL/
      ),
      'Extra' => Regexp.union(
        /Using\sfilesort/,
        /Using\stemporary/
      )
    }

    def initialize(options)
      super
      @out = @options.delete(:out) || $stderr
      @client = Mysql2::Client.new(@options)
    end

    def filter(sql)
      if sql =~ /\Aselect\b/i
        result = @client.query("EXPLAIN #{sql}").first
        colorize_explain(result)
        @out.puts "# #{sql}\n---"
        max_key_length = result.keys.map(&:length).max

        result.each do |key, value|
          @out.puts "%*s: %s" % [max_key_length, key, value]
        end

        @out.puts
      end
    end

    private

    def colorize_explain(explain)
      badquery = false

      REGEXPS.each do |key, regexp|
        value = explain[key] || ''

        value.gsub!(regexp) do |m|
          badquery = true
          colored(m)
        end
      end
    end

    def colored(str)
      Term::ANSIColor.red(Term::ANSIColor.bold(str))
    end
  end
end

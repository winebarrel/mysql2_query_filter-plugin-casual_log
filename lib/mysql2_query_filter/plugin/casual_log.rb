require 'yaml'
require 'mysql2_query_filter'
require 'term/ansicolor'

module Mysql2QueryFilter::Plugin
  class CasualLog < Filter
    Mysql2QueryFilter::Plugin.register(:casual_log, self)

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
      @matcher = @options.delete(:match) || proc {|sql, query_options| true }
      @client = Mysql2::Client.new(@options)
    end

    def filter(sql, query_options)
      if sql =~ /\A\s*SELECT\b/i and @matcher.call(sql, query_options)
        badquery = false
        explains = []

        @client.query("EXPLAIN #{sql}").each_with_index do |result, i|
          colorize_explain(result).tap { |bq| badquery ||= bq }
          explains << format_explain(result, i + 1)
        end

        if badquery
          @out << "# #{sql}\n" + explains.join + "\n"
        end
      end
    end

    private

    def colorize_explain(explain)
      badquery = false

      REGEXPS.each do |key, regexp|
        value = explain[key] ||= 'NULL'

        value.gsub!(regexp) do |m|
          badquery = true
          colored(m)
        end
      end

      badquery
    end

    def colored(str)
      Term::ANSIColor.red(Term::ANSIColor.bold(str))
    end

    def format_explain(explain, i)
      message = "*************************** #{i}. row ***************************\n"
      max_key_length = explain.keys.map(&:length).max

      explain.each do |key, value|
        message << "%*s: %s\n" % [max_key_length, key, value]
      end

      message
    end
  end
end

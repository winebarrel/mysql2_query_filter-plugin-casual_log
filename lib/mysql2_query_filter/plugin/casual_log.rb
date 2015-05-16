require 'yaml'
require 'mysql2_query_filter'
require 'term/ansicolor'

module Mysql2QueryFilter::Plugin
  class CasualLog < Mysql2QueryFilter::Base
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
      @out = @options[:out] || $stderr
      @matcher = @options[:match] || proc {|sql, client| true }
      @client = @options[:client]
    end

    def filter(sql, client)
      if sql =~ /\A\s*SELECT\b/i and @matcher.call(sql, client)
        conn = @client || client
        badquery = false
        explains = []

        conn.query("EXPLAIN #{sql}", :as => :hash).each_with_index do |result, i|
          colorize_explain(result).tap {|bq| badquery ||= bq }
          explains << format_explain(result, i + 1)
        end

        if badquery
          query_options = conn.query_options.dup
          query_options.delete(:password)

          @out << <<-EOS
# Time: #{Time.now.strftime("%Y-%m-%d %H:%M:%S")}
# Query options: #{query_options.inspect}
# Query: #{sql}
#{explains.join("\n")}
          EOS
        end
      end
    rescue => e
      $stderr.puts colored([e.message, e.backtrace.first].join("\n"))
    end

    private

    def colorize_explain(explain_result)
      badquery = false

      REGEXPS.each do |key, regexp|
        value = explain_result[key] ||= 'NULL'
        value = value.to_s

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

      message.chomp
    end
  end # CasualLog
end # Mysql2QueryFilter::Plugin

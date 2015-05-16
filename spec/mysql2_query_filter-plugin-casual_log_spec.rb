describe Mysql2QueryFilter::Plugin::CasualLog do
  let(:client) { Mysql2::Client.new(host: "localhost", username: "root", database: "mysql") }
  let(:today) { Time.parse("2015-05-15 20:15:55 +0000") }
  let(:out) { StringIO.new }

  before do
    Mysql2QueryFilter.configure do |filter|
      filter.plugin :casual_log, out: out
    end

    Timecop.freeze(today) do
      client.query(sql)
    end
  end

  subject { out.string.sub(/Query options:.*/, "Query options:").sub(/rows: \d+/, "rows:") }

  context "when bad query" do
    let(:sql) { "select * from user" }

    let(:explain) do
      <<-EOS
# Time: 2015-05-15 20:15:55
# Query options:
# Query: select * from user
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE
        table: user
         type: #{red bold "ALL"}
possible_keys: #{red bold "NULL"}
          key: #{red bold "NULL"}
      key_len:\s
          ref:\s
         rows:
        Extra:\s
      EOS
    end

    it { is_expected.to eq explain }
  end

  context "when good query" do
    let(:sql) { "select 1 from user where Host = 'localhost'" }
    it { is_expected.to eq "" }
  end
end

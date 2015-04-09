require 'json'
module Endpoints
  class Tables < Base
    namespace "/tables" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
        encode(DB.tables)
      end

      get "/:table" do |table|
        MultiJson.decode(params[:q]) # ensure json query
        rows = DB.from(table).where("data @> ?", params[:q]).all
        rows.each {|r| r[:data] = MultiJson.decode(r[:data])}
        encode(rows)
      end

      get "/:table/:id" do |table, id|
        row = DB.from(table).where(id: id).first
        serialize_row(row)
      end

      put "/:table/:id" do |table, id|
        row = modify_row(table: table, id: id) do
          json_body
        end
        serialize_row(row)
      end

      patch "/:table/:id" do |table, id|
        row = modify_row(table: table, id: id) do |data|
          data.merge!(json_body)
        end
        serialize_row(row)
      end

      post do
        table = json_body['table']
        DB.transaction do
          table.gsub!(/\W/,'')
          DB.create_table(table) do
            column :id,         :uuid,        default: Sequel.function(:uuid_generate_v4), primary_key: true
            column :data,       :jsonb
            column :seq,        :int,         default: 0
            column :created_at, :timestamptz, default: Sequel.function(:now)
            column :updated_at, :timestamptz, default: Sequel.function(:now)
            index :data, type: :gin, opclass: :jsonb_path_ops
          end
        end
        status 201
        encode table
      end

      post "/:table" do |table|
        id = DB.from(table).insert(data: raw_body)
        encode(id)
      end

      delete "/:table" do |table|
        DB.drop_table table
        status 200
      end

      private
      def serialize_row(row)
        row[:data] = MultiJson.decode(row[:data])
        encode(row)
      end

      def modify_row(table:, id:)
        dataset = DB.from(table).where(id: id)
        row = dataset.first
        row[:updated_at] = Time.now.utc
        row[:seq] += 1

        new_data = yield MultiJson.decode(row[:data])
        row[:data] = MultiJson.encode(new_data)

        dataset.update(row)
        return row
      end

      def json_body
        MultiJson.decode(raw_body)
      end

      def raw_body
        request.body.read.tap { request.body.rewind }
      end
    end
  end
end

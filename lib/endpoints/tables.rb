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

      get "/:name/:id" do |name, id|
        row = DB.from(name).where(id: id).first
        serialize_row(row)
      end

      put "/:name/:id" do |name, id|
        dataset = DB.from(name).where(id: id)
        row = dataset.first
        row[:updated_at] = Time.now.utc
        row[:seq] += 1
        row[:data] = raw_body
        dataset.update(row)
        serialize_row(row)
      end

      post do
        name = json_body['name']
        DB.transaction do
          name.gsub!(/\W/,'')
          DB.create_table(name) do
            column :id,         :uuid,        default: Sequel.function(:uuid_generate_v4), primary_key: true
            column :data,       :jsonb
            column :seq,        :int,         default: 0
            column :created_at, :timestamptz, default: Sequel.function(:now)
            column :updated_at, :timestamptz, default: Sequel.function(:now)
            index :data, type: :gin, opclass: :jsonb_path_ops
          end
        end
        status 201
        encode name
      end

      post "/:name" do |name|
        id = DB.from(name).insert(data: raw_body)
        encode(id)
      end

      delete "/:name" do |name|
        DB.drop_table name
        status 200
      end

      private
      def serialize_row(row)
        row[:data] = MultiJson.decode(row[:data])
        encode(row)
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

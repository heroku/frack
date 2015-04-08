require 'json'
module Endpoints
  class Tables < Base
    namespace "/tables" do
      before do
        content_type :json, charset: 'utf-8'
      end

      get do
       tables = DB["
         SELECT table_schema || '.' || table_name AS table
         FROM   information_schema.tables
         WHERE  table_type = 'BASE TABLE'
         AND    table_schema NOT IN ('pg_catalog', 'information_schema');
        "].map{|t| t[:table]}
        encode(tables)
      end

      get "/:name/:id" do |name, id|
        data = DB.from(name).where(id: id).first
        encode(data)
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
        id = DB.from(name).insert(data: MultiJson.dump(json_body))
        encode(id)
      end

      delete "/:name" do |name|
        name.gsub!(/\W/,'')
        DB["drop table #{name};"].all
        status 200
      end

      private
      def json_body
        MultiJson.decode(request.body.read).tap do
          request.body.rewind
        end
      end
    end
  end
end

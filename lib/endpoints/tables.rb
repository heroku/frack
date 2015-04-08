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

      post do
        name = json_body['name']
        DB.transaction do
          name.gsub!(/\W/,'')
          DB["create table #{name} (id uuid primary key default uuid_generate_v4(), data jsonb);"].all
          DB["create index on #{name} using gin (data jsonb_path_ops);"].all
        end
        status 201
        encode name
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

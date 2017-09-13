require 'generators/tok_access/orm_helper'
require 'rails/generators/active_record/model/model_generator'

module TokAccess
  module Generators
    class ModelGenerator < ActiveRecord::Generators::ModelGenerator
      include TokAccess::Generators::OrmHelper
      source_root File.join(File.dirname(ActiveRecord::Generators::ModelGenerator.instance_method(:create_migration_file).source_location.first), "templates")


      def create_migration_file
        return unless options[:migration] && options[:parent].nil?
        attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? } if options[:indexes] == false
        if behavior == :invoke
          if model_exists? or migration_exists?(table_name)
            migration_template "#{__FILE__}/../templates/migration_existing_for.rb", "db/migrate/add_tok_access_to_#{table_name}.rb", migration_version: migration_version
          else
            migration_template "#{__FILE__}/../templates/migration_for.rb", "db/migrate/tok_access_create_#{table_name}.rb", migration_version: migration_version
          end
        end
        if behavior == :revoke
          migration_template "#{__FILE__}/../templates/migration_existing_for.rb", "db/migrate/add_tok_access_to_#{table_name}.rb", migration_version: migration_version
          migration_template "#{__FILE__}/../templates/migration_for.rb", "db/migrate/tok_access_create_#{table_name}.rb", migration_version: migration_version
        end
      end

      def generate_tok_model
        tok_model_table_name = "#{table_name.singularize}_tok"
        tok_model_class_name = "#{table_name.singularize}_tok".camelize
        if behavior == :invoke
          if !File.exist?(Rails.root.join("app", "models", "#{tok_model_table_name}.rb"))
            invoke "active_record:model", [tok_model_class_name, "token:string","devise_token:string", "object_id:integer"]
          end
          inject_into_class(Rails.root.join("app", "models", "#{table_name.singularize}.rb"), Object.const_get(table_name.singularize.camelize)) do
            %Q{\ttokify\n}
          end
          inject_into_class(Rails.root.join("app", "models", "#{tok_model_table_name}.rb"), Object.const_get(tok_model_class_name)) do
            %Q{\tdefine_toks :#{table_name.singularize}\n}
          end
        end
        if behavior == :revoke
          system "rails d model #{table_name.singularize.camelize}"
          system "rails d model #{tok_model_class_name}"
        end
      end
    end
  end
end

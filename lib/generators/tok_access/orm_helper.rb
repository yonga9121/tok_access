module TokAccess
  module Generators
    module OrmHelper

      private

      def model_exists?
        File.exist?(File.join(destination_root, model_path))
      end

      def migration_exists?(table_name)
        Dir.glob("#{File.join(destination_root, migration_path)}/[0-9]*_*.rb").grep(/\d+_add_tok_access_to_#{table_name}.rb$/).first
      end

      def migration_path
        @migration_path ||= File.join("db", "migrate")
      end

      def model_path
        @model_path ||= File.join("app", "models", "#{file_path}.rb")
      end

      def migration_version
         "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
      end

      def migration_data
        <<-RUBY.strip_heredoc
        t.string :password_digest, null: false, default: ""
        RUBY
      end

    end
  end
end

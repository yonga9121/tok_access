module TokAccess

  class TokConfig

    attr_accessor :tokens_limit
    @tokens_limit = nil

    def initialize()
      @tokens_limit = 10
    end

  end

  @config =  TokConfig.new

  def config
    @config
  end
  module_function :config

  def configure(&block)
    if block_given?
      yield @config
    end
  end
  module_function :configure

  Object.class_eval do
    def tokify
      class_eval do
        include TokAccess::TokAuthenticable
        has_secure_password
        has_many :toks, class_name: "#{self}Tok", foreign_key: "object_id", autosave: true
      end
    end

    def define_toks(association = nil)
      class_eval do
        belongs_to association,
                   class_name: "#{self.to_s.gsub(/Tok\z/,'')}",
                   foreign_key: "object_id" if association
        belongs_to :_tok_object,
                   class_name: "#{self.to_s.gsub(/Tok\z/,'')}",
                   foreign_key: "object_id" if association
        has_secure_token
        has_secure_token :devise_token
        validates :token, :devise_token, presence: true, on: :update
      end
    end
  end

end

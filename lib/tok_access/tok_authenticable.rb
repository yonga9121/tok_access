module TokAccess

  module TokAuthenticable
    extend ActiveSupport::Concern

    included do

        # before create an tokified object, setup the toks
        before_create :setup_access_tok

        # Return nil if you haven't authenticated the object
        # using the method #tok_auth or the method #tok_auth failed the
        # authentication process. Otherwise, return the token attribute of one
        # of the associated object toks.
        def get_token
          @_token
        end

        # Return nil if you haven't authenticated the object
        # using the method #tok_auth or the method #tok_auth failed the
        # authentication process. Otherwise, return the devise_token attribute
        # of one of the associated object toks.
        def get_devise_token
          @_devise_token
        end

        # Return nil if you haven't use the method TokAccess.validate_access.
        # After the TokAccess.validate_access method is called, if the access was validated
        # successfuly, this method will return true if the token was regenerated, otherwise
        # return nil
        def refreshed?
          @refreshed
        end


        # Authenticate the object with the given password .
        # If the authentication process is successful return the object and the
        # methods #get_tok and #get_devise_tok will return the tokens
        # Return nil if the authentication process fails
        # You can pass as a parameter a devise_token. If the object has a tok that
        # match the devise_token given, will regenerate the tok. If you do not
        # pass the devise_token parameter, the method will create a new tok
        # associated with the object. If the object.toks.size is equal to the
        # toks_limit, the method will destroy one of the toks and create a new one
        def tok_auth(password, devise_token = nil )
          if self.authenticate(password)
            generate_access_toks(devise_token)
            return self
          end
          nil
        end

        # If the object is associated to the tok given the method will return
        # the object and the methods #get_tok and #get_devise_tok will
        # return the tokens. Otherwise return nil
        def provide_access(tok)
          if self.toks.find_by(id: tok.id)
            refresh tok
            set_token tok.token
            set_devise_token tok.devise_token
            return self
          end
          nil
        end

        private

        def refresh(tok)
          if tok.updated_at >= 15.minutes.ago
            tok.touch
            @refreshed = true
          end
        end

        def set_token(token)
          @_token = token
        end

        def set_devise_token(token)
          @_devise_token = token
        end

        def setup_access_tok
          self.toks.build()
        end

        def generate_access_toks(devise_token = nil)
          if !devise_token
            self.toks.order(updated_at: :asc).first.destroy if self.toks.count == TokAccess.config.tokens_limit
            tok = self.toks.create
          else
            tok = self.toks.find_by(devise_token: devise_token)
            tok.regenerate_token if tok
            tok.regenerate_devise_token if tok
          end
          if tok
            @refreshed = true
            set_token tok.token
            set_devise_token tok.devise_token
          end
        end

    end

    module ClassMethods

      # object: The object to authenticate
      # password: The password to authenticate the object with
      # if the object is authenticatred successfully, returns the object with
      # => the get_token and get_devise_token methods returning the access
      # => tokens.
      # otherwise return nil
      def tok_authentication(object, password)
          return object.tok_auth(password)
      end

      # tokens: hash with a devise_token key or token key
      # if any of the tokens is found. Provide access to the related
      # object calling the method provide_access
      # otherwise return nil
      def validate_access(tokens = {})
        toks_class = Object.const_get("#{self.name.camelize}Tok")
        tok = toks_class.find_by(devise_token: tokens[:devise_token]) if tokens[:devise_token]
        tok = toks_class.find_by(token: tokens[:token]) if tokens[:token] and !tok
        if tok
          return tok._tok_object.provide_access(tok)
        end
        nil
      end

    end

  end

end

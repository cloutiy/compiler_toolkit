module Compilers
  class Tokenizer
    @line = 1
    @position = 1

    def initialize(@code : String, @symbol_patterns : Array(Tuple(Symbol, Regex)))
    end

    # tokenize keeps trying to identify tokens until there's no input left. When done returns a list of Tokens.
    def tokenize
      tokens = [] of Token | Nil
      until @code.empty?
        tokens << next_token
      end # until
      tokens
    end # tokenize

    # Uses a series of Regex patterns to identity token types. When there's a match, an instance of Token is returned
    def next_token
      @symbol_patterns.each do |kind, re|
        re = /^(#{re})/
        if @code =~ re
          payload = $1
          token = Token.new(kind, payload, @line, @position)
          @code = @code[payload.size..-1]
          @position = @position + payload.size
          # If \n, increment line counter; reset position
          if kind == :newline
            @line = @line + 1
            @position = 1
          end
          return token # return Token.new(kind, value)
        end            # if
      end              # do
      # If the input doesn't match any of the patterns given to the scanner, throw an error.
      puts "Got stuck at #{@line}:#{@position} while reading: #{@code.inspect}. I couldn't map the next chars to any of the patterns I know how to recognize."
      exit
    end # next_token
  end

  # A token is of a certain kind and a payload
  struct Token
    property kind, payload, line, position

    def initialize(@kind : Symbol, @payload : String, @line : Int32, @position : Int32)
    end
  end # struct

end # module

# ## Driver
# Define list of token patterns
symbol_patterns = [
  # Keywords
  {:def, /def/},
  {:end, /end/},
  # Identifiers
  {:identifier, /[a-zA-Z]+/},
  # Numbers
  {:float, /[0-9]+\.[0-9]+/},
  {:int, /[0-9]+/},
  # Delimiters
  {:oparen, /\(/},
  {:cparen, /\)/},
  {:space, / /},
  {:comma, /,/},
  {:newline, /\n/},
]

# Read source file
f = File.read("source.txt")
# Instantiate scanner; feed it the file and list of patterns to recorgnize.
t = Compilers::Tokenizer.new(f, symbol_patterns).tokenize
# Look at the list of tokens.
puts t.map(&.inspect).join("\n")

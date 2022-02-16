-- lexit.lua
-- Darian Marvel
-- 2/11/2022
-- Writing a lexer for "Tenrec"
-- Based on Glenn G. Chappell's "lexer.lua"
-- lexer.lua header comment below

-- *********************************************************************

-- lexer.lua
-- VERSION 3
-- Glenn G. Chappell
-- Started: 2022-02-02
-- Updated: 2022-02-04
--
-- For CS F331 / CSCE A331 Spring 2022
-- In-Class Lexer Module

-- History:
-- - v1:
--   - Framework written. Lexer treats every character as punctuation.
-- - v2:
--   - Add state LETTER, with handler. Write skipToNextLexeme. Add
--     comment on invariants.
-- - v3
--   - Finished (hopefully). Add states DIGIT, DIGDOT, DOT, PLUS, MINUS,
--     STAR. Comment each state-handler function. Check for MAL lexeme.

-- Usage:
--
--    program = "print a+b;"  -- program to lex
--    for lexstr, cat in lexer.lex(program) do
--        -- lexstr is the string form of a lexeme.
--        -- cat is a number representing the lexeme category.
--        --  It can be used as an index for array lexer.catnames.
--    end

-- *********************************************************************

-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local lexer = {}  -- Our module; members are added below


-- *********************************************************************
-- Public Constants
-- *********************************************************************


-- Numeric constants representing lexeme categories
lexer.KEY    = 1
lexer.ID     = 2
lexer.NUMLIT = 3
lexer.STRLIT = 4
lexer.OP     = 5
lexer.PUNCT  = 6
lexer.MAL    = 7


-- catnames
-- Array of names of lexeme categories.
-- Human-readable strings. Indices are above numeric constants.
lexer.catnames = {
    "Keyword",
    "Identifier",
    "NumericLiteral",
    "StringLiteral",
    "Operator",
    "Punctuation",
    "Malformed"
}

-- *********************************************************************
-- Local Constants
-- *********************************************************************

local keywords = {
  "and",
  "char",
  "cr",
  "elif",
  "else",
  "false",
  "func",
  "if",
  "not",
  "or",
  "print",
  "read",
  "return",
  "true",
  "while"
}

-- *********************************************************************
-- Kind-of-Character Functions
-- *********************************************************************

-- All functions return false when given a string whose length is not
-- exactly 1.


-- isLetter
-- Returns true if string c is a letter character, false otherwise.
local function isLetter(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "A" and c <= "Z" then
        return true
    elseif c >= "a" and c <= "z" then
        return true
    else
        return false
    end
end


-- isDigit
-- Returns true if string c is a digit character, false otherwise.
local function isDigit(c)
    if c:len() ~= 1 then
        return false
    elseif c >= "0" and c <= "9" then
        return true
    else
        return false
    end
end


-- isWhitespace
-- Returns true if string c is a whitespace character, false otherwise.
local function isWhitespace(c)
    if c:len() ~= 1 then
        return false
    elseif c == " " or c == "\t" or c == "\n" or c == "\r"
      or c == "\f" then
        return true
    else
        return false
    end
end


-- isPrintableASCII
-- Returns true if string c is a printable ASCII character (codes 32 " "
-- through 126 "~"), false otherwise.
local function isPrintableASCII(c)
    if c:len() ~= 1 then
        return false
    elseif c >= " " and c <= "~" then
        return true
    else
        return false
    end
end


-- isIllegal
-- Returns true if string c is an illegal character, false otherwise.
local function isIllegal(c)
    if c:len() ~= 1 then
        return false
    elseif isWhitespace(c) then
        return false
    elseif isPrintableASCII(c) then
        return false
    else
        return true
    end
end


-- *********************************************************************
-- The Lexer
-- *********************************************************************


-- lex
-- Our lexer
-- Intended for use in a for-in loop:
--     for lexstr, cat in lexer.lex(program) do
-- Here, lexstr is the string form of a lexeme, and cat is a number
-- representing a lexeme category. (See Public Constants.)
function lexer.lex(program)
    -- ***** Variables (like class data members) *****

    local pos       -- Index of next character in program
                    -- INVARIANT: when getLexeme is called, pos is
                    --  EITHER the index of the first character of the
                    --  next lexeme OR program:len()+1
    local state     -- Current state for our state machine
    local ch        -- Current character
    local lexstr    -- The lexeme, so far
    local category  -- Category of lexeme, set when state set to DONE
    local handlers  -- Dispatch table; value created later

    -- ***** States *****

    local DONE   = 0
    local START  = 1
    local LETTER = 2
    local DIGIT  = 3
    local DIGDOT = 4
    local DOT    = 5
    local PLUS   = 6
    local MINUS  = 7
    local STAR   = 8
    local EXP = 9
    local STRING1 = 10
    local STRING2 = 11
    local ANGBRACK = 12

    -- ***** Character-Related Utility Functions *****

    -- currChar
    -- Return the current character, at index pos in program. Return
    -- value is a single-character string, or the empty string if pos is
    -- past the end.
    local function currChar()
        return program:sub(pos, pos)
    end

    -- nextChar
    -- Return the next character, at index pos+1 in program. Return
    -- value is a single-character string, or the empty string if pos+1
    -- is past the end.
    local function nextChar()
        return program:sub(pos+1, pos+1)
    end

    local function nextCharC(count)
        return program:sub(pos+count, pos+count)
    end

    -- drop1
    -- Move pos to the next character.
    local function drop1()
        pos = pos+1
    end

    -- add1
    -- Add the current character to the lexeme, moving pos to the next
    -- character.
    local function add1()
        lexstr = lexstr .. currChar()
        drop1()
    end

    -- skipToNextLexeme
    -- Skip whitespace and comments, moving pos to the beginning of
    -- the next lexeme, or to program:len()+1.
    local function skipToNextLexeme()
        while true do
            -- Skip whitespace characters
            while isWhitespace(currChar()) do
                drop1()
            end

            -- Done if no comment
            if currChar() ~= "#" then
                break
            end

            -- Skip comment
            drop1()  -- Drop leading "#"
            while true do
                if currChar() == "\n" then
                    drop1()  -- Drop trailing "\n"
                    break
                elseif currChar() == "" then  -- End of input?
                   return
                end
                drop1()  -- Drop character inside comment
            end
        end
    end

    -- ***** State-Handler Functions *****

    -- A function with a name like handle_XYZ is the handler function
    -- for state XYZ

    -- State DONE: lexeme is done; this handler should not be called.
    local function handle_DONE()
        error("'DONE' state should not be handled\n")
    end

    -- State START: no character read yet.
    local function handle_START()
        if isIllegal(ch) then
            add1()
            state = DONE
            category = lexer.MAL
        elseif isLetter(ch) or ch == "_" then
            add1()
            state = LETTER
        elseif isDigit(ch) then
            add1()
            state = DIGIT
        elseif ch == "." then
            add1()
            state = DOT
        elseif ch == "+" then
            add1()
            state = PLUS
        elseif ch == "-" then
            add1()
            state = MINUS
        elseif ch == "*" or ch == "/" or ch == "%" or ch == "=" then
            --add1()
            state = STAR
        elseif ch == "'" then
          add1()
          state = STRING1
        elseif ch == '"' then
          add1()
          state = STRING2
        elseif ch == "!" and nextChar() == "=" then
          add1()
          add1()
          state = DONE
          category = lexer.OP
        elseif ch == "<" or ch == ">" then
          add1()
          state=ANGBRACK
        elseif ch == "[" or ch == "]" then
          add1()
          state = DONE
          category = lexer.OP
        else
            add1()
            state = DONE
            category = lexer.PUNCT
        end
    end

    -- State LETTER: we are in an ID.
    local function handle_LETTER()
        if isLetter(ch) or ch == "_" or isDigit(ch) then
            add1()
        else
            state = DONE
            --if lexstr == "begin" or lexstr == "end"
              --or lexstr == "print" then
                --category = lexer.KEY
            for i, word in pairs(keywords) do
              if lexstr == word then
                category = lexer.KEY
                return
              end
            end
            category = lexer.ID
        end
    end

    -- State DIGIT: we are in a NUMLIT, and we have NOT seen ".".
    local function handle_DIGIT()
        if isDigit(ch) then
            add1()
        elseif ch == "e" or ch == "E" then
            if ( nextChar() == "+" and isDigit(nextCharC(2)) ) or isDigit(nextChar()) then
              add1()
              add1()
              state = EXP
            else
              state = DONE
              category = lexer.NUMLIT
            end
            --if
        --elseif ch == "." then
        --    add1()
        --    state = DIGDOT
        else
            state = DONE
            category = lexer.NUMLIT
        end
    end

    local function handle_EXP()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexer.NUMLIT
        end
    end

    local function handle_STRING1()
        if ch == "\n" then
          state = DONE
          category = lexer.MAL
        elseif ch == "'" then
          add1()
          state = DONE
          category = lexer.STRLIT
        elseif ch == "" then
          state = DONE
          category = lexer.MAL
        else
          add1()
        end
    end

    local function handle_STRING2()
      if ch == "\n" then
        state = DONE
        category = lexer.MAL
      elseif ch == '"' then
        add1()
        state = DONE
        category = lexer.STRLIT
      elseif ch == "" then
        state = DONE
        category = lexer.MAL
      else
        add1()
      end
    end

    -- State DIGDOT: we are in a NUMLIT, and we have seen ".".
    local function handle_DIGDOT()
        if isDigit(ch) then
            add1()
        else
            state = DONE
            category = lexer.NUMLIT
        end
    end

    -- State DOT: we have seen a dot (".") and nothing else.
    local function handle_DOT()
        --if isDigit(ch) then
        --    add1()
        --    state = DIGDOT
        --else
            state = DONE
            category = lexer.PUNCT
        --end
    end

    -- State PLUS: we have seen a plus ("+") and nothing else.
    local function handle_PLUS()
        if isDigit(ch) then
            --add1()
            state = DONE
            category = lexer.OP
        elseif ch == "." then
            --if isDigit(nextChar()) then  -- lookahead
                --add1()  -- add dot to lexeme
                --state = DIGDOT
            --else        -- lexeme is just "+"; do not add dot to lexeme
                state = DONE
                category = lexer.OP
            --end
        else
            state = DONE
            category = lexer.OP
        end
    end

    -- State MINUS: we have seen a minus ("-") and nothing else.
    local function handle_MINUS()
        if isDigit(ch) then
          --add1()
          state = DONE
          category = lexer.OP
        elseif ch == "." then
            --if isDigit(nextChar()) then  -- lookahead
                --add1()  -- add dot to lexeme
                --state = DIGDOT
            --else        -- lexeme is just "-"; do not add dot to lexeme
                state = DONE
                category = lexer.OP
            --end
        else
            state = DONE
            category = lexer.OP
        end
    end

    -- State STAR: we have seen a star ("*"), slash ("/"), or equal
    -- ("=") and nothing else.
    local function handle_STAR()  -- Handle * or / or =
        if ch == "=" and nextChar() == "=" then
            add1()
            add1()
            state = DONE
            category = lexer.OP
        else
            add1()
            state = DONE
            category = lexer.OP
        end
    end

    local function handle_ANGBRACK()  -- Handle < or >
        if ch == "=" then
            add1()
            state = DONE
            category = lexer.OP
        else
            state = DONE
            category = lexer.OP
        end
    end

    -- ***** Table of State-Handler Functions *****

    handlers = {
        [DONE]=handle_DONE,
        [START]=handle_START,
        [LETTER]=handle_LETTER,
        [DIGIT]=handle_DIGIT,
        [DIGDOT]=handle_DIGDOT,
        [DOT]=handle_DOT,
        [PLUS]=handle_PLUS,
        [MINUS]=handle_MINUS,
        [STAR]=handle_STAR,
        [EXP]=handle_EXP,
        [STRING1]=handle_STRING1,
        [STRING2]=handle_STRING2,
        [ANGBRACK]=handle_ANGBRACK
    }

    -- ***** Iterator Function *****

    -- getLexeme
    -- Called each time through the for-in loop.
    -- Returns a pair: lexeme-string (string) and category (int), or
    -- nil, nil if no more lexemes.
    local function getLexeme(dummy1, dummy2)
        if pos > program:len() then
            return nil, nil
        end
        lexstr = ""
        state = START
        while state ~= DONE do
            ch = currChar()
            handlers[state]()
        end

        skipToNextLexeme()
        return lexstr, category
    end

    -- ***** Body of Function lex *****

    -- Initialize & return the iterator function
    pos = 1
    skipToNextLexeme()
    return getLexeme, nil, nil
end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************


return lexer

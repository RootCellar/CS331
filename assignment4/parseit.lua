-- Darian Marvel
-- 02/22/2022 (2's day)
-- Finishing parseit.lua for Tenrec
-- This file was started by Glenn G. Chappell


-- *********************************************************************

-- parseit.lua  INCOMPLETE
-- Glenn G. Chappell
-- 2022-02-16
--
-- For CS F331 / CSCE A331 Spring 2022
-- Solution to Assignment 4, Exercise 1
-- Requires lexit.lua

-- *********************************************************************

local lexit = require "lexit"


-- *********************************************************************
-- Module Table Initialization
-- *********************************************************************


local parseit = {}  -- Our module


-- *********************************************************************
-- Variables
-- *********************************************************************


-- For lexer iteration
local iter          -- Iterator returned by lexit.lex
local state         -- State for above iterator (maybe not used)
local lexer_out_s   -- Return value #1 from above iterator
local lexer_out_c   -- Return value #2 from above iterator

-- For current lexeme
local lexstr = ""   -- String form of current lexeme
local lexcat = 0    -- Category of current lexeme:
                    --  one of categories below, or 0 for past the end


-- *********************************************************************
-- Symbolic Constants for AST
-- *********************************************************************


local STMT_LIST    = 1
local PRINT_STMT   = 2
local RETURN_STMT  = 3
local ASSN_STMT    = 4
local FUNC_CALL    = 5
local FUNC_DEF     = 6
local IF_STMT      = 7
local WHILE_LOOP   = 8
local STRLIT_OUT   = 9
local CR_OUT       = 10
local CHAR_CALL    = 11
local BIN_OP       = 12
local UN_OP        = 13
local NUMLIT_VAL   = 14
local BOOLLIT_VAL  = 15
local READ_CALL    = 16
local SIMPLE_VAR   = 17
local ARRAY_VAR    = 18

local PARSEIT_PRINT_DEBUG = true

-- *********************************************************************
-- Utility Functions
-- *********************************************************************

-- print_debug
-- prints the given string if the PARSEIT_PRINT_DEBUG
-- constant above is true
local function print_debug(string)
  if(PARSEIT_PRINT_DEBUG) then
      print(string)
  end
end

-- advance
-- Go to next lexeme and load it into lexstr, lexcat.
-- Should be called once before any parsing is done.
-- Function init must be called before this function is called.
local function advance()
    -- Advance the iterator
    lexer_out_s, lexer_out_c = iter(state, lexer_out_s)

    -- If we're not past the end, copy current lexeme into vars
    if lexer_out_s ~= nil then
        lexstr, lexcat = lexer_out_s, lexer_out_c
    else
        lexstr, lexcat = "", 0
    end
end


-- init
-- Initial call. Sets input for parsing functions.
local function init(prog)
    iter, state, lexer_out_s = lexit.lex(prog)
    advance()
end


-- atEnd
-- Return true if pos has reached end of input.
-- Function init must be called before this function is called.
local function atEnd()
    return lexcat == 0
end


-- matchString
-- Given string, see if current lexeme string form is equal to it. If
-- so, then advance to next lexeme & return true. If not, then do not
-- advance, return false.
-- Function init must be called before this function is called.
local function matchString(s)
    if lexstr == s then
        advance()
        return true
    else
        return false
    end
end


-- matchCat
-- Given lexeme category (integer), see if current lexeme category is
-- equal to it. If so, then advance to next lexeme & return true. If
-- not, then do not advance, return false.
-- Function init must be called before this function is called.
local function matchCat(c)
    if lexcat == c then
        advance()
        return true
    else
        return false
    end
end


-- *********************************************************************
-- "local" Statements for Parsing Functions
-- *********************************************************************


local parse_program
local parse_stmt_list
local parse_simple_stmt
local parse_complex_stmt
local parse_print_arg
local parse_expr
local parse_compare_expr
local parse_arith_expr
local parse_term
local parse_factor


-- *********************************************************************
-- The Parser: Function "parse" - EXPORTED
-- *********************************************************************


-- parse
-- Given program, initialize parser and call parsing function for start
-- symbol. Returns pair of booleans & AST. First boolean indicates
-- successful parse or not. Second boolean indicates whether the parser
-- reached the end of the input or not. AST is only valid if first
-- boolean is true.
function parseit.parse(prog)
    -- Initialization
    init(prog)

    -- Get results from parsing
    local good, ast = parse_program()  -- Parse start symbol
    local done = atEnd()

    -- And return them
    return good, done, ast
end


-- *********************************************************************
-- Parsing Functions
-- *********************************************************************


-- Each of the following is a parsing function for a nonterminal in the
-- grammar. Each function parses the nonterminal in its name and returns
-- a pair: boolean, AST. On a successul parse, the boolean is true, the
-- AST is valid, and the current lexeme is just past the end of the
-- string the nonterminal expanded into. Otherwise, the boolean is
-- false, the AST is not valid, and no guarantees are made about the
-- current lexeme. See the AST Specification near the beginning of this
-- file for the format of the returned AST.

-- NOTE. Declare parsing functions "local" above, but not below. This
-- allows them to be called before their definitions.


-- parse_program
-- Parsing function for nonterminal "program".
-- Function init must be called before this function is called.
function parse_program()
    local good, ast

    good, ast = parse_stmt_list()
    return good, ast
end


-- parse_stmt_list
-- Parsing function for nonterminal "stmt_list".
-- Function init must be called before this function is called.
function parse_stmt_list()
    local good, ast1, ast2

    print_debug("parse_stmt_list")
    print_debug(lexstr)

    ast1 = { STMT_LIST }
    while true do
        if lexstr == "print"
          or lexstr == "return"
          or lexcat == lexit.ID then
            good, ast2 = parse_simple_stmt()
            if not good then
                return false, nil
            end
            if not matchString(";") then
                return false, nil
            end
        elseif lexstr == "func"
          or lexstr == "if"
          or lexstr == "while" then
            good, ast2 = parse_complex_stmt()
            if not good then
                return false, nil
            end
        else
            break
        end

        table.insert(ast1, ast2)
    end

    return true, ast1
end


-- parse_simple_stmt
-- Parsing function for nonterminal "simple_stmt".
-- Function init must be called before this function is called.
function parse_simple_stmt()

    print_debug("parse_simple_stmt")
    print_debug(lexstr)

    local good, ast1, ast2, savelex, arrayflag

    if matchString("print") then
        if not matchString("(") then
            return false, nil
        end

        if matchString(")") then
            return true, { PRINT_STMT }
        end

        good, ast1 = parse_print_arg()
        printValue(ast1)
        if not good then
            return false, nil
        end

        ast2 = { PRINT_STMT, ast1 }
        while matchString(",") do
            good, ast1 = parse_print_arg()
            if not good then
                return false, nil
            end
            table.insert(ast2, ast1)
        end


        if not matchString(")") then
            return false, nil
        end

        return true, ast2

    elseif matchString("return") then
        good, ast1 = parse_expr()
        if not good then
            return false, nil
        end

        return true, { RETURN_STMT, ast1 }

    elseif lexcat == lexit.ID then
      local id = lexstr
      advance()
      if matchString("(") and matchString(")") then
        return true, {FUNC_CALL, id}
      elseif matchString("=") then
        good, ast1 = parse_expr()
        if not good then
          return false, nil
        end
        return true, {ASSN_STMT, {SIMPLE_VAR, id}, ast1}
      elseif matchString("[") then
        good, ast1 = parse_expr()
        if not good then
          return false, nil
        end
        if not matchString("]") then
          return false, nil
        end
        if not matchString("=") then
          return false, nil
        end

        good, ast2 = parse_expr()
        if not good then
          return false, nil
        end

        return true, {ASSN_STMT, {ARRAY_VAR, id, ast1}, ast2}
      end
    else
      return false, nil
    end
end


-- parse_complex_stmt
-- Parsing function for nonterminal "complex_stmt".
-- Function init must be called before this function is called.
function parse_complex_stmt()

  print_debug("parse_complex_stmt")
  print_debug(lexstr)

    local good, exp, ast, ast2
    local cmplxTable = {}

    if matchString("func") then
      if not lexcat == lexit.ID then
        return false, nil
      end

      local id = lexstr
      advance()

      if not matchString("(") then
        return false, nil
      end
      if not matchString(")") then
        return false, nil
      end

      if not matchString("{") then
        return false, nil
      end

      good, ast1 = parse_stmt_list()
      if not good then
        return false, nil
      end

      if not matchString("}") then
        return false, nil
      end

      return true, { FUNC_DEF, id, ast1 }

    end

    local ifOrWhile = false
    local type

    if matchString("while") then
      type = WHILE_LOOP
      --table.insert(cmplxTable, WHILE_LOOP)
      cmplxTable = {WHILE_LOOP}
      ifOrWhile = true
    end
    if matchString("if") then
      type = IF_STMT
      --table.insert(cmplxTable, IF_STMT)
      cmplxTable = {IF_STMT}
      ifOrWhile = true
    end

    if ifOrWhile then

      if not matchString("(") then
        return false, nil
      end

      print_debug("ifOrWhile: exp")

      good, exp = parse_expr()
      if not good then
        return false, nil
      end

      print_debug("ifOrWhile: parsed expr")

      table.insert(cmplxTable, exp)

      if not matchString(")") then
        return false, nil
      end

      print_debug("ifOrWhile: before {")

      if not matchString("{") then
        return false, nil
      end

      print_debug("ifOrWhile: stmt_list")

      good, ast = parse_stmt_list()
      if not good then
        return false, nil
      end

      table.insert(cmplxTable, ast)

      if not matchString("}") then
        return false, nil
      end

      if type == IF_STMT then

        while matchString("elif") do


          if not matchString("(") then
            return false, nil
          end

          good, exp = parse_expr()
          if not good then
            return false, nil
          end

          table.insert(cmplxTable, exp)

          if not matchString(")") then
            return false, nil
          end

          if not matchString("{") then
            return false, nil
          end

          good, ast = parse_stmt_list()
          if not good then
            return false, nil
          end

          table.insert(cmplxTable, ast)

          if not matchString("}") then
            return false, nil
          end


        end

        if matchString("else") then
          hasElse = true

          if not matchString("{") then
            return false, nil
          end

          good, ast2 = parse_stmt_list()
          if not good then
            return false, nil
          end

          table.insert(cmplxTable, ast2)

          if not matchString("}") then
            return false, nil
          end

        end
      end

      return true, cmplxTable
    end

end


-- parse_print_arg
-- Parsing function for nonterminal "print_arg".
-- Function init must be called before this function is called.
function parse_print_arg()

  print_debug("parse_print_arg")
  print_debug(lexstr)

  if matchString("cr") then
    return {CR_OUT}
  end

  if lexcat == lexit.STRLIT then
    temp = lexstr
    advance()
    return true, {STRLIT_OUT, temp}
  end

  if matchString("char") and matchString("(") then
    local good, ast = parse_expr()
    if not good then
      return false, nil
    end
    if not matchString(")") then
      return false, nil
    end

    return true, {CHAR_CALL, ast}
  end

  local good, ast = parse_expr()
  if not good then
    return false, nil
  end
  return true, ast
end


-- parse_expr
-- Parsing function for nonterminal "expr".
-- Function init must be called before this function is called.
function parse_expr()

  print_debug("parse_expr")
  print_debug(lexstr)

  local good, factor = parse_compare_expr()
  if not good then
    return false, nil
  end

  if lexstr == "and" or lexstr == "or" then
    local op = lexstr
    advance()
    good, factor2 = parse_term()
    if not good then
      return false, nil
    end

    return true, {{BIN_OP, op}, factor, factor2}

  end

  return true, factor

end


-- parse_compare_expr
-- Parsing function for nonterminal "compare_expr".
-- Function init must be called before this function is called.
function parse_compare_expr()

  print_debug("parse_compare_expr")
  print_debug(lexstr)

  local good, factor = parse_arith_expr()
  if not good then
    return false, nil
  end

  if lexstr == "=="
    or lexstr == "!="
    or lexstr == "<"
    or lexstr == "<="
    or lexstr == ">"
    or lexstr == ">="
  then
    local op = lexstr
    advance()
    good, factor2 = parse_term()
    if not good then
      return false, nil
    end

    return true, {{BIN_OP, op}, factor, factor2}

  end

  return true, factor

end


-- parse_arith_expr
-- Parsing function for nonterminal "arith_expr".
-- Function init must be called before this function is called.
function parse_arith_expr()

  print_debug("parse_arith_expr")
  print_debug(lexstr)

  local good, factor = parse_term()
  if not good then
    return false, nil
  end

  if lexstr == "+" or lexstr == "-" then
    local op = lexstr
    advance()
    good, factor2 = parse_term()
    if not good then
      return false, nil
    end

    return true, {{BIN_OP, op}, factor, factor2}

  end

  return true, factor

end


-- parse_term
-- Parsing function for nonterminal "term".
-- Function init must be called before this function is called.
function parse_term()

    print_debug("parse_term")
    print_debug(lexstr)

    local good, factor = parse_factor()
    if not good then
      return false, nil
    end

    if not lexcat == lexit.OP then
      return true, factor
    end

    if not (lexstr == "*" or lexstr == "/" or lexstr == "%") then
      return true, factor
    end

    local table = {}
    local factor2

    if lexcat == lexit.OP then
      local op = lexstr
      advance()
      good, factor2 = parse_term()
      if not good then
        return false, nil
      end

      return true, {{BIN_OP, op}, factor, factor2}

    end

    return true, factor
end


-- parse_factor
-- Parsing function for nonterminal "factor".
-- Function init must be called before this function is called.
function parse_factor()

  print_debug("parse_factor")
  print_debug(lexstr)

  if matchString("(") then
    local good, ast = parse_expr()
    if not good then
      return false, nil
    end
    if not matchString(")") then
      return false, nil
    end

    return true, ast
  end

  if matchString("+") then
    local good, factor = parse_factor()
    if not good then
      return false, nil
    end

    return true, { {UN_OP, "+"}, factor}
  end

  if matchString("-") then
    local good, factor = parse_factor()
    if not good then
      return false, nil
    end

    return true, { {UN_OP, "-"}, factor}
  end

  if matchString("not") then
    local good, factor = parse_factor()
    if not good then
      return false, nil
    end

    return true, { {UN_OP, "not"}, factor}
  end

  if lexcat == lexit.NUMLIT then
    local val = lexstr
    advance()
    return true, {NUMLIT_VAL, val}
  end

  if matchString("true") then
    return true, {BOOLLIT_VAL, "true"}
  end
  if matchString("false") then
    return true, {BOOLLIT_VAL, "false"}
  end

  if matchString("read") then
    if matchString("(") and matchString(")") then
      return true, {READ_CALL}
    else
      return false, nil
    end
  end

  if lexcat == lexit.ID then
    local id = lexstr
    advance()

    if matchString("(") and matchString(")") then
      return true, {FUNC_CALL, id }
    elseif matchString("[") then
      local good, ast = parse_expr()
      if not good then
        return false, nil
      end

      if not matchString("]") then
        return false, nil
      end

      return true, {ARRAY_VAR, id, ast}
    else
      return true, {SIMPLE_VAR, id}
    end

  end

  return false, nil

end


-- *********************************************************************
-- Module Table Return
-- *********************************************************************

-- printValue
-- Given a value, print it in (roughly) Lua literal notation if it is
-- nil, number, string, boolean, or table -- calling this function
-- recursively for table keys and values. For other types, print an
-- indication of the type. The second argument, if passed, is max_items:
-- the maximum number of items in a table to print.
function printValue(...)
    assert(select("#", ...) == 1 or select("#", ...) == 2,
           "printValue: must pass 1 or 2 arguments")
    local x, max_items = select(1, ...)  -- Get args (may be nil)
    if type(max_items) ~= "nil" and type(max_items) ~= "number" then
        error("printValue: max_items must be a number")
    end

    if type(x) == "nil" then
        io.write("nil")
    elseif type(x) == "number" then
        io.write(x)
    elseif type(x) == "string" then
        io.write('"'..x..'"')
    elseif type(x) == "boolean" then
        if x then
            io.write("true")
        else
            io.write("false")
        end
    elseif type(x) ~= "table" then
        io.write('<'..type(x)..'>')
    else  -- type is "table"
        io.write("{")
        local first = true  -- First iteration of loop?
        local key_count, unprinted_count = 0, 0
        for k, v in pairs(x) do
            key_count = key_count + 1
            if max_items ~= nil and key_count > max_items then
                unprinted_count = unprinted_count + 1
            else
                if first then
                    first = false
                else
                    io.write(",")
                end
                io.write(" [")
                printValue(k, max_items)
                io.write("]=")
                printValue(v, max_items)
            end
        end
        if unprinted_count > 0 then
            if first then
                first = false
            else
                io.write(",")
            end
            io.write(" <<"..unprinted_count)
            if key_count - unprinted_count > 0 then
                io.write(" more")
            end
            if unprinted_count == 1 then
                io.write(" item>>")
            else
                io.write(" items>>")
            end
        end
        io.write(" }")
    end
end

return parseit

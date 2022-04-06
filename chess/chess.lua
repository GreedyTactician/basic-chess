--if this file is required from another directory, this variable will help us
--local foldername = (...):match("(.-)[^%.]+$") 

local function concatlist(...)
  local arg = {...}
  local ret = {}
  local c 
  for i = 1, #arg do
    c = arg[i] 
    for j = 1, #c do
      table.insert(ret, c[j])
    end
  end
  return ret
end

-- Save copied tables in `copies`, indexed by original table.
local function deepcopy(orig, copies)
    copies = copies or {}
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        if copies[orig] then
            copy = copies[orig]
        else
            copy = {}
            copies[orig] = copy
            for orig_key, orig_value in next, orig, nil do
                copy[deepcopy(orig_key, copies)] = deepcopy(orig_value, copies)
            end
            setmetatable(copy, deepcopy(getmetatable(orig), copies))
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function table_equal(t1, t2)

	local function subset(t11, t22)
	
		if not (type(t11) == "table" and type(t22) == "table") then
			return false
		end 
	
		for k, v in pairs(t11) do
		
			if t22[k] ~= v then
				if type(v) == "table" and type(t22[k]) == "table" then 
					if not (subset(v, t22[k]) and subset(t22[k], v)) then
						return false
					end
				else
					return false
				end
			end
			
		end
		return true
	end

	return t1 == t2 or subset(t1, t2) and subset(t2, t1)
end

function contain(t, elem, eq_func)
	if eq_func == nil then eq_func = function(a, b) return a == b end end
  for k, v in pairs(t) do
    if eq_func(elem, v) then 
      return true 
    end
  end
  return false
end


---------------------------------------------------------
--standard piece definitions on a standard board

local function define_standard_pieces()
	local piecedef = {}
	local ruleslib = require("examiners")

	local d = ruleslib.DIRS
	local pp = ruleslib.PIECE_PATTERNS
	local reg = ruleslib.define_regular_rule
	local pawn = ruleslib.define_pawn_rule
	local castle = ruleslib.define_castle_rule

	piecedef.whitepawn = {}
	table.insert(piecedef.whitepawn, pawn(d.UP, {"black"}, 2, 8, 5))
	piecedef.blackpawn = {}
	table.insert(piecedef.blackpawn, pawn(d.DOWN, {"white"}, 7, 1, 4))

	local othercolour
	local colours = {"black", "white"}
	for v, k in pairs(colours) do
	
		othercolour = colours[v%2+1]
		
		piecedef[k.."king"] = {}
		table.insert(piecedef[k.."king"], reg(pp["kinglike"], {othercolour}, 1))
		
		piecedef[k.."queen"] = {}
		table.insert(piecedef[k.."queen"], reg(pp["kinglike"], {othercolour}))
		
		piecedef[k.."bishop"] = {}
		table.insert(piecedef[k.."bishop"], reg(pp["diagonal"], {othercolour}))
		
		piecedef[k.."knight"] = {}
		table.insert(piecedef[k.."knight"], reg(pp["knight"], {othercolour}, 1))
		
		piecedef[k.."rook"] = {}
		table.insert(piecedef[k.."rook"], reg(pp["horizontalandvertical"], {othercolour}))
	end
	return piecedef
end


local function get_piece_to_def_table()
  local ret = define_standard_pieces()
  local mt = {}

  mt.__index = function(t, k)
  	if type(k) == "table" then
      return t[k[2]..k[1]]
    end
  end

  mt.__newindex = function(t, k, v)
    if type(k) == "number" or type(k) == "string" then
      rawset(t, k, v)
    elseif type(k) == "table" then
      rawset(t, k[2]..k[1], v)
    end
  end

  setmetatable(ret, mt)
  return ret
end
---------------------------------------------

--functions that determine a piece of information at a particular point of the board
local function get_colour(board, square)
	assert(square[1] ~= nil and square[2] ~= nil, "That's not a square")
	local temp = board(square)

	if temp == nil then
		return temp
	else
		return temp[2] or temp[1]
	end
end

local function get_column_last_ply_double_pawn(state)

	local last_ply = state.ply_history[#state.ply_history]
	
	if last_ply == nil then return end
	
	if last_ply[4] == "double move pawn" then
		assert(last_ply[2][1] == last_ply[3][1] or last_ply[2][2] == last_ply[3][2], "A pawn is double moving in two axis?")
		--finding which is the column
		return last_ply[2][1] == last_ply[3][1] and last_ply[3][1] or last_ply[2][2]
	end
end

local function square_under_threat(board, owncolour)

end

---------------------
--functions that packages all the information a given rule requires in a function
local function get_regular_rule_info(state, square)
	local initial_info = {square}
	local get_info_func = function(k)
		return get_colour(state.board, k) 
	end
	return initial_info, get_info_func
end

local function get_pawn_rule_info(state, square)
	local initial_info = {square, get_column_last_ply_double_pawn(state)}
	local get_info_func = function(k)
		return get_colour(state.board, k) 
	end
	return initial_info, get_info_func
end

local function get_castle_rule_info(state, square)
	local initial_info = {square}
	local get_info_func = function(k)
		return get_colour(state.board, k), square_under_threat(state.board, get_colour(state.board, k))
	end
	return initial_info, get_info_func
end
--table that packages all the functions that provide the information for the rules
local info_funcs_table = {}
info_funcs_table.regular = get_regular_rule_info
info_funcs_table.pawn = get_pawn_rule_info
info_funcs_table.castling = get_castle_rule_info


local function get_movement(state, square)
	--get the set of rules for that piece
	local examiners = state.piecedefinitions[state.board(square)]
	local e, etype, efunc, temp
	local ret = {}
	--for each rule in the set
	for i = 1, #examiners do
		e = examiners[i]
		etype = e[1]
		efunc = e[2]
		--get the possible squares the piece can move to
		temp = efunc(info_funcs_table[etype](state, square))

		--add the moves
		for i = 1, #temp do
			table.insert(ret, temp[i])
		end
	end
	
	--we could sort through the illegal moves here

	--return all the moves in one list
	return ret
end
---------------------------





local function new_standard_board()

	local BOARD_AND_TRANSFORM = require("board")
  board = BOARD_AND_TRANSFORM.new_board()
 
  --setting board space
  for x = 0, 7 do
    for y = 0, 7 do
      board[x][y] = {"empty square"}
    end
  end

  for x = 0, 7 do
    --setting pawns
    board[x][1] = {"pawn", "white"}
    board[x][6] = {"pawn", "black"}
  end

  --setting rooks
  board[0][0] = {"rook", "white"}
  board[7][0] = {"rook", "white"}
  board[0][7] = {"rook", "black"}
  board[7][7] = {"rook", "black"}

  --setting knights
  board[1][0] = {"knight", "white"}
  board[6][0] = {"knight", "white"}
  board[1][7] = {"knight", "black"}
  board[6][7] = {"knight", "black"}
  --
  -- --setting bishops
  board[2][0] = {"bishop", "white"}
  board[5][0] = {"bishop", "white"}
  board[2][7] = {"bishop", "black"}
  board[5][7] = {"bishop", "black"}

  --setting kings and queens
  board[3][0] = {"queen", "white"}
  board[4][0] = {"king", "white"}
  board[3][7] = {"queen", "black"}
  board[4][7] = {"king", "black"}
  return board
end




--assumes a standard board
local function find_keys_with_piece_of_colour(board, colour)
  local ret = {}

  for x = 0, 7 do
    for y = 0, 7 do
      if board({x, y})[2] == colour then table.insert(ret, {x, y}) end
    end
  end
	
  return ret
end

local function get_possible_ply(state, colour)
	local squares = find_keys_with_piece_of_colour(state.board, colour)
	local ret = {}
	local temp
	--TODO: table.append instead of a for loop
	for i = 1, #squares do
		temp = get_movement(state, squares[i])

		--add the moves
		for i = 1, #temp do
			table.insert(ret, temp[i])
		end
	end 
	--perhaps sort illegal moves here
	return ret
end

local function is_legal_ply(state, ply)
	local tc = {[0] = "white", "black"}
	local turnof = tc[#state.ply_history%2]

	local plys = get_possible_ply(state, turnof)

	return contain(plys, ply, table_equal)
end

--ignores illegal moves (kings are captured as victory condition)
local function is_complete(state)
	--look for kings on both sides
	local white_pieces = find_keys_with_piece_of_colour(stae.board, "white")
	local black_pieces = find_keys_with_piece_of_colour(stae.board, "black")

	local function isking(piece)
		return piece[1] == "king"
	end

	local w_hasking = false
	local b_hasking = false
	--find white king
	for i = 1, #white_pieces do
		if isking(white_pieces[i]) then
			w_hasking = true
			break
		end
	end
	--find black king
	for i = 1, #black_pieces do
		if isking(black_pieces[i]) then
			b_hasking = true
			break
		end
	end
	--a king has to be present
	assert(w_hasking or b_hasking, "Missing both kings")
	--if one king isn't present, declare victory to the other colour 
	if not w_hasking then return true, "black" end
	if not b_hasking then return true, "white" end

	return false
end


--transforms input
local function applyply(board, ply, listeners)
	local BOARD_AND_TRANSFORM = require("board")
  local transformations = BOARD_AND_TRANSFORM.transformations

  if ply[1] == "regular_ply" then 
    transformations[ply[1]](board, ply[2], ply[3])
  end
  if ply[1] == "promotion" then 
    --get player input here
    local playerinput
		if listeners.get_promotion_player_input ~= nil then
			playerinput = listeners.get_promotion_player_input()
		end
		if playerinput == nil then
			playerinput = {"queen", board(ply[2])[2]}
		end
    transformations[ply[1]](board, ply[2], ply[3], playerinput)
  end
  if ply[1] == "en_passant" then
    transformations[ply[1]](board, ply[2], ply[3], ply[4])
  end
  if ply[1] == "castling" then 
    transformations[ply[1]](board, ply[2], ply[3])
  end
end



local function initial_standard_game_state()

  local state = {}
  
  state.board = new_standard_board()
  state.piecedefinitions = get_piece_to_def_table()
	state.ply_history = {}

  return state  
end 

local function new_standard_game(get_promotion_player_input)
  local ret = {}

  ret.current_state = initial_standard_game_state()

  ret.state_history = {current_state}

	--only one input here, but another game could presumebly have more
	local listeners = {}
	listeners.get_promotion_player_input = get_promotion_player_input
  
  local mt = {}
  local tc = {[0] = "white", "black"}
  mt.__index = function(t, k)
  	if k == "board" then
  		return t.current_state.board
  	end
		if k == "turnof" then
			return tc[#t.state_history%2]
		end
		if k == "get_all_ply_for_current_player" then
			return get_possible_ply(t.current_state, t.turnof)
		end
		if k == "get_ply_for" then
			return function(x, y) return get_movement(t.current_state, {x, y}) end
		end
		if k == "play" then
			--note that illegal moves can be played. the ply isnt checked here
			return function(ply)
				t.current_state = deepcopy(t.current_state)
				table.insert(t.state_history, t.current_state)
				applyply(t.current_state.board, ply, listeners)
				table.insert(t.current_state.ply_history, ply)
			end
		end
		if k == "play_legal_ply" then
			return function(ply)
				assert(is_legal_ply(t.current_state, ply), "Not a legal move!")
				return t.play(ply)
			end
		end
		
  	return rawget(t, k)
  end
  
  setmetatable(ret, mt)

  return ret
end


return new_standard_game


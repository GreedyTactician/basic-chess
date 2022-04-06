
local function contain(t, elem)
  for k, v in pairs(t) do
    if elem == v then 
      return true 
    end
  end
  return false
end

function andf(list)
	for i = 1, #list do
		if true ~= list[i] then return false end
	end
	return true
end


----------------------
local UP = {0, 1}
local DOWN = {0, -1}
local RIGHT = {1, 0}
local LEFT = {-1, 0}

local DIRS = {UP = UP, DOWN=DOWN, RIGHT=RIGHT, LEFT=LEFT}


local mt_2d_addandsub = {}
--metatable to define operations
mt_2d_addandsub.__add = function(a, b)
  local ret = {a[1]+b[1], a[2]+b[2]}
  setmetatable(ret, getmetatable(a) or getmetatable(b))
  return ret
end

mt_2d_addandsub.__sub = function(a, b)
  local ret = {a[1]-b[1], a[2]-b[2]}
  setmetatable(ret, getmetatable(a) or getmetatable(b))
  return ret
end
	
setmetatable(UP, mt_2d_addandsub)
setmetatable(DOWN, mt_2d_addandsub)
setmetatable(RIGHT, mt_2d_addandsub)
setmetatable(LEFT, mt_2d_addandsub)

local PIECE_PATTERNS = {}
PIECE_PATTERNS["diagonal"] = {UP+RIGHT, UP+LEFT, DOWN+RIGHT, DOWN+LEFT}
PIECE_PATTERNS["horizontalandvertical"] = {UP, LEFT, DOWN, RIGHT}
PIECE_PATTERNS["kinglike"] = {UP+RIGHT, UP+LEFT, DOWN+RIGHT, DOWN+LEFT, UP, DOWN, LEFT, RIGHT}
PIECE_PATTERNS["knight"] = {UP+UP+LEFT, UP+UP+RIGHT, DOWN+ DOWN+LEFT, DOWN+DOWN+RIGHT, LEFT +LEFT+UP, LEFT+LEFT+DOWN, RIGHT+RIGHT+UP, RIGHT+RIGHT+DOWN}
---------------------------------------------------------------------------------------  

--returns a closure that takes initial_info and get_info_func
--the following rules had a 2d square grid in mind
--initial_info and get_info_func is defined on a rule by rule basis



--initial_info = {key_of_initial_square}
--get_info_func(key) returns the colour of the piece on that square or 'empty square'
local function define_regular_rule(directions, colours, range)


  --update the direction
  local function new_direction(state)
    state.current_direction = state.current_direction + 1
		state.done = directions[state.current_direction] == nil
		
		if state.done then return end
		
    state.current_square = state.initial_square + directions[state.current_direction]
    state.distance_moved_in_this_direction = 1
    
  end

  local function inform(state, colour)
    local iscapture = contain(colours, colour)
    local ismove = colour == "empty square" 
    local ply = state.current_square
      
    --if its a capture or not a square you can move to
    if not ismove then 
      new_direction(state)
    else
      state.distance_moved_in_this_direction = state.distance_moved_in_this_direction+1
      if range ~= nil and range < state.distance_moved_in_this_direction then 
        new_direction(state)
      else
        state.current_square = state.current_square + directions[state.current_direction]
      end
    end
		
    --only captures and moves are valid moves
    if (iscapture or ismove) then
			table.insert(state.returnval, {"regular_ply", state.initial_square, ply})
		end
  end

  local function get_ply(initial_info, get_info_func)
		
		local state = {}
    state.done = false 
    state.initial_square = unpack(initial_info)
    state.current_direction = 0
		new_direction(state)

		state.returnval = {}

		while not state.done do 
			inform(state, get_info_func(state.current_square))
  	end

    return state.returnval
  end
  return {"regular", get_ply}
end
    


  --this function defines the rules for a pawn
	--initial_info = {key_of_initial_square, double_move_pawn_column}
--get_info_func(key) returns the colour of the piece on that square or 'empty square'
local function define_pawn_rule(direction_of_movement, colours, rank_to_double_move, rank_to_promote, rank_enpassant)

	-- +1 because the array starts from 0 but I'd rather keep the rank numbering that chess community uses (which starts from 1)
	rank_to_double_move = rank_to_double_move - 1
	rank_to_promote = rank_to_promote - 1
	rank_enpassant = rank_enpassant - 1

  assert(direction_of_movement[1] == 0 or direction_of_movement[2] == 0, "The direction of movement is not along only one axis.")
  assert(math.abs(direction_of_movement[1]) + math.abs(direction_of_movement[2]) == 1, "The direction of movement must be a unit vector.")

	setmetatable(direction_of_movement, mt_2d_addandsub)

	
  local function get_rank_and_column(square)
    --we only go horizontally or vertically (see assert above)
		-- so either {x, 0} or {0, x}
    local dir = direction_of_movement[1] ~= 0 and 1 or 2
    local dir2 = direction_of_movement[1] ~= 0 and 2 or 1

		
    return square[dir], square[dir2]
  end

  local function make_square(rank, column)
    local dir = direction_of_movement[1] ~= 0 and 1 or 2
    local dir2 = direction_of_movement[1] ~= 0 and 2 or 1

    local ret = {}

    ret[dir] = rank
    ret[dir2] = column
    return ret
  end


	local function empty_square(k, f)
		return "empty square" == f(k)
	end

	local function opponants_colour(k, f)
		return contain(colours, f(k))
	end

  local function get_ply(initial_info, get_info_func)

    local state = {}
    state.done = false 
    state.initial_square = initial_info[1]
    local column_enpassant = initial_info[2]

    state.currentply = 1

		state.returnval = {}
		
    local rank, column = get_rank_and_column(state.initial_square)
    local dir_is_positive = direction_of_movement[1] > 0 or direction_of_movement[2] > 0 
    local rankincrement = dir_is_positive and 1 or -1

		local temp
      --generate all possible moves here
      
      --check for en passant
    if column_enpassant ~= nil and math.abs(column_enpassant-column) == 1 and rank == rank_enpassant then
		
      -- {transformation, init square, destination square, dead pawn square}
      temp = {"en_passant", state.initial_square, make_square(rank+rankincrement, column_enpassant), make_square(rank, column_enpassant)}
			table.insert(state.returnval, temp)
    end
   
    --are we one rank before promotion?
    local movetype = rank+rankincrement == rank_to_promote and "promotion" or "regular_ply"
    --move forward
    temp = {movetype, state.initial_square, make_square(rank+rankincrement, column)}
		
    if empty_square(temp[3], get_info_func) then table.insert(state.returnval, temp) end

		 --double move
    if rank == rank_to_double_move then 
      temp = {"regular_ply", state.initial_square, make_square(rank+2*rankincrement, column), "double move pawn"}

			--if the piece right in front or the destination square is empty 
			if empty_square(temp[3], get_info_func) and empty_square(temp[2]+direction_of_movement, get_info_func) then
				table.insert(state.returnval, temp)
			end
    end
		
    --captures
    temp = {movetype, state.initial_square, make_square(rank+rankincrement, column+1)}
    if opponants_colour(temp[3], get_info_func) then table.insert(state.returnval, temp) end

    temp = {movetype, state.initial_square, make_square(rank+rankincrement, column-1)}
    if opponants_colour(temp[3], get_info_func) then table.insert(state.returnval, temp) end
    return state.returnval
  end

      
  return {"pawn", get_ply}
end

  --rule type: castle


local function define_castle_rule()
     

  local function get_ply(initial_square)

    local state = {}
    state.done = false 
    state.initial_square = initial_square
		state.returnval = {}

    return state.returnval
  end

  return {"castling", get_ply}
end
  
return {PIECE_PATTERNS = PIECE_PATTERNS,
DIRS = DIRS,
define_castle_rule = define_castle_rule,
define_pawn_rule = define_pawn_rule,
define_regular_rule = define_regular_rule}

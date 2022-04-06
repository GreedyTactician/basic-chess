
local function new_board()

  local board = {}
  board.metadata = {undocommands = {}}
	
  local bmt = {}
	
  bmt.__index = function(t, k)

    if type(k) == "number" then
  --this is just to avoid having to initialise the 2d array for each new x
  --it will also prevent errors when we try to look for indices outside the array
  --eg. self.board[0][8] would normally be an error, but now its just nil
      if rawget(t, k) == nil then
        rawset(t, k, {})
      end 
      return rawget(t, k)
  --before if you have position and a board: board[position[1]][position[2]]
  --now you can do this instead: board[position]
    elseif type(k) == "table" then
			assert(#k >= 2 and t[k[1]] ~= nil, "Wrong arguments in table.")
      return t[k[1]][k[2]]
		elseif type(k) == "string" then
		
			if k == "colour" then
				return function(a, b)
					if type(a) == "table" then
						return t[a][2]
					elseif type(a) == "number" and type(b) == "number" then
						return t[a][b][2]
					end
				end
			end

			
    end

  end
	
  --and this works with setting values too
  bmt.__newindex = function(t, k, v)
    if type(k) == "number" then
      rawset(t, k, v)
    elseif type(k) == "table" then
      rawset(t[k[1]], k[2], v)
    end
  end
	bmt.__tostring = function(t)
		local str = {}
		local temp 
		for i = 0, #t do
			for j = 0, #t[i] do
				temp = t[i][j]
				if temp == nil then table.insert(str, "~") else
					table.insert(str, string.sub(temp[1], 1, 1)..string.sub(temp[2] or "", 1, 1))
					table.insert(str, " ")
				end
			end
			table.insert(str, "\n")
		end
		return table.concat(str)
	end

  bmt.__call = function(t, ...)
    local arg = {...}
    
    --all one argument stuff
    if #arg == 1 then 
      if type(arg[1]) == "table" then 
        return t[arg[1]]
      end
    end
    --otherwise, follow a string command
    if type(arg[1]) == "string" then  
      if arg[1] == "set" then 
        table.insert(t.metadata.undocommands, {"set", arg[2], t[arg[2]]})
        t[arg[2]] = arg[3]
        return 
      end

      if arg[1] == "undo" then
        t(table.unpack(table.remove(t.metadata.undocommands)))
      end
      
      if arg[1] == "undo block" then 
        while #t.metadata.undocommands > 0 and t.metadata.undocommands[#t.metadata.undocommands][1] ~= "startblock" do
          t("undo")
        end
        table.remove(t.metadata.undocommands)
      end

      if arg[1] == "end" then 
        table.insert(t.metadata.undocommands, {"endblock"})
      end
    
      if arg[1] == "endblock" then 
        assert(table.remove(t.metadata.undocommands)[1] == "endblock")
      end

      if arg[1] == "start" then 
        table.insert(t.metadata.undocommands, {"start"})
      end

      if arg[1] == "startblock" then 
        assert(table.remove(t.metadata.undocommands)[1] == "startblock")
      end


    end
  end

  setmetatable(board, bmt)
  return board
end

 
 
--transformations on the board
local transformations = {}
--the board should be able to be called like a function and take {x, y} argument that returns the piece on that square
--and take the board('set', {x, y}, piece) to set the piece on that square
--calling board('start') and board('end') marks the begeining and end of the move
--board('undo') removes the last move 
--
function transformations.regular_ply(board, start_square, end_square)
  board("start")  
  local piece_removed = board(end_square)
  local moving_piece = board(start_square)

  board("set", end_square, moving_piece)
  board("set", start_square, {"empty square"})
  board("end")
	
end

function transformations.en_passant(board, start_square, end_square, pawn)
  board("start")
  transformations.regular_ply(board, start_square, end_square)
  board("set", pawn, {"empty square"})
  board("end")
end

function transformations.castling(board, king_position, rook_position)
  board("start")
  local d = {rook_position[1] - king_position[1], rook_position[2] - king_position[2]}
  d = {d[1] ~= 0 and 1 or 0, d[2] ~= 0 and 1 or 0}
  local king = board(king_position)
  local rook = board(rook_position)
  
  board(king_position, {"empty square"})
  board(rook_position, {"empty square"})
  local newpositionking = {king_position[1] + 2*d[1], king_position[2] + 2*d[2]}
  local newpositionrook = {rook_position[1] + d[1], rook_position[2] + d[2]}
  
  board("set", newpositionking, king)
  board("set", newpositionrook, rook)
  board("end")
end

function transformations.promotion(board, start_square, end_square, piece_chosen)

  board("start")
  local piece_removed = board(end_square)
  local moving_piece = board(start_square)
  board("set", end_square, piece_chosen)
  board("set", start_square, {"empty square"})
  board("end")
end

return {new_board = new_board, transformations = transformations}

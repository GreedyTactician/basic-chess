inspect = require("inspect")
function init(funcs, width, height)	
	
	local LOAD_IMAGE = funcs[1] --(path)
	local QUAD = funcs[2] --(x1, y1, x2, y2, s1, s2)
	local DRAW_SQUARE = funcs[3] --(x, y, w, h, r, g, b)
	local DRAW_IMAGE = funcs[4] --(imgID, x, y, sx, sy, quadID) default quad is the whole image
	local DRAW_CIRCLE = funcs[5] --(x, y, r, R, G, B)
	local GET_DIMENSIONS = funcs[6] --(imgID)
	
	--init
	local BOARDSIZE = {width, height}
	--BOARDCANVAS = love.graphics.newCanvas(BOARDSIZE[1], BOARDSIZE[2])
	local BOARDCANVAS_PREPIECE_DRAW_TODO = {}
	local BOARDCANVAS_POSTPIECE_DRAW_TODO = {}
	local BOARDCANVAS_PREPIECE_DRAW_TODO_OLD = {}
	local BOARDCANVAS_POSTPIECE_DRAW_TODO_OLD = {}
	
	------------------------------------------------------------ premature definitions for variable definitions 
	local function apply_path(t, path)
		local ret = t
		for i = 1, #path do 
			ret = ret[path[i]]
			
			if ret == nil then return end 
		end
		return ret
	end

	local function forge_path(t, path, val)
		local ret = t
		for i = 1, #path-1 do
			if ret[path[i]] == nil then ret[path[i]] = {} end
			ret = ret[path[i]]
		end
		ret[path[#path]] = val
	end
	
	
	local function make_MAP_SQUARE_CLICKED_TO_ACTION()
		local ret = {}
		local mt = {}
		mt.__index = function(t, k)
			if type(k) == "table" then
				return apply_path(t, k)
			end
			return rawget(t, k)
		end
		mt.__newindex = function(t, k, v)
			if type(k) == "table" then
				return forge_path(t, k, v)
			end
			return rawset(t, k, v)
		end
		setmetatable(ret, mt)
		return ret
	end
	
	
	local function init_quads()

	 	local CHESS_SET = LOAD_IMAGE("chessset.png")

		-- transform = love.math.newTransform( )
		-- transform:scale(0.45, 0.45)

		local x, y = GET_DIMENSIONS(CHESS_SET)
		local PIECE_XSIZE = x/12
		local PIECE_YSIZE = y

		 

		local xsize= PIECE_XSIZE
		local ysize= PIECE_YSIZE

		local ret = {}

		--setting up each individual piece from the sprite sheet
		ret.blackking = QUAD(0, 0, xsize, ysize, x, y)
		ret.blackqueen = QUAD(xsize*1, 0, xsize, ysize, x, y)
		ret.blackrook = QUAD(xsize*2, 0, xsize, ysize, x, y)
		ret.blackbishop = QUAD(xsize*3, 0, xsize, ysize, x, y)
		ret.blackknight = QUAD(xsize*4, 0, xsize, ysize, x, y)
		ret.blackpawn = QUAD(xsize*5, 0, xsize, ysize, x, y)
		ret.whiteking = QUAD(xsize*6, 0, xsize, ysize, x, y)
		ret.whitequeen = QUAD(xsize*7, 0, xsize, ysize, x, y)
		ret.whiterook = QUAD(xsize*8, 0, xsize, ysize, x, y)
		ret.whitebishop = QUAD(xsize*9, 0, xsize, ysize, x, y)
		ret.whiteknight = QUAD(xsize*10, 0, xsize, ysize, x, y)
		ret.whitepawn = QUAD(xsize*11, 0, xsize, ysize, x, y)
		
		ret.kingblack = blackking
		ret.queenblack = blackqueen
		ret.kingwhite = whiteking
		ret.rookwhite = whiterook
		ret.pawnwhite = whitepawn
		ret.bishopwhite = whitebishop
		ret.knightwhite = whiteknight
		ret.rookblack = blackrook
		ret.pawnblack = blackpawn
		ret.bishopblack = blackbishop
		ret.knightblack = blackknight
		ret.null = QUAD(0, 0, 0, 0, x, y)
		return ret, CHESS_SET, {PIECE_XSIZE, PIECE_YSIZE}
	end
	----------------------------------------------------------
	

	local MAP_SQUARE_CLICKED_TO_ACTION = make_MAP_SQUARE_CLICKED_TO_ACTION()
	
	local SELECTED_SQUARE = {}
	
	local QUADS, QUADIMG, PIECESIZE = init_quads()

	local create_game = require("chess")

	local GAME = create_game()
	
	local UPDATED = false

	--keeps fetching the latest board and translate the content of the square to the string key for quads
	local BOARDWRAPPER = {}

	local mt = {game = GAME}

	mt.__index = function(t, k)

		local temp = getmetatable(t).game.board[k[1]][k[2]]
		if temp == nil then
			error("why")
			return nil
		elseif temp[1] == "empty square" then
			return "null"
		else
			return temp[2]..temp[1]
		end
	end
	setmetatable(BOARDWRAPPER, mt)
	
	

	-------------- END OF INIT
	----functions definitions below


	local function draw_board(board, xsize, ysize, quadimage, piece_to_quads, piecesize, prepiecetodo, postpiecetodo)
		--computing important values
		--local xsize = canvas:getPixelWidth()
		--local ysize = canvas:getPixelHeight()

		local xsizesquare = xsize/8
		local ysizesquare = ysize/8

		local PIECE_XSIZE = piecesize[1]
		local PIECE_YSIZE = piecesize[2]

		local shrinkage = 0.9
		local xpiecescale = (xsizesquare/PIECE_XSIZE)*shrinkage
		local ypiecescale = (ysizesquare/PIECE_YSIZE)*shrinkage

		local realxpiecesize = xpiecescale*PIECE_XSIZE
		local realypiecesize = ypiecescale*PIECE_YSIZE

		local xcenteroffset = (1-shrinkage)*realxpiecesize/2
		local ycenteroffset = (1-shrinkage)*realypiecesize/2


		DRAW_SQUARE(0, 0, xsize, ysize, 0.6, 0.3, 0, 1)


		for x = 0, 7 do
		  for y = 0, 7 do
		    if x%2 == y%2 then
		      DRAW_SQUARE(x*xsizesquare, y*ysizesquare, xsizesquare, ysizesquare, 0, 0.7, 0.7, 1)
		    end
		  end
		end

		---draw the prepiece stuff

		for i = 1, #prepiecetodo do
			prepiecetodo[i]()
		end

		---------putting each piece on the board

		for x = 0, 7 do
		  for y = 0, 7 do
		  	DRAW_IMAGE(quadimage, x*xsizesquare+xcenteroffset, y*ysizesquare+ycenteroffset, xpiecescale, ypiecescale, piece_to_quads[board[{x, y}]])
		    --love.graphics.draw(quadimage, piece_to_quads[board[{x, y}]], math.floor(x*xsizesquare+xcenteroffset), (ysize-realypiecesize)-math.floor(y*ysizesquare+ycenteroffset), 0, xpiecescale, ypiecescale)
		  end
		end

			---draw the postpiece stuff

		for i = 1, #prepiecetodo do
			postpiecetodo[i]()
		end

	-------------
		--love.graphics.setCanvas()
	end
	
		--takes the on_screen coords and returns the in_game coords
	local function to_game_coordinates(x, y, xsize, ysize, xflip, yflip)
		local xsizesquare = xsize/8
		local ysizesquare = ysize/8
		
		local x = xflip and 7-math.floor(x/xsizesquare) or math.floor(x/xsizesquare)
		
		local y = yflip and 7-math.floor(y/ysizesquare) or math.floor(y/ysizesquare)

		return x, y
	end

	local function to_screen_coordinates(x, y, xsize, ysize, xflip, yflip)
		local xsizesquare = xsize/8
		local ysizesquare = ysize/8

		local x = xflip and xsize-(x+1)*xsizesquare or x*xsizesquare
		local y = yflip and ysize-(y+1)*ysizesquare or y*ysizesquare

		return x, y
	end

	local function paint_selected_square(x, y, xsizesquare, ysizesquare)
		
			--paints a red square on the selected square
		 local xx, yy = to_screen_coordinates(x, y, 8*xsizesquare, 8*ysizesquare)

		 DRAW_SQUARE(xx, yy, xsizesquare, ysizesquare, 1, 0, 0, 1)
	end

	local function paint_ply(xsizesquare, ysizesquare, ply)

		if ply[1] == "regular_ply" or ply[1] == "promotion" or ply[1] == "en_passant"  then 
			local xx, yy = to_screen_coordinates(ply[3][1], ply[3][2], 8*xsizesquare, 8*ysizesquare)

			DRAW_CIRCLE(xx+xsizesquare/2, yy+ysizesquare/2, 0.8*xsizesquare/2, 0.2, 0.2, 0.2, 0.2)
		end
	end




	local function draw()

		
		if not UPDATED then 
			draw_board(BOARDWRAPPER, BOARDSIZE[1], BOARDSIZE[2], QUADIMG, QUADS, PIECESIZE, BOARDCANVAS_PREPIECE_DRAW_TODO, BOARDCANVAS_POSTPIECE_DRAW_TODO)
		
			BOARDCANVAS_PREPIECE_DRAW_TODO_OLD = BOARDCANVAS_PREPIECE_DRAW_TODO
			BOARDCANVAS_POSTPIECE_DRAW_TODO_OLD = BOARDCANVAS_POSTPIECE_DRAW_TODO
			BOARDCANVAS_PREPIECE_DRAW_TODO = {}
			BOARDCANVAS_POSTPIECE_DRAW_TODO = {}
		else
			draw_board(BOARDWRAPPER, BOARDSIZE[1], BOARDSIZE[2], QUADIMG, QUADS, PIECESIZE, BOARDCANVAS_PREPIECE_DRAW_TODO_OLD, BOARDCANVAS_POSTPIECE_DRAW_TODO_OLD)
		end
		
		UPDATED = true

	end
	
	local function undo()
		GAME.undo()
	end

	--manages clicks on the board
	local function board_clicked(x, y)

		--if its a move, play it
		if MAP_SQUARE_CLICKED_TO_ACTION[{x, y}] ~= nil then
			GAME.play_legal_ply(MAP_SQUARE_CLICKED_TO_ACTION[{x, y}])
			--remove older moves
			MAP_SQUARE_CLICKED_TO_ACTION = make_MAP_SQUARE_CLICKED_TO_ACTION()
			return 
		end
		MAP_SQUARE_CLICKED_TO_ACTION = make_MAP_SQUARE_CLICKED_TO_ACTION()

		--only select a square if there is a piece of the player who is playing
		if GAME.board.colour(x, y) == GAME.turnof then
			--colour the square
			table.insert(BOARDCANVAS_PREPIECE_DRAW_TODO, function() paint_selected_square(x, y, BOARDSIZE[1]/8, BOARDSIZE[2]/8) end)

			--get the moves (or ply) possible with that piece
			local plys = GAME.get_ply_for(x, y)

			--show the possible moves
			table.insert(BOARDCANVAS_POSTPIECE_DRAW_TODO, function()
				for i = 1, #plys do
					paint_ply(BOARDSIZE[1]/8, BOARDSIZE[2]/8, plys[i]) 
				end
			end)
			
			--allow the player to click on the squares to play
			local temp
			for i = 1, #plys do
				temp = plys[i]
				
				if temp[1] == "regular_ply" or temp[1] == "promotion" or temp[1] == "en_passant" then
					assert(MAP_SQUARE_CLICKED_TO_ACTION[temp[3]] == nil, "Some bug somewhere")
					MAP_SQUARE_CLICKED_TO_ACTION[temp[3]] = temp
				end

			end
				
		end
		
	end


	local function mousepressed( x, y, xscreen, yscreen, xflip, yflip)
		UPDATED = false
	--  local on_screen_square_clicked = {math.floor(8*x/BOARDSIZE[1]), math.floor(8*y/BOARDSIZE[2])}
		board_clicked(to_game_coordinates(x, y, xscreen or BOARDSIZE[1], yscreen or BOARDSIZE[2],  xflip, yflip))

	end
	
	return {mousepressed = mousepressed, draw = draw, updated = function() return UPDATED end, undo = undo}
end

return init


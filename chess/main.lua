function love.load()

	--configure bindings
	local LOAD_IMAGE = function(path) return love.graphics.newImage(path) end --(path)
	local QUAD = function(x1, y1, x2, y2, s1, s2) return love.graphics.newQuad(x1, y1, x2, y2, s1, s2) end --(x1, y1, x2, y2, s1, s2)
	local DRAW_SQUARE = function(x, y, w, h, r, g, b, a)   love.graphics.setColor(r, g, b, a or 1) love.graphics.rectangle("fill", x, y, w, h) love.graphics.setColor(1, 1, 1, 1) end--(x, y, w, h, r, g, b)
	local DRAW_IMAGE = 
		function(imgID, x, y, sx, sy, quadID) --(imgID, x, y, sx, sy, quadID) default quad is the whole image
			if quadID == nil then 
				love.graphics.draw(imgID, x, y, 0, sx, sy)
			else
				love.graphics.draw(imgID, quadID, x, y, 0, sx, sy)
			end
		end
	local DRAW_CIRCLE = function(x, y, R, r, g, b, a) love.graphics.setColor(r, g, b, a or 1) love.graphics.circle("fill", x, y, R) love.graphics.setColor(1, 1, 1, 1) end  --(x, y, r, R, G, B)
	local GET_DIMENSIONS = function(imgID) return imgID:getDimensions() end --(imgID)
	
	local funcs = {LOAD_IMAGE, QUAD, DRAW_SQUARE, DRAW_IMAGE, DRAW_CIRCLE, GET_DIMENSIONS}

	local chessdraw = require("draw")
	
	local width, height = love.graphics.getDimensions()
	local ret = chessdraw(funcs, width, height)
	
	ISUPDATED = ret.updated
	DRAWFUNC = ret.draw
	MOUSEPRESSED = ret.mousepressed
	
	CANVAS = love.graphics.newCanvas(800, 800)
end

function love.update(dt)
	if not ISUPDATED() then 
		love.graphics.setCanvas(CANVAS)
		DRAWFUNC()
		love.graphics.setCanvas()
	end
end

function love.draw()
	love.graphics.draw(CANVAS)
end

function love.mousepressed( x, y, button, istouch, presses )
	MOUSEPRESSED(x, y)
end 

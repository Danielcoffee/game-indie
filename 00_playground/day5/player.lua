-- ============================================
-- MODULE: PLAYER
-- ============================================

function init_player()
	player.x = 400
	player.y = 550
	player.width = 80
	player.height = 20
end

function update_player()
	player.x = love.mouse.getX()
	player.x = math.max(0, math.min(800- player.width, player.x)) 
end

function draw_player()
	love.graphics.setColor(0.2, 0.7, 0.2)
	love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
end

-- ham lay toa do trung tam cua player
function get_player_center_x()
	return player.x + player.width/2
end

function get_player_y()
	return player.y
end

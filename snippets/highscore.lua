-- ============================================
-- SNIPPET: HIGH SCORE
-- Lưu và đọc điểm cao từ file
-- require("highscore")
-- ============================================

high_score = 0
save_file = "savegame.txt"

function load_highscore()
	if love.filesystem.getInfo(save_file) then
		local content = love.filesystem.read(save_file)
		high_score = tonumber(content) or 0
	else
		high_score = 0
	end
end


function save_highscore(score)
	if score > high_score then
		high_score = score
	end
	love.filesystem.write(save_file, tostring(high_score))
end

function draw_highscore(x, y)
	love.graphics.setColor(1, 0, 0)
	love.graphics.print("High score: " .. high_score, x, y)
end

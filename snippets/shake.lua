-- ============================================
-- SNIPPET: SCREEN SHAKE
-- Dùng cho bất kỳ game Love2D nào
-- Cách dùng:
--   1. require("shake") ở đầu main.lua
--   2. Gọi begin_shake(4, 0.15) khi có va chạm
--   3. Gọi start_shake() & end_shake() trong love.draw (đầu và cuối)
-- ============================================

-- Biến toàn cục
shake_timer = 0
shake_magnitude = 4
shake_dx = 0
shake_dy = 0

-- ham kich hoat rung
function begin_shake(magnitude, timer)
	shake_timer = timer
	shake_magnitude = magnitude
end


-- ham cap nhat trong love.update(dt)
function update_shake(dt)
	if shake_timer > 0 then
		shake_timer = shake_timer - dt
		if shake_timer < 0 then shake_timer = 0 end
	end
end


-- ham bat dau dich: dau draw()
function start_shake()
	shake_dx, shake_dy = 0, 0
	if shake_timer > 0 then
		shake_dx = math.random(-shake_magnitude, shake_magnitude)
		shake_dy = math.random(-shake_magnitude/2, shake_magnitude/2)
		love.graphics.translate(shake_dx, shake_dy)
	end
end


-- ham reset: cuoi draw()
function end_shake()
	if shake_timer > 0 then
		love.graphics.translate(-shake_dx, -shake_dy)
	end
end


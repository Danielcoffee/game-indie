
package.path = package.path .. ";D:/Daniel/game-indie/snippets/?.lua"
package.path = package.path .. ";D:/Daniel/game-indie/00_playground/day5/?.lua"

require("shake")
require("particle")
require("highscore")
require("ball")
require("game")
require("player")

function love.load()
	init_game()
end

function love.update(dt)
	if game_over then return end
	update_balls(dt)
	update_player()
	update_particles(dt)
	update_powerups(dt)
	update_magnet_effect(dt) --okie
	update_slow_time_effect(dt) -- okie
	update_shake(dt)
end

function love.draw()
	start_shake()

	-- ve nen
	love.graphics.setColor(0.1, 0.1, 0.15)
	love.graphics.rectangle("fill", 0, 0, 800, 600)

	-- ve game object
	draw_particles()
	draw_balls()
	draw_powerups()
	draw_player()

	-- UI
	love.graphics.setColor(1, 1, 1)
	love.graphics.print("Score: " ..score, 10, 10)
	draw_highscore(10, 35)
	love.graphics.print("Speed: " ..math.floor(base_speed), 10, 50)

	-- hien thi trang thai power-up
	if slow_time_active then
		love.graphics.setColor(0.2, 0.5, 1)
		love.graphics.print("Slow time: " .. string.format("%.1f", slow_time_timer) .."s", 10, 90)
	end

	if magnet_active then
		love.graphics.setColor(0.7, 0.2, 1)
		love.graphics.print("Magnet: " .. string.format("%.1f", magnet_timer) .. "s", 10, 110)
		love.graphics.setColor(0.7, 0.2, 1, 0.2)
		love.graphics.circle("line", get_player_center_x(), player.y, magnet_range)
	end

	if game_over then
		love.graphics.setColor(1, 1, 1)
		love.graphics.print("GAME OVER", 360, 280)
		love.graphics.print("Press R to restart", 340, 320)
		love.graphics.print("Final Score: " .. score, 355, 350)
		if score == high_score and score > 0 then
			love.graphics.setColor(1, 0.8, 0)
			love.graphics.print("NEW RECORD!", 355, 380)
		end
	end
	end_shake()
end

function draw_balls()
	for _, ball in ipairs(balls) do
		local radius = ball.radius
		if ball.hit_animation then
			radius = ball.radius * ball.hit_scale
		end

		if ball.is_golden then
			love.graphics.setColor(1, 0.8, 0)
			love.graphics.circle("fill", ball.x, ball.y, radius + 3)
			love.graphics.setColor(1, 0.9, 0.2)
		else
			love.graphics.setColor(0.9, 0.2, 0.2)
		end

		love.graphics.circle("fill", ball.x, ball.y, radius)
	end
end

-- === VẼ POWER-UP ===
function draw_powerups()
    for _, p in ipairs(powerups) do
        local radius = p.radius
        if p.hit_animation then
            radius = p.radius * p.hit_scale
        end
        
        if p.type == 1 then
            love.graphics.setColor(0.2, 0.5, 1)
            love.graphics.circle("fill", p.x, p.y, radius)
            love.graphics.setColor(0.4, 0.7, 1)
        else
            love.graphics.setColor(0.7, 0.2, 1)
            love.graphics.circle("fill", p.x, p.y, radius)
            love.graphics.setColor(0.9, 0.5, 1)
        end
        love.graphics.circle("fill", p.x, p.y, radius - 3)
    end
end

-- === XỬ LÝ PHÍM ===
function love.keypressed(key)
    if key == "r" and game_over then
        init_game()
    end
    if key == "escape" then
        love.event.quit()
    end
end

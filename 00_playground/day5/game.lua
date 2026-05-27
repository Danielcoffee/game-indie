-- ============================================
-- MODULE: GAME LOGIC
-- ============================================

function init_game()
	score = 0
	game_over = false
	base_speed = 200
	balls = {}
	powerups = {}
	player = {}
	particles = {}
	slow_time_active = false
	magnet_active = false

	init_player()
	spawn_ball()
	spawn_powerup()
end

function update_balls(dt)
	for i = #balls, 1, -1 do
		local ball = balls[i]

		-- animation no
		if ball.hit_animation then
			ball.hit_timer = ball.hit_timer - dt
			ball.hit_scale = 1 + (0.3 - ball.hit_timer) * 2		-- ball.hit_timer 0.5(1) ->0(2) 
			ball.hit_scale = math.min(ball.hit_scale, 2.5)
			if ball.hit_timer <= 0 then
				table.remove(balls, i)
			end
			goto continue_ball
		end

		-- bong roi
		ball.y = ball.y + ball.speed_y * dt

		-- va cham voi player
		if ball.x > player.x and ball.x < player.x + player.width and ball.y + ball.radius > player.y then
			-- cong diem
			if ball.is_golden then
				score = score + 5
				begin_shake(4, 0.15)
				spawn_particles(ball.x, ball.y, 1, 0.8, 0, 8) 		-- mau vang
			else
				score = score + 1
				begin_shake(2, 0.1)
				spawn_particles(ball.x, ball.y, 0.9, 0.2, 0.2, 8) 	-- mau do
			end

		-- tang toc do
			base_speed = math.min(base_speed + 10, 750)
		-- animation no
			
			ball.hit_animation = true
			ball.hit_timer = 0.3
			ball.hit_scale = 1

		-- luu highscore
			save_highscore(score)

		-- tao bong moi va powerup
			spawn_ball()
			spawn_powerup()
		elseif ball.y + ball.radius > 600 then
			game_over = true
		end

		::continue_ball::
	end
end

function update_powerups(dt)
	for i = #powerups, 1, -1 do
		local p = powerups[i]

		if p.hit_animation then
			p.hit_timer = p.hit_timer - dt
			p.hit_scale = 1 + (0.3 - p.hit_timer) * 2
			p.hit_scale = math.min(p.hit_scale, 2.5)
			if p.hit_timer <= 0 then
				table.remove(powerups, i)
			end
			goto continue_powerup
		end
		
		p.y = p.y + p.speed_y * dt

		if p.y + p.radius > player.y and player.x+ player.width > p.x and p.x > player.x then
			activate_powerup(p.type)

			-- Particles mau xanh cho power-up
			if p.type == 1 then
				spawn_particles(p.x, p.y, 0.2, 0.5, 1, 8) 	-- xanh
			elseif p.type == 2 then
				spawn_particles(p.x, p.y, 0.7, 0.2, 1, 8) 	-- tim
			end

			p.hit_animation = true
			p.hit_timer = 0.3
			p.hit_scale = 1

		elseif p.y + p.radius > 600 then
			table.remove(powerups, i)
		end

		::continue_powerup::
	end
end

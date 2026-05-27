-- ============================================
-- MODULE: BALL + POWERUP
-- ============================================
-- magnet
magnet_timer = 0
magnet_range = 100
magnet_strength = 500

-- SLOW TIME
slow_time_timer = 0

function spawn_ball()
	local is_golden = math.random() < 0.2 -- chi 20% co hoi.

	local current_speed = base_speed
	if slow_time_active then
		current_speed = base_speed * 0.5
	end

	local ball = {
		x = math.random(50, 750),
		y = 50,
		radius = 15,
		is_golden = is_golden,
		speed_y= current_speed,
		hit_animation = false,
		hit_timer = 0,
		hit_scale = 1
	}
	table.insert(balls, ball)
end

function spawn_powerup()
	if math.random() > 0.2 then return end

	local power_type = math.random(1,2)
	local powerup = {
		x = math.random(50, 750),
		y = 50,
		radius = 12,
		speed_y = 150,
		type = power_type,
		hit_animation = false,
		hit_timer = 0,
		hit_scale = 1
	}
	table.insert(powerups, powerup)
end

function update_magnet_effect(dt)
	if not magnet_active then return end

	magnet_timer = magnet_timer - dt
	if magnet_timer <= 0 then
		magnet_active = false
		return
	end

	-- hut bong
	local player_center_x = get_player_center_x()
	local player_y = get_player_y()

	for _, ball in ipairs(balls) do
		local dx = player_center_x - ball.x
		local dy = player_y - ball.y
		local dist = math.sqrt(dx*dx + dy*dy)
		if dist < magnet_range and dist > 1 then
			local strength = 1 - dist / magnet_range		-- cang gan center --> strength cang manh
			local force = magnet_strength * strength * dt
			ball.x = ball.x + dx * force / dist
			-- gioi han bong khong ra khoi man hinh
			ball.x = math.max(ball.radius, math.min(ball.x, 800 - ball.radius))
		end
	end
end

function update_slow_time_effect(dt)
	if not slow_time_active then return end		-- slow_time_active == false: k co gi xay ra

	slow_time_timer = slow_time_timer - dt		-- slow_time_timer == true: update
	if slow_time_timer <= 0 then				-- Het thoi gian --> update ve false
		slow_time_active = false

		-- khoi phuc toc do
		for _, ball in ipairs(balls) do
			ball.speed_y = base_speed
		end
	end
end


function activate_powerup(power_type)
	if power_type == 1 then 					-- Slow time
		slow_time_active = true
		slow_time_timer = 10
		for _, ball in ipairs(balls) do
			ball.speed_y = base_speed * 0.5
		end
	elseif power_type == 2 then					-- Magnet time
		magnet_active = true
		magnet_timer = 10
	end
	
	-- phat am thanh neu co
	if sound_powerup then sound_powerup:play() end
end

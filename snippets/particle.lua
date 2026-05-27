-- ============================================
-- SNIPPET: PARTICLE SYSTEM
-- require("particle") in main.lua
-- Dùng cho hiệu ứng bụi, nổ, tia lửa
-- ============================================


particles = {}

-- Khoi tao prticles
function spawn_particles(x, y, r, g, b, count)
	count = count or math.random(5, 10)
	for i = 1, count do
		local particle = {
			x = x, 
			y = y,
			r = r,
			g = g,
			b = b,
			vx = math.random(-50, 50),
			vy = math.random(-100, 100),
			life = 1,
			size = math.random(2,4)
		}
		table.insert(particles, particle)
	end
end

-- Update particles
-- co vx, vy, so luong hat

function update_particles(dt)
	for i = #particles, 1, -1 do
		local p = particles[i]
		p.x = p.x + p.vx * dt
		p.y = p.y + p.vy * dt
		p.life = p.life - dt

		if p.life < 0 then
			table.remove(particles, i)
		end

	end
end


-- Draw particles
function draw_particles()
	for _,p in ipairs(particles) do
		local alpha = p.life/0.5
		love.graphics.setColor(p.r, p.g, p.b, alpha)
		love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
	end
end

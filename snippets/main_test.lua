-- =======================
-- File: main.lua dung de test cac snippets
-- =======================

require("shake")
require("particle")
require("highscore")

function love.load()
	load_highscore()
--[[
	spawn_particles(7, 400, 1, 0, 0)
	for i = 1, 20 do
		x = math.random(0, 800)
		y = math.random(0, 600)
		r = math.random()
		g = math.random()
		b = math.random()
		count = math.random(5, 20)
		spawn_particles(x,y,r,g,b,count)
	end
		]]
end


function love.update(dt)
--	update_particles(dt)
	save_highscore(9)
end


function love.draw()
--	draw_particles()
	draw_highscore(10, 10)
end

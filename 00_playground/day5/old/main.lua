-- ============================================
-- NGÀY 5: GAME BẮT BÓNG + POWER-UP
-- Slow Time + Magnet
-- ============================================

-- ========== 1. KHAI BÁO BIẾN TOÀN CỤC ==========

function love.load()
    -- === PLAYER ===
    player = {
        x = 400,
        y = 550,
        width = 80,
        height = 20
    }
    
    -- === BÓNG ===
    balls = {}
    base_speed = 200
    
    -- === POWER-UP ===
    powerups = {}           -- mảng chứa các power-up đang rơi
    
    -- === HIỆU ỨNG TẠM THỜI ===
    slow_time_active = false
    slow_time_timer = 0
    
    magnet_active = false
    magnet_timer = 0
    magnet_range = 100      -- phạm vi hút (pixel)
    
    -- === ĐIỂM SỐ ===
    score = 0
    high_score = 0
    
    -- === HIỆU ỨNG ===
    shake_timer = 0
    shake_magnitude = 4
    particles = {}
    
    -- === TRẠNG THÁI ===
    game_over = false
    
    -- === ĐỌC HIGH SCORE ===
    if love.filesystem.getInfo("savegame.txt") then
        local content = love.filesystem.read("savegame.txt")
        high_score = tonumber(content) or 0
    end
    
    -- === ÂM THANH ===
    sound_powerup = nil
    sound_magnet = nil
    
    if love.filesystem.getInfo("sounds/powerup.wav") then
        sound_powerup = love.audio.newSource("sounds/powerup.wav", "static")
    end
    
    if love.filesystem.getInfo("sounds/magnet.wav") then
        sound_magnet = love.audio.newSource("sounds/magnet.wav", "static")
    end
    
    -- === TẠO BÓNG ĐẦU TIÊN ===
    spawn_ball()
end

-- ========== 2. HÀM TẠO BÓNG ==========

function spawn_ball()
    local is_golden = love.math.random() < 0.2
    
    -- Tốc độ bóng: nếu đang slow time thì giảm 50%
    local current_speed = base_speed
    if slow_time_active then
        current_speed = base_speed * 0.5
    end
    
    local ball = {
        x = love.math.random(50, 750),
        y = 50,
        radius = 15,
        speed_y = current_speed,
        is_golden = is_golden,
        hit_animation = false,
        hit_timer = 0,
        hit_scale = 1
    }
    
    table.insert(balls, ball)
end

-- ========== 3. HÀM TẠO POWER-UP ==========

function spawn_powerup()
    -- 10% chance spawn power-up mỗi khi bắt được bóng
    if love.math.random() > 0.1 then
        return
    end
    
    -- Chọn loại power-up: 1 = Slow Time, 2 = Magnet
    local power_type = love.math.random(1, 2)
    
    local powerup = {
        x = love.math.random(50, 750),
        y = 50,
        radius = 12,
        speed_y = 150,          -- rơi chậm hơn bóng một chút
        type = power_type,      -- 1: slow, 2: magnet
        hit_animation = false,
        hit_timer = 0,
        hit_scale = 1
    }
    
    table.insert(powerups, powerup)
end

-- ========== 4. HÀM KÍCH HOẠT POWER-UP ==========

function activate_powerup(power_type)
    if power_type == 1 then      -- Slow Time
        slow_time_active = true
        slow_time_timer = 3.0    -- kéo dài 3 giây
        
        -- Cập nhật tốc độ cho tất cả bóng hiện tại
        for _, ball in ipairs(balls) do
            ball.speed_y = base_speed * 0.5
        end
        
    elseif power_type == 2 then  -- Magnet
        magnet_active = true
        magnet_timer = 3.0
    end
    
    -- Phát âm thanh
    if sound_powerup then
        sound_powerup:play()
    end
end

-- ========== 5. HÀM CẬP NHẬT HIỆU ỨNG POWER-UP ==========

function update_powerup_effects(dt)
    -- Cập nhật Slow Time
    if slow_time_active then
        slow_time_timer = slow_time_timer - dt
        if slow_time_timer <= 0 then
            slow_time_active = false
            
            -- Khôi phục tốc độ bóng về bình thường
            for _, ball in ipairs(balls) do
                ball.speed_y = base_speed
            end
        end
    end
    
    -- Cập nhật Magnet
    if magnet_active then
        magnet_timer = magnet_timer - dt
        if magnet_timer <= 0 then
            magnet_active = false
        else
            -- Hút bóng về phía player
            for _, ball in ipairs(balls) do
                local dx = player.x + player.width/2 - ball.x
                local dy = player.y - ball.y
                local dist = math.sqrt(dx*dx + dy*dy)
                
                if dist < magnet_range then
                    -- Tính lực hút: càng gần càng hút mạnh
                    local force = 200 * (1 - dist / magnet_range) * dt
                    ball.x = ball.x + dx * force / dist
                    
                    -- Giới hạn bóng không bay ra ngoài màn hình
                    ball.x = math.max(ball.radius, math.min(800 - ball.radius, ball.x))
                end
            end
        end
    end
end

-- ========== 6. HÀM TẠO PARTICLE (thêm hiệu ứng cho power-up) ==========

function spawn_particles(x, y, is_golden, is_powerup)
    local num_particles = love.math.random(5, 10)
    
    for i = 1, num_particles do
        local r, g, b
        if is_powerup then
            -- Màu cho power-up: xanh dương hoặc tím
            r = 0.3
            g = 0.3
            b = 1
        else
            r = is_golden and 1 or 0.9
            g = is_golden and 0.8 or 0.2
            b = is_golden and 0 or 0.2
        end
        
        local particle = {
            x = x,
            y = y,
            vx = love.math.random(-100, 100),
            vy = love.math.random(-150, -50),
            life = 0.5,
            size = love.math.random(2, 4),
            r = r, g = g, b = b
        }
        table.insert(particles, particle)
    end
end

-- ========== 7. CẬP NHẬT BÓNG (thêm xử lý va chạm với power-up) ==========

function update_balls(dt)
    for i = #balls, 1, -1 do
        local ball = balls[i]
        
        if ball.hit_animation then
            ball.hit_timer = ball.hit_timer - dt
            ball.hit_scale = 1 + (0.5 - ball.hit_timer) * 2
            ball.hit_scale = math.min(ball.hit_scale, 2.5)
            
            if ball.hit_timer <= 0 then
                table.remove(balls, i)
            end
            goto continue_ball
        end
        
        -- Bóng rơi
        ball.y = ball.y + ball.speed_y * dt
        
        -- Va chạm với player
        if ball.y + ball.radius > player.y and
           ball.x > player.x and
           ball.x < player.x + player.width then
            
            -- Xử lý bắt bóng
            if ball.is_golden then
                score = score + 5
                start_shake(6, 0.15)
            else
                score = score + 1
                start_shake(3, 0.1)
            end
            
            spawn_particles(ball.x, ball.y, ball.is_golden, false)
            
            base_speed = math.min(base_speed + 10, 600)
            
            ball.hit_animation = true
            ball.hit_timer = 0.2
            ball.hit_scale = 1
            
            -- Cập nhật high score
            if score > high_score then
                high_score = score
                love.filesystem.write("savegame.txt", tostring(high_score))
            end
            
            -- SPAWN POWER-UP (10% chance)
            spawn_powerup()
            
            -- Tạo bóng mới
            spawn_ball()
            
        elseif ball.y + ball.radius > 600 then
            game_over = true
        end
        
        ::continue_ball::
    end
end

-- ========== 8. CẬP NHẬT POWER-UP ==========

function update_powerups(dt)
    for i = #powerups, 1, -1 do
        local p = powerups[i]
        
        if p.hit_animation then
            p.hit_timer = p.hit_timer - dt
            p.hit_scale = 1 + (0.5 - p.hit_timer) * 2
            p.hit_scale = math.min(p.hit_scale, 2.5)
            
            if p.hit_timer <= 0 then
                table.remove(powerups, i)
            end
            goto continue_powerup
        end
        
        -- Power-up rơi
        p.y = p.y + p.speed_y * dt
        
        -- Va chạm với player
        if p.y + p.radius > player.y and
           p.x > player.x and
           p.x < player.x + player.width then
            
            -- Kích hoạt power-up
            activate_powerup(p.type)
            spawn_particles(p.x, p.y, false, true)
            
            p.hit_animation = true
            p.hit_timer = 0.2
            p.hit_scale = 1
            
        elseif p.y + p.radius > 600 then
            -- Power-up rơi mất (không game over)
            table.remove(powerups, i)
        end
        
        ::continue_powerup::
    end
end

-- ========== 9. CẬP NHẬT PARTICLE ==========

function update_particles(dt)
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

-- ========== 10. LOVE.UPDATE ==========

function love.update(dt)
    if game_over then return end
    
    -- Di chuyển player
    player.x = love.mouse.getX()
    player.x = math.max(0, math.min(800 - player.width, player.x))
    
    -- Cập nhật shake
    if shake_timer > 0 then
        shake_timer = shake_timer - dt
        if shake_timer < 0 then shake_timer = 0 end
    end
    
    -- Cập nhật hiệu ứng power-up
    update_powerup_effects(dt)
    
    -- Cập nhật các thành phần
    update_balls(dt)
    update_powerups(dt)
    update_particles(dt)
end

-- ========== 11. HÀM VẼ ==========

function love.draw()
    -- Xử lý shake
    local shake_x, shake_y = 0, 0
    if shake_timer > 0 then
        shake_x = love.math.random(-shake_magnitude, shake_magnitude)
        shake_y = love.math.random(-shake_magnitude/2, shake_magnitude/2)
        love.graphics.translate(shake_x, shake_y)
    end
    
    -- Nền
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- Vẽ particle
    for _, p in ipairs(particles) do
        local alpha = p.life / 0.5
        love.graphics.setColor(p.r, p.g, p.b, alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
    
    -- Vẽ bóng
    for _, ball in ipairs(balls) do
        local radius = ball.radius
        if ball.hit_animation then
            radius = ball.radius * ball.hit_scale
        end
        
        if ball.is_golden then
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.circle("fill", ball.x, ball.y, radius + 3)
            love.graphics.setColor(1, 0.9, 0.2)
            love.graphics.circle("fill", ball.x, ball.y, radius)
        else
            love.graphics.setColor(0.9, 0.2, 0.2)
            love.graphics.circle("fill", ball.x, ball.y, radius)
        end
    end
    
    -- Vẽ POWER-UP
    for _, p in ipairs(powerups) do
        local radius = p.radius
        if p.hit_animation then
            radius = p.radius * p.hit_scale
        end
        
        if p.type == 1 then  -- Slow Time: màu xanh dương
            love.graphics.setColor(0.2, 0.5, 1)
            love.graphics.circle("fill", p.x, p.y, radius)
            love.graphics.setColor(0.4, 0.7, 1)
            love.graphics.circle("fill", p.x, p.y, radius - 3)
        else  -- Magnet: màu tím
            love.graphics.setColor(0.7, 0.2, 1)
            love.graphics.circle("fill", p.x, p.y, radius)
            love.graphics.setColor(0.9, 0.5, 1)
            love.graphics.circle("fill", p.x, p.y, radius - 3)
        end
    end
    
    -- Vẽ player
    love.graphics.setColor(0.2, 0.7, 0.2)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- Vẽ UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    
    love.graphics.setColor(0.9, 0.9, 0.5)
    love.graphics.print("HIGH SCORE: " .. high_score, 10, 35)
    
    love.graphics.setColor(0.5, 0.8, 1)
    love.graphics.print("Speed: " .. math.floor(base_speed) .. " px/s", 10, 60)
    
    -- Hiển thị trạng thái power-up
    if slow_time_active then
        love.graphics.setColor(0.2, 0.5, 1)
        love.graphics.print("SLOW TIME: " .. string.format("%.1f", slow_time_timer) .. "s", 10, 90)
    end
    
    if magnet_active then
        love.graphics.setColor(0.7, 0.2, 1)
        love.graphics.print("MAGNET: " .. string.format("%.1f", magnet_timer) .. "s", 10, 110)
        
        -- Vẽ vòng tròn phạm vi hút (hiệu ứng visual)
        love.graphics.setColor(0.7, 0.2, 1, 0.2)
        love.graphics.circle("line", player.x + player.width/2, player.y, magnet_range)
    end
    
    -- Game over
    if game_over then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("GAME OVER", 360, 280)
        love.graphics.print("Press R to restart", 340, 320)
        love.graphics.print("Final Score: " .. score, 355, 350)
        
        if score == high_score and score > 0 then
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.print("★ NEW RECORD! ★", 355, 380)
        end
    end
    
    -- Reset shake
    if shake_timer > 0 then
        love.graphics.translate(-shake_x, -shake_y)
    end
end

-- ========== 12. HÀM PHỤ TRỢ ==========

function start_shake(magnitude, duration)
    shake_magnitude = magnitude
    shake_timer = duration
end

function reset_game()
    game_over = false
    score = 0
    base_speed = 200
    balls = {}
    powerups = {}
    particles = {}
    shake_timer = 0
    
    slow_time_active = false
    slow_time_timer = 0
    magnet_active = false
    magnet_timer = 0
    
    spawn_ball()
end

function love.keypressed(key)
    if key == "r" and game_over then
        reset_game()
    end
    
    if key == "escape" then
        love.event.quit()
    end
end

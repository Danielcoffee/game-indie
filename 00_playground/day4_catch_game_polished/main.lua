-- ============================================
-- NGÀY 4+: GAME HỨNG BÓNG HOÀN CHỈNH
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
    balls = {}          -- mảng chứa tất cả bóng đang rơi
    base_speed = 200    -- tốc độ rơi (tăng dần khi bắt được)
    
    -- === ĐIỂM SỐ ===
    score = 0
    high_score = 0
    
    -- === HIỆU ỨNG ===
    shake_timer = 0     -- thời gian rung còn lại (giây)
    shake_magnitude = 4 -- cường độ rung (pixel)
    
    -- === PARTICLE (bụi khi bắt bóng) ===
    particles = {}      -- mảng chứa các hạt bụi
    
    -- === ÂM THANH ===
    -- load âm thanh (nếu file không tồn tại, vẫn chạy nhưng im lặng)
    local normal_path = "../../assets/sounds/free_sfx/catch_normal.wav"
    local golden_path = "../../assets/sounds/free_sfx/catch_golden.wav"
    
    if love.filesystem.getInfo(normal_path) then
        sound_normal = love.audio.newSource(normal_path, "static")
    else
        sound_normal = nil
        print("Warning: Missing sounds/catch_normal.wav")
    end
    
    if love.filesystem.getInfo(golden_path) then
        sound_golden = love.audio.newSource(golden_path, "static")
    else
        sound_golden = nil
        print("Warning: Missing sounds/catch_golden.wav")
    end
    
    -- === TRẠNG THÁI ===
    game_over = false
    
    -- === ĐỌC HIGH SCORE TỪ FILE ===
    if love.filesystem.getInfo("savegame.txt") then
        local content = love.filesystem.read("savegame.txt")
        high_score = tonumber(content) or 0
    end
    
    -- === TẠO BÓNG ĐẦU TIÊN ===
    spawn_ball()
end

-- ========== 2. HÀM TẠO BÓNG MỚI ==========

function spawn_ball()
    local is_golden = love.math.random() < 0.2  -- 20% bóng vàng
    
    local ball = {
        x = love.math.random(50, 750),
        y = 50,
        radius = 15,
        speed_y = base_speed,    -- dùng tốc độ hiện tại
        is_golden = is_golden,
        
        -- === HIỆU ỨNG NỔ (thêm mới) ===
        -- Khi bắt được bóng, thay vì xóa ngay, bóng sẽ nổ to rồi biến mất
        hit_animation = false,   -- có đang trong trạng thái nổ không?
        hit_timer = 0,           -- thời gian nổ còn lại
        hit_scale = 1            -- scale hiện tại (1 = bình thường)
    }
    
    table.insert(balls, ball)
end

-- ========== 3. HÀM TẠO PARTICLE (BỤI) ==========

function spawn_particles(x, y, is_golden)
    -- Tạo từ 5 đến 10 hạt bụi
    local num_particles = love.math.random(5, 10)
    
    for i = 1, num_particles do
        -- Mỗi hạt là 1 bảng có các thuộc tính riêng
        local particle = {
            x = x,
            y = y,
            vx = love.math.random(-100, 100),  -- vận tốc x (pixel/giây)
            vy = love.math.random(-150, -50),  -- vận tốc y (bay lên trên)
            life = 0.5,                         -- sống 0.5 giây
            size = love.math.random(2, 4),      -- kích thước 2-4 pixel
            
            -- Màu sắc theo loại bóng
            r = is_golden and 1 or 0.9,   -- vàng = 1, đỏ = 0.9
            g = is_golden and 0.8 or 0.2, -- vàng = 0.8, đỏ = 0.2
            b = is_golden and 0 or 0.2     -- vàng = 0, đỏ = 0.2
        }
        table.insert(particles, particle)
    end
end

-- ========== 4. HÀM KÍCH HOẠT RUNG ==========

function start_shake(magnitude, duration)
    shake_magnitude = magnitude
    shake_timer = duration
end

-- ========== 5. LOVE.UPDATE (CẬP NHẬT MỖI FRAME) ==========

function love.update(dt)
    if game_over then return end
    
    -- === DI CHUYỂN PLAYER ===
    player.x = love.mouse.getX()
    player.x = math.max(0, math.min(800 - player.width, player.x))
    
    -- === CẬP NHẬT SHAKE (giảm thời gian rung) ===
    if shake_timer > 0 then
        shake_timer = shake_timer - dt
        if shake_timer < 0 then shake_timer = 0 end
    end
    
    -- === CẬP NHẬT PARTICLE ===
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.life = p.life - dt
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        
        if p.life <= 0 then
            table.remove(particles, i)  -- hạt chết thì xóa
        end
    end
    
    -- === CẬP NHẬT BÓNG ===
    for i = #balls, 1, -1 do
        local ball = balls[i]
        
        -- Nếu bóng đang trong animation nổ
        if ball.hit_animation then
            ball.hit_timer = ball.hit_timer - dt
            -- hiệu ứng nổ: scale tăng dần từ 1 lên 2
            ball.hit_scale = 1 + (0.5 - ball.hit_timer) * 2
            ball.hit_scale = math.min(ball.hit_scale, 2.5)
            
            if ball.hit_timer <= 0 then
                table.remove(balls, i)  -- xóa bóng sau khi nổ xong
            end
            goto continue  -- bỏ qua phần rơi và va chạm
        end
        
        -- BÓNG RƠI
        ball.y = ball.y + ball.speed_y * dt
        
        -- === VA CHẠM VỚI PLAYER ===
        if ball.y + ball.radius > player.y and
           ball.x > player.x and
           ball.x < player.x + player.width then
            
            -- BẮT ĐƯỢC BÓNG!
            
            -- 1. Phát âm thanh
            if ball.is_golden then
                if sound_golden then sound_golden:play() end
                score = score + 5
                start_shake(6, 0.15)  -- rung mạnh hơn
            else
                if sound_normal then sound_normal:play() end
                score = score + 1
                start_shake(3, 0.1)   -- rung nhẹ
            end
            
            -- 2. Tạo particle bụi tại vị trí bóng
            spawn_particles(ball.x, ball.y, ball.is_golden)
            
            -- 3. Tăng tốc độ toàn cục
            base_speed = math.min(base_speed + 10, 600)  -- tối đa 600
            
            -- 4. Kích hoạt animation nổ cho bóng này
            ball.hit_animation = true
            ball.hit_timer = 0.2  -- nổ trong 0.2 giây
            ball.hit_scale = 1
            
            -- 5. Cập nhật high score
            if score > high_score then
                high_score = score
                love.filesystem.write("savegame.txt", tostring(high_score))
            end
            
            -- 6. Tạo bóng mới (thay thế bóng vừa bắt)
            spawn_ball()
            
        -- === BÓNG RƠI XUỐNG ĐÁY ===
        elseif ball.y + ball.radius > 600 then
            game_over = true
        end
        
        ::continue::
    end
end

-- ========== 6. LOVE.DRAW (VẼ MÀN HÌNH) ==========

function love.draw()
    -- === XỬ LÝ SHAKE (dịch toàn bộ màn hình) ===
    local shake_x, shake_y = 0, 0
    if shake_timer > 0 then
        shake_x = love.math.random(-shake_magnitude, shake_magnitude)
        shake_y = love.math.random(-shake_magnitude/2, shake_magnitude/2)
        love.graphics.translate(shake_x, shake_y)
    end
    
    -- === VẼ NỀN ===
    love.graphics.setColor(0.1, 0.1, 0.15)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    
    -- === VẼ PARTICLE (bụi) ===
    for _, p in ipairs(particles) do
        -- alpha giảm dần theo thời gian sống
        local alpha = p.life / 0.5  -- 1 -> 0
        love.graphics.setColor(p.r, p.g, p.b, alpha)
        love.graphics.rectangle("fill", p.x, p.y, p.size, p.size)
    end
    
    -- === VẼ BÓNG ===
    for _, ball in ipairs(balls) do
        local radius = ball.radius
        
        -- Nếu đang trong animation nổ, vẽ to hơn
        if ball.hit_animation then
            radius = ball.radius * ball.hit_scale
        end
        
        if ball.is_golden then
            -- Bóng vàng: viền sáng
            love.graphics.setColor(1, 0.8, 0)
            love.graphics.circle("fill", ball.x, ball.y, radius + 3)
            love.graphics.setColor(1, 0.9, 0.2)
            love.graphics.circle("fill", ball.x, ball.y, radius)
        else
            -- Bóng đỏ
            love.graphics.setColor(0.9, 0.2, 0.2)
            love.graphics.circle("fill", ball.x, ball.y, radius)
        end
    end
    
    -- === VẼ PLAYER ===
    love.graphics.setColor(0.2, 0.7, 0.2)
    love.graphics.rectangle("fill", player.x, player.y, player.width, player.height)
    
    -- === VẼ UI ===
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 10, 10)
    
    love.graphics.setColor(0.9, 0.9, 0.5)
    love.graphics.print("HIGH SCORE: " .. high_score, 10, 35)
    
    love.graphics.setColor(0.5, 0.8, 1)
    love.graphics.print("Speed: " .. math.floor(base_speed) .. " px/s", 10, 60)
    
    -- === GAME OVER ===
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
    
    -- === RESET SHAKE ===
    if shake_timer > 0 then
        love.graphics.translate(-shake_x, -shake_y)
    end
end

-- ========== 7. XỬ LÝ PHÍM BẤM ==========

function love.keypressed(key)
    if key == "r" and game_over then
        -- RESET GAME
        game_over = false
        score = 0
        base_speed = 200
        balls = {}
        particles = {}
        shake_timer = 0
        
        spawn_ball()
    end
    
    if key == "escape" then
        love.event.quit()
    end
end


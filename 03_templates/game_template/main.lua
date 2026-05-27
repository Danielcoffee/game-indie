-- ============================================
-- TEMPLATE: CẤU TRÚC CƠ BẢN CHO GAME LOVE2D
-- Copy folder này khi bắt đầu project mới
-- ============================================

-- Load snippets (đường dẫn tương đối từ project tới snippets)
package.path = package.path .. ";D:/Daniel/game-indie/snippets/?.lua"

require("shake")
require("particle")
require("highscore")

function love.load()
    -- Load high score
    load_highscore()
    
    -- Khởi tạo game
    score = 0
    game_over = false
    
    -- Khởi tạo các thành phần riêng của game
    init_game()
end

function init_game()
    -- Reset các biến game
    score = 0
    game_over = false
    -- ... thêm các biến khác tùy game
end

function love.update(dt)
    if game_over then return end
    
    -- Cập nhật game logic
    update_game(dt)
    
    -- Cập nhật particle và shake (dùng snippets)
    update_particles(dt)
    update_shake(dt)
end

function love.draw()
    begin_shake()
    
    -- Vẽ game
    draw_game()
    
    -- Vẽ particle và UI
    draw_particles()
    draw_score()
    draw_highscore(10, 35)
    
    if game_over then
        draw_game_over()
    end
    
    end_shake()
end

function love.keypressed(key)
    if key == "r" and game_over then
        init_game()
    end
    if key == "escape" then
        love.event.quit()
    end
end

-- === CÁC HÀM CẦN ĐỊNH NGHĨA (override) ===
function init_game() end
function update_game(dt) end
function draw_game() end
function draw_score() 
    love.graphics.print("Score: " .. score, 10, 10)
end
function draw_game_over()
    love.graphics.print("GAME OVER", 360, 280)
    love.graphics.print("Press R to restart", 340, 320)
end

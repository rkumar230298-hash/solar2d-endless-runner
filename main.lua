-- main.lua — Solar 2D Endless Runner
-- Side-scrolling runner: jump over obstacles, collect points, survive as long as possible

local physics = require("physics")

-- ─── Constants ────────────────────────────────────────────────────────────────
local W, H = display.contentWidth, display.contentHeight
local GROUND_Y = H * 0.8
local GRAVITY = -800
local JUMP_FORCE = 480
local SCROLL_SPEED_INIT = 220   -- pixels / second
local SCROLL_SPEED_MAX  = 420
local SPEED_INCREMENT   = 5     -- added every second
local PLATFORM_GAP_MIN  = 200
local PLATFORM_GAP_MAX  = 380
local OBSTACLE_CHANCE   = 0.4   -- 40 % of new platforms carry an obstacle

-- ─── State ────────────────────────────────────────────────────────────────────
local scrollSpeed = SCROLL_SPEED_INIT
local score = 0
local highScore = 0
local isGameOver = false
local isOnGround = false

-- Display groups
local bgGroup, gameGroup, uiGroup

-- Game objects
local player, ground, scoreLabel, hiLabel, gameOverLabel, restartBtn
local platforms = {}
local obstacles = {}

-- ─── Helpers ──────────────────────────────────────────────────────────────────
local function makeRect(group, x, y, w, h, r, g, b)
    local rect = display.newRect(group, x, y, w, h)
    rect:setFillColor(r or 1, g or 1, b or 1)
    return rect
end

-- ─── Collision ────────────────────────────────────────────────────────────────
local function onCollision(event)
    if event.phase == "began" then
        local a, b = event.object1, event.object2
        -- Player lands on platform
        if (a == player and b.isGround) or (b == player and a.isGround) then
            isOnGround = true
        end
        -- Player hits obstacle → game over
        if (a == player and b.isObstacle) or (b == player and a.isObstacle) then
            if not isGameOver then
                isGameOver = true
                Runtime:removeEventListener("enterFrame", onEnterFrame)
                if score > highScore then
                    highScore = score
                end
                gameOverLabel.isVisible = true
                restartBtn.isVisible    = true
                hiLabel.text = "Best: " .. highScore
            end
        end
    end
end

-- ─── Platform factory ─────────────────────────────────────────────────────────
local function spawnPlatform(x)
    local pw = math.random(120, 220)
    local py = GROUND_Y - math.random(0, 60)   -- slight vertical variation
    local plat = makeRect(gameGroup, x + pw / 2, py, pw, 14, 0.3, 0.8, 0.4)
    plat.isGround = true
    physics.addBody(plat, "static", { friction = 0.5, bounce = 0 })
    platforms[#platforms + 1] = plat

    -- Optionally add an obstacle on top
    if math.random() < OBSTACLE_CHANCE then
        local obs = makeRect(gameGroup, x + pw / 2, py - 24, 20, 30, 0.9, 0.25, 0.2)
        obs.isObstacle = true
        physics.addBody(obs, "static", { friction = 0, bounce = 0 })
        obstacles[#obstacles + 1] = obs
    end
end

-- ─── Game loop ────────────────────────────────────────────────────────────────
local lastTime = system.getTimer()
local nextPlatformX = W + 20

function onEnterFrame(event)
    local now = system.getTimer()
    local dt = (now - lastTime) / 1000
    lastTime = now

    -- Increase speed over time
    scrollSpeed = math.min(SCROLL_SPEED_MAX, scrollSpeed + SPEED_INCREMENT * dt)

    local dx = scrollSpeed * dt

    -- Scroll ground
    ground.x = ground.x - dx
    if ground.x < -ground.width / 2 + W then
        ground.x = ground.x + ground.width
    end

    -- Scroll platforms and obstacles; remove if off-screen
    for i = #platforms, 1, -1 do
        local p = platforms[i]
        p.x = p.x - dx
        if p.x < -p.width then
            display.remove(p)
            table.remove(platforms, i)
        end
    end
    for i = #obstacles, 1, -1 do
        local o = obstacles[i]
        o.x = o.x - dx
        if o.x < -o.width then
            display.remove(o)
            table.remove(obstacles, i)
        end
    end

    -- Spawn new platforms
    nextPlatformX = nextPlatformX - dx
    if nextPlatformX < W + 20 then
        local gap = math.random(PLATFORM_GAP_MIN, PLATFORM_GAP_MAX)
        nextPlatformX = W + gap
        spawnPlatform(W + gap)
    end

    -- Score
    score = score + dt * 5
    scoreLabel.text = "Score: " .. math.floor(score)
end

-- ─── Input ────────────────────────────────────────────────────────────────────
local function onTap()
    if isGameOver then return end
    if isOnGround then
        isOnGround = false
        player:applyLinearImpulse(0, player.mass * JUMP_FORCE / 60, player.x, player.y)
    end
end

-- ─── Build scene ──────────────────────────────────────────────────────────────
local function buildScene()
    bgGroup   = display.newGroup()
    gameGroup = display.newGroup()
    uiGroup   = display.newGroup()

    -- Sky background
    local sky = makeRect(bgGroup, W / 2, H / 2, W, H, 0.12, 0.15, 0.25)

    -- Scrolling ground (wide enough to wrap)
    ground = makeRect(gameGroup, W / 2, GROUND_Y + 20, W * 4, 40, 0.3, 0.65, 0.35)
    ground.isGround = true
    physics.addBody(ground, "static", { friction = 0.5, bounce = 0 })

    -- Initial platform run
    spawnPlatform(0)
    spawnPlatform(300)
    spawnPlatform(560)

    -- Player (simple square character)
    player = makeRect(gameGroup, W * 0.2, GROUND_Y - 60, 32, 44, 0.2, 0.6, 1.0)
    physics.addBody(player, { density = 1, friction = 0.3, bounce = 0 })
    player.isFixedRotation = true
    isOnGround = true

    -- UI labels
    scoreLabel = display.newText(uiGroup, "Score: 0", W / 2, 30, native.systemFontBold, 22)
    scoreLabel:setFillColor(1, 1, 1)

    hiLabel = display.newText(uiGroup, "Best: 0", W / 2, 58, native.systemFont, 16)
    hiLabel:setFillColor(1, 1, 0.5)

    gameOverLabel = display.newText(uiGroup, "GAME OVER", W / 2, H / 2 - 40, native.systemFontBold, 40)
    gameOverLabel:setFillColor(1, 0.3, 0.3)
    gameOverLabel.isVisible = false

    restartBtn = display.newText(uiGroup, "Tap to Restart", W / 2, H / 2 + 20, native.systemFont, 24)
    restartBtn:setFillColor(1, 1, 1)
    restartBtn.isVisible = false
end

-- ─── Restart ──────────────────────────────────────────────────────────────────
local function restart()
    Runtime:removeEventListener("collision", onCollision)
    Runtime:removeEventListener("enterFrame", onEnterFrame)
    Runtime:removeEventListener("tap", onTap)

    display.remove(bgGroup)
    display.remove(gameGroup)
    display.remove(uiGroup)
    platforms = {}
    obstacles = {}
    scrollSpeed = SCROLL_SPEED_INIT
    score = 0
    isGameOver = false
    isOnGround = false
    nextPlatformX = W + 20
    lastTime = system.getTimer()

    buildScene()

    Runtime:addEventListener("collision", onCollision)
    Runtime:addEventListener("enterFrame", onEnterFrame)
    Runtime:addEventListener("tap", onTap)
end

-- ─── Init ─────────────────────────────────────────────────────────────────────
physics.start()
physics.setGravity(0, GRAVITY / 60)

buildScene()

Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", onEnterFrame)
Runtime:addEventListener("tap", onTap)

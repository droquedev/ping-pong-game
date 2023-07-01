local push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

local smallFont = nil
local scoreFont = nil
local player1 = nil
local player2 = nil
local ball = nil
local gameState = nil
local player1Score = 0
local player2Score = 0
local servingPlayer = 1
local largeFont = nil
local winningPlayer = 0

function love.load()
	love.window.setTitle("David's Pong Game")
	love.graphics.setDefaultFilter('nearest', 'nearest')

	math.randomseed(os.time())

	smallFont = love.graphics.newFont('/fonts/pixel.ttf', 8)
	largeFont = love.graphics.newFont('/fonts/pixel.ttf', 16)
	scoreFont = love.graphics.newFont('/fonts/pixel.ttf', 32)

	love.graphics.setFont(smallFont)

	push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
		fullscreen = false,
		resizable = false,
		vsync = true
	})

	player1Score = 0
	player2Score = 0

	player1 = Paddle(10, 30, 5, 20)
	player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 50, 5, 20)

	ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

	gameState = 'start'
end

function love.update(dt)
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.03
			ball.x = player1.x + 5

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end
		end

		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy
		end

		ball:update(dt)

		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1

			if player2Score >= 10 then
				winningPlayer = 2
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end

		if ball.x > VIRTUAL_WIDTH then
			servingPlayer = 2
			player1Score = player1Score + 1
			if player1Score >= 10 then
				winningPlayer = 1
				gameState = 'done'
			else
				gameState = 'serve'
				ball:reset()
			end
		end
	end


	if love.keyboard.isDown('w') then
		player1.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('s') then
		player1.dy = PADDLE_SPEED
	else
		player1.dy = 0
	end

	if love.keyboard.isDown('up') then
		player2.dy = -PADDLE_SPEED
	elseif love.keyboard.isDown('down') then
		player2.dy = PADDLE_SPEED
	else
		player2.dy = 0
	end

	player1:update(dt)
	player2:update(dt)
end

function love.keypressed(key)
	if key == 'escape' then
		love.event.quit()
	end

	if key == 'enter' or key == 'return' then
		if gameState == 'start' then
			gameState = 'serve'
		elseif gameState == 'serve' then
			gameState = 'play'
		elseif gameState == 'done' then
			gameState = 'serve'

			ball:reset()

			player1Score = 0
			player2Score = 0

			if winningPlayer == 1 then
				servingPlayer = 2
			else
				servingPlayer = 1
			end
		end
	end
end

function love.draw()
	push:apply('start')

	love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

	love.graphics.setFont(smallFont)

	if gameState == 'start' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'serve' then
		love.graphics.setFont(smallFont)
		love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!", 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'play' then
		-- no UI messages to display in play
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
	end


	player1:render()
	player2:render()

	ball:render()

	love.graphics.setFont(scoreFont)

	love.graphics.printf(tostring(player1Score), 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2, 'center')
	love.graphics.printf(tostring(player2Score), VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH / 2, 'center')


	displayFps()

	push:apply('end')
end

function displayFps()
	love.graphics.setFont(smallFont)
	love.graphics.setColor(0, 255, 0, 255)
	love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end

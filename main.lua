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
local gameState = 'menu'
local player1Score = 0
local player2Score = 0
local servingPlayer = 1
local largeFont = nil
local winningPlayer = 0
local sounds = nil
local isVersusAI = true

function love.load()
	love.window.setTitle("David's Pong Game")
	love.graphics.setDefaultFilter('nearest', 'nearest')

	math.randomseed(os.time())

	smallFont = love.graphics.newFont('/fonts/pixel.ttf', 8)
	largeFont = love.graphics.newFont('/fonts/pixel.ttf', 16)
	scoreFont = love.graphics.newFont('/fonts/pixel.ttf', 32)

	sounds = {
		['paddle_hit'] = love.audio.newSource('/sounds/paddle_hit.wav', 'static'),
		['score'] = love.audio.newSource('/sounds/score.wav', 'static'),
		['wall_hit'] = love.audio.newSource('/sounds/wall_hit.wav', 'static')
	}

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
end

function love.update(dt)
	if gameState == 'menu' then
		return
	end
	if gameState == 'serve' then
		ball.dy = math.random(-50, 50)
		if servingPlayer == 1 then
			ball.dx = math.random(140, 200)
		else
			ball.dx = -math.random(140, 200)
		end
	elseif gameState == 'play' then
		if ball:collides(player1) then
			ball.dx = -ball.dx * 1.04
			ball.x = player1.x + 5

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball:collides(player2) then
			ball.dx = -ball.dx * 1.03
			ball.x = player2.x - 4

			if ball.dy < 0 then
				ball.dy = -math.random(10, 150)
			else
				ball.dy = math.random(10, 150)
			end

			sounds['paddle_hit']:play()
		end

		if ball.y <= 0 then
			ball.y = 0
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end

		if ball.y >= VIRTUAL_HEIGHT - 4 then
			ball.y = VIRTUAL_HEIGHT - 4
			ball.dy = -ball.dy

			sounds['wall_hit']:play()
		end

		ball:update(dt)

		if ball.x < 0 then
			servingPlayer = 1
			player2Score = player2Score + 1

			sounds['score']:play()
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

			sounds['score']:play()
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

	if (isVersusAI) then
		if (ball.x > VIRTUAL_WIDTH / 2) then
			if (ball.y < player2.y or ball.y > player2.y + 20) then
				if (ball.y < player2.y) then
					player2.dy = -PADDLE_SPEED - 10
				elseif (ball.y > player2.y + 20) then
					player2.dy = PADDLE_SPEED - 10
				else
					player2.dy = 0
				end
			else
				player2.dy = 0
			end
		else
			player2.dy = 0
		end
	elseif love.keyboard.isDown('up') then
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

	if gameState == 'menu' then
		if key == 'up' or key == 'w' and isVersusAI ~= true then
			isVersusAI = true
		elseif (key == 'down' or key == 's') and isVersusAI ~= false then
			isVersusAI = false
		elseif key == 'enter' or key == 'return' then
			gameState = 'start'
		end
	end

	if (key == 'enter' or key == 'return') and gameState ~= 'menu' then
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
	elseif gameState == 'done' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Player ' .. tostring(winningPlayer) .. ' wins!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
	elseif gameState == 'menu' then
		love.graphics.setFont(largeFont)
		love.graphics.printf('Choose your game mode!', 0, 10, VIRTUAL_WIDTH, 'center')
		love.graphics.setFont(smallFont)
		if isVersusAI == true then
			love.graphics.setColor(0, 255, 0, 255)
			love.graphics.printf('Versus AI', 0, 30, VIRTUAL_WIDTH, 'center')
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.printf('Versus Player', 0, 40, VIRTUAL_WIDTH, 'center')
		else
			love.graphics.setColor(255, 0, 0, 255)
			love.graphics.printf('Versus AI', 0, 30, VIRTUAL_WIDTH, 'center')
			love.graphics.setColor(0, 255, 0, 255)
			love.graphics.printf('Versus Player', 0, 40, VIRTUAL_WIDTH, 'center')
		end
	end

	love.graphics.setColor(255, 255, 255, 255)


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

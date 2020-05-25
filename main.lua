function love.load()
--[[I am leon Dale of Bloody Visual. this is a game built of one of my first tutorials in love and lua.
    This has been a fun ride and I hope you enjoy this game.
    for my sake and all those who enter here, I have, to the best of my meager abilities, commented on where and why everything is
    happening in this here code.
    at some point I need to 'plumb' this game and separate the enemies into their own tab. and add folders for sprites and sounds.
    I wish to add a squareMan at 50 kills and another level or two, perhaps even a mote of story line.]]

require("source.startup.startup")
startup()



--this is the table for the players variables !! now moved to player.lua
  player = {}
  player.x = love.graphics.getWidth()/2
  player.y = love.graphics.getHeight()/2
  player.speed = 180

--this is a table to contain multiple 'zombie' tables
  zombies = {}
  --this is the table to contain multiple instances of bullet tables
  bullets = {} --!! now moved to player.lua

--sets the gameState to 1, the main menu.  IMPROVE THE MENU
  gameState = 1
  --maxtime is the maximum time between shots, timer counts down from maxtime giving time between shots
  maxTime = 2
  timer = maxTime
  --sets the score to 0
  score = 0
--a font is set here, it's used in the menu
  myFont = love.graphics.newFont(40)
--this is a variable to vary the deathScreams of enemies
  deathScream = 0
end --this is the end to love.load

function love.update(dt)
--when gameState is 1, music stops and score resets
  if gameState == 1 then
  sounds.music:stop()
  score = 0
end -- end of the gamestate 1 updates

  --when gameState = 3 I want music to stop, triangle to stop, squareMan to appear!
if gameState == 3 then
  sounds.music:stop()
  sounds.spree01:play()
  score = 0
  squareManUpdate(dt)
  bossbulletsUpdate(dt)
end --end of the gameState 3 updates


--when gameState = 2 then music is played at low volume and player controls are defined, including escape to quit.
  if gameState == 2 then
    sounds.music:play()
    sounds.music:setVolume(0.3)




--this is a cheat to test squareMan
    if love.keyboard.isDown('1') then
      score = 49
    end-- end of the cheat if statement
  end--end of the gameState 2 updates


--this allows us to quit with escape
    if love.keyboard.isDown('escape') then
      love.event.push('quit')
    end

    --movement code for player !!this is moved to player.lua
    if love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
      player.y = player.y + player.speed * dt
    end

    if love.keyboard.isDown("w") and player.y > 0 then
      player.y = player.y - player.speed * dt
    end

    if love.keyboard.isDown("a") and player.x > 0 then
      player.x = player.x - player.speed * dt
    end

    if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
      player.x = player.x + player.speed * dt
    end



--this governs enemy movement
  for i,z in ipairs(zombies) do
    z.x = z.x + math.cos(zombie_player_angle(z)) * z.speed * dt
    z.y = z.y + math.sin(zombie_player_angle(z)) * z.speed * dt

--if the enemy touches player then enemies are reset to nil, gameState goes to 1 and player position reset
--MAYBE i can create a 3 heart health system, I can see how to do it, but it is not yet implimented
    if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
      for i,z in ipairs(zombies) do
        zombies[i] = nil
        gameState = 1
        player.x = love.graphics.getWidth()/2
        player.y = love.graphics.getHeight()/2
      end
    end
  end


--this governs bullet movement
--MAYBE for knockback i can apply this x and y to the enemy on hit, minus instead of plus.
  for i,b in ipairs(bullets) do
    b.x = b.x + math.cos(b.direction) * b.speed * dt
    b.y = b.y + math.sin(b.direction) * b.speed * dt
  end

--checks to see if bullet is beyond screen and removes bullet if true
  for i=#bullets,1,-1 do
    local b = bullets[i]
    if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
      table.remove(bullets, i)
    end
  end

--check to see if a bullet hits enemy, +1 to score, remove enemy and bullet
--MAYBE this is where the knockback would be added
--MAYBE this is where the floating point would be added
  for i,z in ipairs(zombies) do
    for j,b in ipairs(bullets) do
      if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
        --[[the next two line are supposed to 'knockback' the enemy in the direction of the bullet.  it does not work.
        z.x = z.x - math.cos(b.direction) * 5 * dt
        z.y = z.y - math.sin(b.direction) * 5 * dt]]
        --this is supposed to draw blood at z.x and y upon death
        love.graphics.draw(sprites.blood2, z.x, z.y, nil, 1, 1)
        z.dead = true
        b.dead = true
        score = score + 1
--all of this is to vary the death screams of the dying.
        deathScream = deathScream + 1
        if deathScream == 1 then
        sounds.ughk:play()
      end
      if deathScream == 2 then
      sounds.ohh:play()
      --[[this is an attempt to draw a blood spatter at the zombie angle * -1
      --love draw reminder: drawable object, x , y, radians, scale.x, scale.y, origin offset.x, origin offset.y
      love.graphics.draw(sprites.blood1, 200, 200)]]
    end
    if deathScream == 3 then
    sounds.owww:play()
  end
  if deathScream == 4 then
  sounds.owowo:play()
end
if deathScream == 5 then
  sounds.blahhh:play()
  deathScream = 0
end

      end
    end
  end



  --searches bullets table for dead bullets and removes them
  for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
      table.remove(bullets, i)
    end
  end


--if the game is active then the timer counts down and at 0 spawns an enemy, the maxtime is set and the timer is set to maxtime for a count down to next spawn
  if gameState == 2 then
    timer = timer - dt
    if timer <= 0 then
      spawnZombie()
      --this maxtime controls how often enemies appear
      maxTime = maxTime * 0.97
      timer = maxTime
    end
  end


--below are the commentators phrases.
 if score == 5 then
    sounds.ohoh:play()
  end
  if score == 10 then
    sounds.idBuyThatForADollar:play()
  end
  if score == 20 then
    sounds.wowWee:play()
  end
  if score == 30 then
    sounds.futile:play()
  end
  if score == 40 then
    sounds.getToFifty:play()
  end
  --when score is 50 we want to say victory and then stop the victory chant, clear the score and figt the squareMan
  --that lives in gamesState 3 and stop the triangles from attacking
  if score == 50 then
    sounds.victory:play()

gameState = 3

    for i,z in ipairs(zombies) do
      zombies[i] = nil
    end
  end --this is the end for the score 50 triggers, i can't tell if gameState =3 is working.



end --this is the end for love.update











function love.draw()

  --this draws the background first
  love.graphics.draw(sprites.background, 0, 0)
  -- a test line for gamestate gameState
  love.graphics.setColor(0, 0, 0)
  love.graphics.printf("GAMESTATE" .. gameState, 0, 10, love.graphics.getWidth(), "center")

-- this next line is a test for drawing blood
love.graphics.setColor(1, 0,0)
love.graphics.draw(sprites.blood2, 100, 50, nil, 0.1, 0.1)

---this gameState 1 stuff is our menu plus note for the dev
  if gameState == 1 then
    --ah, here is where the font was declared as 40 earlier, color set to black
    love.graphics.setFont(myFont)
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf("Click anywhere to begin!", 0, 50, love.graphics.getWidth(), "center")
    --these are dev notes, things to do
    love.graphics.printf("add high score, add JUICE! add levels? add square man, add camera shake and knock back", 0, 100, love.graphics.getWidth(), "center")
    love.graphics.printf("add blood, selective color, add controller support, add +1 animation per kill", 0, 350, love.graphics.getWidth(), "center")

  end --end of gamestate 1 draws


  --this prints the score even if gameState is not 1, this is a problem because it assumes we will stay binary, but we are adding a 3rd gamestate.
love.graphics.setColor(0, 0, 0)
love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")



--sets color back to white....it doesn't make sense to me, but it seemed nessessary.
love.graphics.setColor(1, 1, 1)

--draw the player
  love.graphics.draw(sprites.player, player.x, player.y, player_mouse_angle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)

if gameState == 3 then
  squareManDraw()
  bossbulletsDraw()
end

--goes through the 'zombies' table and draws the 'zombie' tables found
  for i,z in ipairs(zombies) do
    love.graphics.draw(sprites.zombie, z.x, z.y, zombie_player_angle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

-- this is the new attempt at blood code, it still does not work
--removes dead enemies from the zombies table
  for i=#zombies,1,-1 do
    local z = zombies[i]
    if z.dead == true then
      love.graphics.draw(sprites.blood2, zombie.x, zombie.y, nil, 0.1, 0.1)
      table.remove(zombies, i)
    end
  end




--goes though the table 'bullets' and draws the bullet tables found
  for i,b in ipairs(bullets) do
    love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
  end
end


--this function finds the angle of the mouse and we put it in a variable and use this to make player face the mouse.
function player_mouse_angle()
  return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

--this calculate the angle between player and enemy and puts it in a variable
function zombie_player_angle(enemy)
  return math.atan2(player.y - enemy.y, player.x - enemy.x)
end



--this function contains the table that defines what a zombie/enemy is.
function spawnZombie()
  zombie = {}
  zombie.x = 0
  zombie.y = 0
  zombie.speed = 100
  zombie.dead = false
--this sets it so the enemies appear at random positions outside of the screen
  local side = math.random(1, 4)

  if side == 1 then
    zombie.x = -30
    zombie.y = math.random(0, love.graphics.getHeight())
  elseif side == 2 then
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = -30
  elseif side == 3 then
    zombie.x = love.graphics.getWidth() + 30
    zombie.y = math.random(0, love.graphics.getHeight())
  else
    zombie.x = math.random(0, love.graphics.getWidth())
    zombie.y = love.graphics.getHeight() + 30
  end
--then the last line inserts 'zombie' into the table 'Zombies'
  table.insert(zombies, zombie)
end




--this sets the traits of the bullet including using the player mouse angle for it's direction.
function spawnBullet()
  bullet = {}
  bullet.x = player.x
  bullet.y = player.y
  bullet.speed = 500
  bullet.direction = player_mouse_angle()
  bullet.dead = false

  table.insert(bullets, bullet)
end




--below is the fire bullet code
--more than that if the key is press and gameState is one the game starts
--if gameState is 2 then it's the fire button.
function love.mousepressed( x, y, b, istouch)
  if b == 1 and gameState == 2 or gameState == 3 then
    spawnBullet()
    --sound for bullet
    sounds.pewPew:play()
  end
--this is the 'press any key' code
  if gameState == 1 then
    gameState = 2
    maxTime = 2
    timer = maxTime
    score = 0
  end



end -- this is the love.mousepressed end

--if don't know why the distanceBetween code lives here.
function distanceBetween(x1, y1, x2, y2)
  return math.sqrt((y2 - y1)^2 + (x2 - x1)^2)
end

--[[
	
	tic-tac-toe
	coded by https://github.com/waythink
  
	note: to run this game, you will need a compiler with an
	interactive shell.
  
	there is three game types available at the moment:
	player vs. player, player vs. AI, and AI vs. AI (namely, a demo mode)
	
--]]

-------------------
-- configuration --
-------------------

-- basic configuration --

local GAME_TYPES = {
	[1] = "PLAYER vs. AI",
	[2] = "PLAYER vs. PLAYER",
	[3] = "AI vs. AI"
}

local BOARD_SIZES = {
	[1] = 3, -- 3x3
	[2] = 4, -- 4x4
	[3] = 5 -- 5x5
}

local player = 'x'
local opponent = 'o'

local PLAYER_ONE_IS_HUMAN = false
local PLAYER_TWO_IS_AI = false

local w_char_length = math.max( player:len(), opponent:len(), string.len( '_' ) )

-- phrases --

local phrases = {
	-- main menu
	welcome = "\nWelcome to Tic-Tac-Toe!\nPress 'ENTER' to continue\n",
	selectBoardSize = "BOARD SIZES:\n[1] 3x3\t[2] 4x4\t[3] 5x5\nGame offers the above board sizes. Select your desired one.\n",
	selectGameType = "\nGAME TYPES:\n[1] PLAYER vs. AI\t[2] PLAYER vs. PLAYER\t\t[3] AI vs. AI\nGame offers the above game types. Select your desired one.\n",
	preGameCheck = "\nBOARD SIZE: %sx%s, GAME TYPE: %s\nWould you like to conitnue (Y/N)?\n",

	-- game started
	youreplaying = "\nYou're playing %s.\n",
	turn = "\n\n%s's turn.\n",

	requestX = "\nEnter the X-coordinate [1-%s]: ",
	requestY = "\nEnter the Y-coordinate [1-%s]: ",
	errorOutOfBoundaries = "\nYour coordinates were out of the game boundaries,\nso the move wasn't made.\n",

	pressKey = "\nPress 'ENTER' to continue.\n",

	-- game ended
	winner = "\n\n%s won the game! Congratulations!\n",
	draw = "\n\nThe game ended in a draw.\n"
}

local continuePhrases = { -- this is what's considered valid for (y / n) types of input
	[ 'y' ] = true, [ 'n' ] = 'exit', [ 'yes' ] = true, [ 'no' ] = 'exit',
	[ '1' ] = true, [ '2' ] = 'exit', [ 'yep' ] = true, [ 'nope' ] = 'exit',
	[ 'yeah' ] = true, ['nah'] = 'exit'
}

----------------
-- game setup --
----------------

local input, gameType, moveCount, gameOver

-- assign roles (e.g. player one -> ai, player two -> human)
local function assignRoles( gameType )
	if gameType == 1 then
		PLAYER_ONE_IS_HUMAN = true and ( math.random() > 0.5 ) or false
		
		if PLAYER_ONE_IS_HUMAN then
			PLAYER_TWO_IS_AI = true
		else
			PLAYER_TWO_IS_AI = false
		end

		io.write( string.format( phrases[ "youreplaying" ], ( PLAYER_ONE_IS_HUMAN and "X" ) or "O" ) )
	elseif gameType == 2 then
		PLAYER_ONE_IS_HUMAN = true
		PLAYER_TWO_IS_AI = false
	elseif gameType == 3 then
		PLAYER_ONE_IS_HUMAN = false
		PLAYER_TWO_IS_AI = true
	end

	player = ( PLAYER_ONE_IS_HUMAN and 'x' ) or 'o'
	opponent = ( PLAYER_ONE_IS_HUMAN and 'o' ) or 'x'
end

-----------------
-- board setup --
-----------------

local board, boardSize = { }

local function setupBoard()
    for i = 1, boardSize do
        board[ i ] = { }
        
        for j = 1, boardSize do
            board[ i ][ j ] = '_'
        end
    end

    loadWinningCases()
end

-- searches for winning figure on the board
local function searchForWinner( x, y, figure )
	-- search in columns
	for i = 1, boardSize do
		if board[ x ][ i ] ~= figure then
			break
		elseif i == boardSize then
			return figure
		end
	end
	
	-- search in rows
	for i = 1, boardSize do
		if board[ i ][ y ] ~= figure then
			break
		elseif i == boardSize then
			return figure
		end
	end

	-- diagonal search
	if x == y then
		for i = 1, boardSize do
			if board[ i ][ i ] ~= figure then
				break
			elseif i == boardSize then
				return figure
			end
		end
	end

	-- anti-diagonal search
	if ( x + y ) == ( boardSize + 1 ) then
		for i = 1, boardSize do
			if board[ i ][ ( boardSize + 1 ) - i ] ~= figure then
				break
			elseif i == boardSize then
				return figure
			end
		end
	end

	-- draw
    if moveCount == ( ( boardSize ^ 2 ) ) then
        return "draw"
    end

    return false
end

-- moves a figure to a certain coordinate on the board
local function moveFigure( x, y, figure )
	if board[ x ] then
		-- if 'y' coordinate doesn't exist on the board, return false
		if not board[ y ] then
			return false
		end
	else
		-- if 'x' coordinate doesn't exist on the board, return true
		return false
	end

	-- checks if the space is empty
	if board[ x ][ y ] == '_' then
		-- assign the figure to the cell
		board[ x ][ y ] = figure

		-- check if it was a winning move
		local winner = searchForWinner( x, y, figure )
		if winner then gameOver = winner end

		return true
	end

	return false
end

--------
-- ai --
--------

local r, num = { }, 1

-- creates all possible winning/blocking coordinates depending on the board size
function loadWinningCases()
	-- all possible column wins
	for i = 1, boardSize do
		r[ num ] = {}

		for j = 1, boardSize do
			r[ num ][ j ] = {}
			r[ num ][ j ][ 'x' ] = i
			r[ num ][ j ][ 'y' ] = j
		end

		num = num + 1
	end

	-- all possible row wins
	for i = 1, boardSize do
		r[ num ] = {}

		for j = 1, boardSize do
			r[ num ][ j ] = {}
			r[ num ][ j ][ 'x' ] = j
			r[ num ][ j ][ 'y' ] = i
		end

		num = num + 1
	end

	-- all possible diagonal wins
	r[ num ] = {}
	for i = 1, boardSize do
		r[ num ][ i ] = {}
		r[ num ][ i ][ 'x' ] = i
		r[ num ][ i ][ 'y' ] = i
	end
	num = num + 1

	-- all possible anti-diagonal wins
	r[ num ] = {}
	for i = boardSize, 1, -1 do
		r[ num ][ i ] = {}
		r[ num ][ i ][ 'x' ] = ( boardSize + 1 ) - i
		r[ num ][ i ][ 'y' ] = i
	end
	num = num + 1
end

-- assists in searching for the best coordinate set within cases
local function searchForWinningCoordinates( id )
	local score = 0
	local figure

	-- scroll through the cases, evaluate current game state
	for _, v in pairs(  r[ id ] ) do
		figure = board[ v[ 'x' ] ][ v[ 'y' ] ]

		-- add a point to the score for each 'x' found in the combination
		-- remove a point from the score for each 'o' found in the combination
		if figure == 'x' then score = score + 1 elseif figure == 'o' then score = score - 1 end
	end

	-- return the win chance
	return score
end

local multiplier, s = 1
local emptySpaces, move

-- controls the ai movement
local function aiMove( figure )
	if figure == 'o' then multiplier = -1 else multiplier = 1 end

	s = ( boardSize - 1 )

    -- search coordinates for a winning/blocking move
    for i in pairs( r ) do
        local case = searchForWinningCoordinates( i )

        if ( case == ( s * multiplier ) ) or ( case == ( s * ( multiplier * -1 ) ) ) then
            for _, v in pairs( r[ i ] ) do

                if board[ v[ 'x' ] ][ v[ 'y' ] ] == '_' then
                    moveFigure( v[ 'x' ], v[ 'y' ], figure )

                    return -- move is done, no need to go further
                end
            end
        end
    end

    emptySpaces = { }
    
    -- select a random empty space if no better option was found
    for i = 1, boardSize do
        for j = 1, boardSize do
        	if board[ i ][ j ] == '_' then
        		emptySpaces[ #emptySpaces + 1 ] = { i, j }
        	end
        end
    end

    -- move the figure to an empty space
    move = emptySpaces[ math.random( 1, #emptySpaces) ]

    if not move then return end
    moveFigure( move[ 1 ], move[ 2 ], figure )
end

-------------------------
-- ui & game functions --
-------------------------

-- dump the board to the shell
local function dumpBoard()
	io.write( '\n' )
	
	local repeats, str

	for i = 1, #board do
		local row, str = '', '' -- clear rows each iteration

		for j = 1, #board do
			row = row .. board[ i ][ j ]
			repeats = w_char_length - string.len( board[ i ][ j ] )

			-- repeat empty spaces in the string so everything matches up
			for r = 1, repeats do
				row = row .. " "
			end

			-- row ends, insert a vertical separator
			if j ~= #board then
				row = row .. " | "
			end
		end

		row = row:gsub( '_', ' ' )
		io.write( row ) -- print the generated row without underscores

		-- insert horizontal separators if they're needed
		if i ~= #board then
			repeats = math.ceil( string.len( row ) / string.len( '-' ) )

			for r = 1, repeats do
				str = str .. '-'
			end

			io.write( '\n' .. str .. '\n' )
		end
	end
end

local last_turn, multiplier

-- lets player play the game and controls the AI
local function processDuel( figure )
	dumpBoard() -- draw the board for the player

	figure = ( ( last_turn or 'o' ) == 'x' and 'o' ) or 'x'
	opponent = ( ( figure == 'x' ) and 'o' ) or 'x'

	player = figure

	-- who's turn it is?
	io.write( string.format( phrases["turn"], figure:upper() ) )

	local x, y = 1, 1

	-- demo & player vs AI modes
	if gameType == 3 or ( gameType == 1 and ( ( not PLAYER_ONE_IS_HUMAN and player == 'x' ) or PLAYER_TWO_IS_AI and player == 'o' ) ) then
		io.write( phrases[ "pressKey" ] )

		input = io.read() -- request the player to press a key before AI makes a move
		if not input then return end 
		io.flush() -- clear the input

		moveCount = ( moveCount or 0 ) + 1
		last_turn = figure

		aiMove( figure ) -- calculate the AI move

		io.write( '\n----------------\n')

		return true
	end

	local moveMade = false

	while not moveMade do -- request proper x & y coordinates from the player
		io.write( string.format( phrases[ "requestX" ], boardSize ) )
		io.flush() -- clear the input
		x = tonumber( io.read() )

		io.write( string.format( phrases[ "requestY" ], boardSize ) )
		io.flush() -- clear the input
		y = tonumber( io.read() )

		moveMade = moveFigure( y, x, figure )

		if not moveMade then io.write( phrases[ "errorOutOfBoundaries" ] ) end

		moveCount = ( moveCount or 0 ) + 1
		last_turn = figure
	end

	io.write( '\n----------------\n')

	dumpBoard() -- draw the board the player

	io.write( '\n\n' )
end

----------
-- main --
----------

-- hi!
io.write( phrases[ "welcome" ] )

input = io.read()
if not input then return end

repeat -- request board size from the player
	io.write( phrases[ "selectBoardSize" ] )
	io.flush() -- clear the input
	input = tonumber( io.read() ) or 1
until input >= 1 and input <= #BOARD_SIZES

boardSize = BOARD_SIZES[ input ]

repeat -- request game type from the player
	io.write( phrases[ "selectGameType" ] )
	io.flush() -- clear the input
	input = tonumber( io.read() ) or 1
until input >= 1 and input <= #GAME_TYPES

gameType = input

repeat -- check if player wants to continue
   io.write( string.format( phrases["preGameCheck"], boardSize, boardSize, GAME_TYPES[ gameType ] ) )
   io.flush() -- clear the input
   input = io.read()
until continuePhrases[ input:lower() ]

if continuePhrases[ input:lower() ] == "exit" then os.exit( 0 ) end

setupBoard()
assignRoles( gameType )

while true do
	-- process the moves
	processDuel()

	-- end the cycle if game is over
	if gameOver then break end
end

-- game is over, show the results
dumpBoard()

if gameOver == "draw" then
	io.write( phrases[ "draw" ] )
else
	io.write( string.format( phrases[ "winner" ], gameOver:upper() ) )
end
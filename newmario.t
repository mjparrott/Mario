/* Mario game
 Uses character class */

%Imports
import Character
%Includes
include "goomba.t"

%Setting up graphics
var window : int := Window.Open ("graphics:640;400,offscreenonly,nobuttonbar")

%Constants
const GROUND_HEIGHT := 50
const DELAY := 80 %What to put for the delay

%Procedures
%Setting up the charctesr
%Mario
var mario : pointer to Character
new Character, mario
mario -> stillImageRight := Pic.FileNew ("SMWSheet/still r.bmp")
mario -> walkImageRight := Pic.FileNew ("SMWSheet/moving r2.bmp")
mario -> stillImageLeft := Pic.FileNew ("SMWSheet/still l.bmp")
mario -> walkImageLeft := Pic.FileNew ("SMWSheet/moving l.bmp")
mario -> jumpImageRight := Pic.FileNew ("SMWSheet/jump r1.bmp")
mario -> jumpImageLeft := Pic.FileNew ("SMWSheet/jump l1.bmp")
mario -> initialize ("Mario", GROUND_HEIGHT, 0, KEY_RIGHT_ARROW, KEY_LEFT_ARROW, KEY_UP_ARROW, 'l')

%Luigi
var luigi : pointer to Character
new Character, luigi
luigi -> stillImageRight := Pic.FileNew ("SMWSheet/Luigi/still r.bmp")
luigi -> walkImageRight := Pic.FileNew ("SMWSheet/Luigi/moving r.bmp")
luigi -> stillImageLeft := Pic.FileNew ("SMWSheet/Luigi/still l.bmp")
luigi -> walkImageLeft := Pic.FileNew ("SMWSheet/Luigi/moving l.bmp")
luigi -> jumpImageRight := Pic.FileNew ("SMWSheet/Luigi/jump r1.bmp")
luigi -> jumpImageLeft := Pic.FileNew ("SMWSheet/Luigi/jump l1.bmp")
luigi -> initialize ("Luigi", GROUND_HEIGHT, 50, 'd', 'a', ' ', 's')

%Yoshi
var yoshi : pointer to Character
new Character, yoshi
yoshi -> stillImageRight := Pic.FileNew ("SMWSheet/Yoshi/still r.bmp")
yoshi -> walkImageRight := Pic.FileNew ("SMWSheet/Yoshi/moving r.bmp")
yoshi -> stillImageLeft := Pic.FileNew ("SMWSheet/Yoshi/still l.bmp")
yoshi -> walkImageLeft := Pic.FileNew ("SMWSheet/Yoshi/moving l.bmp")
yoshi -> jumpImageRight := Pic.FileNew ("SMWSheet/Yoshi/jump r1.bmp")
yoshi -> jumpImageLeft := Pic.FileNew ("SMWSheet/Yoshi/jump l1.bmp")
yoshi -> initialize ("Yoshi", GROUND_HEIGHT, 100, 'j', 'g', 'y', 'h')

%Images
var pipe : int := Pic.FileNew ("pipe.bmp")
var background : int := Pic.FileNew ("mariobg.bmp")
background := Pic.Scale (background, maxx, maxy)

%Colours for the background
var yellowshades : array 1 .. 255 of int
for i : 1 .. 255
	yellowshades (i) := RGB.AddColour (1, 1, i / 255)     %255, 255, 25
end for

var greenshades : array 1 .. 25 of int
for i : 1 .. 25
	greenshades (i) := RGB.AddColour (0, (i + 50) / 255, 0)
end for

%Music
var stopMusic : boolean := false
var stopPlaying : boolean := false
process playMusic
loop
	loop
		exit when stopPlaying
		Music.PlayFile ("Music/smb-overworld.mp3")
		
	end loop
	exit when stopMusic
	end loop
end playMusic
fork playMusic

%Mouse variables
var x, y, b : int
%Menu variables
%Constants
const BOX_WIDTH : int := maxx div 2
const BOX_HEIGHT : int := maxy div 6
%Variables
var option : int
var clicked : boolean := false
var options : array 1 .. 3 of string
options (1) := "Play"
options (2) := "Controls"
options (3) := "Quit"
var menuFont : int := Font.New ("Arial:16")
var gameFont : int := Font.New ("Mono:14")
var congratsFont : int := Font.New ("serif:30")

%Various keyboard input
var chars : array char of boolean

%Levels
var level : int := 1
proc endLevel
	level += 1
	cls
	Font.Draw ("Congratulations!", 10, maxy div 2, congratsFont, black)
	View.Update
	Music.PlayFileStop
	stopPlaying := true
	Music.PlayFile( "Course Clear.wav") 
	stopPlaying := false
end endLevel
proc lostLevel
end lostLevel

proc level1
	if mario -> x + Pic.Width ( ^ (mario -> imageToBlit)) >= maxx then
		endLevel
		mario -> x := 0
	else
		Font.Draw ("To finish level 1, walk to the edge of the screen.", 40, maxy - 20, gameFont, black)
	end if
end level1
forward function checkCollision (var Mario : pointer to Character, rx, ry, rx2, ry2 : int) : boolean
proc level2
	var block : int := Pic.FileNew ("block.bmp")
	if mario -> x + Pic.Width ( ^ (mario -> imageToBlit)) >= maxx then
		endLevel
		mario -> x := 0
		Pic.Free (block)
	else
		Font.Draw ("Get to the edge without hitting the boxes.", 100, maxy - 20, gameFont, black)
		Pic.Draw (block, 100, GROUND_HEIGHT, picCopy)

		Pic.Draw (block, 250, GROUND_HEIGHT, picCopy)
		Pic.Draw (block, 250, GROUND_HEIGHT + Pic.Height (block), picCopy)
		var tx : int := mario -> x
		var ty : int := mario -> y
		%Check for collision
		if checkCollision (mario, 100, GROUND_HEIGHT, 100 + Pic.Width (block), GROUND_HEIGHT + Pic.Height (block)) or
				checkCollision (mario, 250, GROUND_HEIGHT, 250 + Pic.Width (block), GROUND_HEIGHT + (Pic.Height (block) * 2)) then
			lostLevel
			mario -> x := 0
		end if
	end if
end level2
body function checkCollision (var Mario : pointer to Character, rx, ry, rx2, ry2 : int) : boolean
	var tx : int := Mario -> x
	var ty : int := Mario -> y
	var tx2 : int := Mario -> x + Pic.Width ( ^ (Mario -> imageToBlit))
	var ty2 : int := Mario -> y + Pic.Height ( ^ (Mario -> imageToBlit))
	if tx2 >= rx and tx <= rx2 and ty2 >= ry and ty <= ry2 then
		result true
	end if
	result false
end checkCollision

%Menu loop
loop

	clicked := false
	loop
		mousewhere (x, y, b)

		option := 0
		for i : 1 .. 3
			if x >= (maxx div 2) - (BOX_WIDTH div 2) and
					x <= (maxx div 2) + (BOX_WIDTH div 2) and
					y <= (maxy div 2) + (BOX_HEIGHT * 3 div 2) - ((i - 1) * BOX_HEIGHT) and
					y >= (maxy div 2) + (BOX_HEIGHT * 3 div 2) - (i * BOX_HEIGHT) then
				option := i
				if b = 1 then
					clicked := true
				end if
			end if
		end for
		exit when option not= 0 and clicked

		Pic.Draw (background, 0, 0, picCopy)
		Draw.Box ((maxx div 2) - (BOX_WIDTH div 2), (maxy div 2) - (BOX_HEIGHT * 3 div 2),
			(maxx div 2) + (BOX_WIDTH div 2), (maxy div 2) + (BOX_HEIGHT * 3 div 2), black)
		for i : 1 .. 3
			Draw.Line ((maxx div 2) - (BOX_WIDTH div 2), (maxy div 2) + (BOX_HEIGHT * 3 div 2) - (i * BOX_HEIGHT),
				(maxx div 2) + (BOX_WIDTH div 2), (maxy div 2) + (BOX_HEIGHT * 3 div 2) - (i * BOX_HEIGHT), black)
			if option = i then
				Draw.FillBox ((maxx div 2) - (BOX_WIDTH div 2) + 1, (maxy div 2) + (BOX_HEIGHT * 3 div 2) - ((i - 1) * BOX_HEIGHT) - 1,
					(maxx div 2) + (BOX_WIDTH div 2) - 1, (maxy div 2) + (BOX_HEIGHT * 3 div 2) - (i * BOX_HEIGHT) + 1, brightred)
			end if
			Font.Draw (options (i), (maxx div 2) - 50, (maxy div 2) + (BOX_HEIGHT * 3) - ((i + 1) * BOX_HEIGHT), menuFont, black)
		end for

		delay (10)
		View.Update
		cls
	end loop
	if option = 1 then
		%Main Loop
		loop

			Input.KeyDown (mario -> chars)
			Input.KeyDown (luigi -> chars)
			Input.KeyDown (yoshi -> chars)
			Input.KeyDown (chars)
			exit when chars (KEY_ESC)

			mario -> move

			mario -> collisionCheck

			mario -> chooseImage

			%Draw the ground and background
			for i : 1 .. 255
				drawfillbox (0, ((i - 1) * 2) + 50, maxx, (i * 2) + 50, yellowshades (i))
			end for
			Draw.Line (0, 50, maxx, 50, black)
			for i : 1 .. 25
				drawfillbox (0, ((i - 1) * 2), maxx, (i * 2), greenshades (i))
			end for

			if level = 1 then
				level1
			elsif level = 2 then
				level2
			end if

			mario -> blitImage

			mario -> loopEnd

			View.Update
			delay (DELAY)
			cls
		end loop
	elsif option = 2 then
		loop
			Input.KeyDown (chars)
			exit when chars (KEY_ESC)

			Pic.Draw (background, 0, 0, picCopy)
			Font.Draw ("Mario:", 100, maxy - 20, menuFont, black)
			Draw.Line (80, 100, 80, maxy, black)
			Font.Draw ("Luigi:", 300, maxy - 20, menuFont, black)
			Draw.Line (280, 100, 280, maxy, black)
			Font.Draw ("Yoshi:", 500, maxy - 20, menuFont, black)
			Draw.Line (480, 100, 480, maxy, black)
			Draw.Line (0, maxy - 60, maxx, maxy - 60, black)

			Font.Draw ("Move", 10, 300, menuFont, black)
			Draw.Line (0, 260, maxx, 260, black)
			Font.Draw ("Sprint", 10, 220, menuFont, black)
			Draw.Line (0, 180, maxx, 180, black)
			Font.Draw ("Jump", 10, 140, menuFont, black)
			Draw.Line (0, 100, maxx, 100, black)

			Font.Draw ("Press escape to return to the main menu.", 120, 40, menuFont, black)

			View.Update
			delay (10)
			cls
		end loop
	elsif option = 3 then
		exit
	end if
end loop
Window.Close (window)
stopMusic := true
stopPlaying := true
Music.PlayFileStop

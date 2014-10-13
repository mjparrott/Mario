/* Character Class for making mario game
 Can be used for different characters */
unit

class Character
	%Exports
	%Procdures
	export initialize, move, collisionCheck, chooseImage, blitImage, loopEnd, var chars, var name, var lastPad, var stillImageRight, var stillImageLeft, var walkImageRight, var walkImageLeft, var
		jumpImageRight, var jumpImageLeft, var x, var y, var isJumping, var imageToBlit, var velX, var GROUND_HEIGHT


	%%%%%Variables%%%%%
	var name : string

	var x : int
	var y : int
	var velX : int
	var velY : int := 0             %Current speeds for the character
	var speed : int := 5             %speed at which character walks
	var jumpSpeed : int := 25

	var picChooser : boolean := false             %False = still picture,
	%True = moving picture
	var direction : string             %Can be left or right
	var lastPad : boolean             %To check to see if user is holding left
	%or right arrows, used for walking
	var lastPadJump : boolean := false             %Check to see if user was holding
	%the jump button
	var isJumping : boolean := false
	var GROUND_HEIGHT : int

	var chars : array char of boolean
	Input.KeyDown (chars)             %To put something the chars array(prevents errors)

	%Keys for moving left and right
	var leftKey : char
	var rightKey : char
	var jumpKey : char
	var sprintKey : char

	%%%%Image Variables%%%%
	var stillImageRight : int
	var stillImageLeft : int
	var walkImageRight : int
	var walkImageLeft : int
	var jumpImageRight : int
	var jumpImageLeft : int
	var imageToBlit : unchecked ^int
	new imageToBlit

	%Set up all the variables for the character
	%Left and right key are for how to move your character
	proc initialize (characterName : string, groundHeight : int, playerX : int, rightMove : char, leftMove : char, upMove : char, sprintMove : char)
		name := characterName
		x := playerX
		y := groundHeight
		GROUND_HEIGHT := groundHeight
		direction := "right"
		lastPad := false
		rightKey := rightMove
		leftKey := leftMove
		jumpKey := upMove
		sprintKey := sprintMove
		^imageToBlit := stillImageRight

		%Change the transparent colour of the images
		var bgColour : int := RGB.AddColour (255 / 255, 0, 220 / 255)
		Pic.SetTransparentColour (stillImageRight, bgColour)
		Pic.SetTransparentColour (stillImageLeft, bgColour)
		Pic.SetTransparentColour (walkImageRight, bgColour)
		Pic.SetTransparentColour (walkImageLeft, bgColour)
		Pic.SetTransparentColour (jumpImageRight, bgColour)
		Pic.SetTransparentColour (jumpImageLeft, bgColour)
	end initialize

	%Get movements for the current loop
	proc move
		velX := 0
		if chars (rightKey) then
			picChooser := not picChooser
			velX := speed
			direction := "right"
			lastPad := true
		end if
		if chars (leftKey) then
			picChooser := not picChooser
			velX := -speed
			direction := "left"
			lastPad := true
		end if
		if chars (jumpKey) and not isJumping then
			isJumping := true
			velY := jumpSpeed
			lastPad := true
		end if

		%SPRINT!
		if chars (sprintKey) and direction = "right" and lastPad then
			velX += speed
		end if
		if chars (sprintKey) and direction = "left" and lastPad then
			velX -= speed
		end if

		x := x + velX
		y := y + velY
		if isJumping then
			velY := velY - 5                                     %GRAVITY
		end if
	end move

	%Make sure they don't go offscreen
	proc collisionCheck
		if x > maxx - Pic.Width ( ^ (imageToBlit)) then
			x := maxx - Pic.Width ( ^ (imageToBlit))                                   %Roughly size of the images
		end if
		if x < 0 then
			x := 0
		end if
	end collisionCheck

	%Choose the correct image to draw
	proc chooseImage
		if direction = "right" then
			if lastPad and picChooser then
				^imageToBlit := walkImageRight
			else
				^imageToBlit := stillImageRight
			end if
			if isJumping then
				^imageToBlit := jumpImageRight
			end if
		else
			if lastPad and not picChooser then
				^imageToBlit := walkImageLeft
			else
				^imageToBlit := stillImageLeft
			end if
			if isJumping then
				^imageToBlit := jumpImageLeft
			end if
		end if
	end chooseImage

	%Blit the required images to screen
	proc blitImage
		Pic.Draw ( ^imageToBlit, x, y, picMerge)
	end blitImage

	proc loopEnd
		lastPad := false
		if not (chars (leftKey) or chars (rightKey)) then
			picChooser := false
		end if
		if chars (jumpKey) then
			lastPadJump := true
		else
			lastPadJump := false
		end if
		if y <= GROUND_HEIGHT + 5 then                         %+ 5 gets rid of glitchiness
			isJumping := false
			velY := 0
			y := GROUND_HEIGHT
		end if
	end loopEnd
end Character

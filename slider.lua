-- Copyright (C) 2013 Corona Inc. All Rights Reserved.
-- File: newSlider unit test.

local widget = require( "widget" )
local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local USE_ANDROID_THEME = false
local USE_IOS7_THEME = true
local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

local xAnchor, yAnchor

if not isGraphicsV1 then
	xAnchor = display.contentCenterX
	yAnchor = display.contentCenterY
else
	xAnchor = 0
	yAnchor = 0
end

--Forward reference for test function timer
local testTimer = nil

function scene:createScene( event )
	local group = self.view
	
	--Display an iOS style background
	local background
	
	if USE_IOS7_THEME then
		background = display.newRect( xAnchor, yAnchor, display.contentWidth, display.contentHeight )
	else
		background = display.newImage( "unitTestAssets/background.png" )
		background.x, background.y = xAnchor, yAnchor
	end
	
	group:insert( background )
	
	if USE_IOS7_THEME then
		-- create a white background, 40px tall, to mask / hide the scrollView
		local topMask = display.newRect( 0, 0, display.contentWidth, 40 )
		topMask:setFillColor( 235, 235, 235, 255 )
		group:insert( topMask )
	end
	
	local backButtonPosition = 5
	local backButtonSize = 52
	local fontUsed = native.systemFont
	
	
	if USE_IOS7_THEME then
		backButtonPosition = 0
		backButtonSize = 40
		fontUsed = "HelveticaNeue-Light"
	end
		
	-- Test android theme
	if USE_ANDROID_THEME then
		widget.setTheme( "widget_theme_android" )
	end

	-- Button to return to unit test listing
	local returnToListing = widget.newButton{
	    id = "returnToListing",
	    left = display.contentWidth * 0.5,
	    top = backButtonPosition,
	    label = "Exit",
	    width = 200, height = backButtonSize,
	    cornerRadius = 8,
	    onRelease = function() storyboard.gotoScene( "unitTestListing" ) end;
	}
	returnToListing.x = display.contentCenterX
	group:insert( returnToListing )
	
	----------------------------------------------------------------------------------------------------------------
	--										START OF UNIT TEST
	----------------------------------------------------------------------------------------------------------------
	
	--Toggle these defines to execute tests. NOTE: It is recommended to only enable one of these tests at a time
	local TEST_SET_VALUE = false
	
	--Create some text to show the sliders output
	local sliderResult = display.newEmbossedText( "Slider at 50%", 0, 0, fontUsed, 22 )
	sliderResult:setFillColor( 0 )
	
	if isGraphicsV1 then
		sliderResult:setReferencePoint( display.CenterReferencePoint )
	end
	
	sliderResult.x = 160
	sliderResult.y = 250
	group:insert( sliderResult )
	
	-- Slider listener function
	local function sliderListener( event )
		--print( "phase is:", event.phase )
		sliderResult:setText( "Slider at " .. event.value .. "%" )
	end

	-- Create a horizontal slider
	local sliderHorizontal = widget.newSlider
	{
		width = 200,
		left = 80,
		top = 300,
		value = 50,
		listener = sliderListener,
	}
	sliderHorizontal.x = display.contentCenterX
	group:insert( sliderHorizontal )
			
	-- Create a vertical slider
	local sliderVertical = widget.newSlider
	{
		height = 150,
		top = 130,
		left = 50,
		value = 80,
		orientation = "vertical",
		listener = sliderListener,
	}
	group:insert( sliderVertical )



	-- Skinned (horizontal)
	local sliderFrames = {
		frames = {
			{ x=0, y=0, width=64, height=64 },
			{ x=64, y=0, width=64, height=64 },
			{ x=128, y=0, width=64, height=64 },
			{ x=194, y=0, width=64, height=64 },
			{ x=262, y=0, width=64, height=64 }
		}, sheetContentWidth = 332, sheetContentHeight = 64
	}
	local sliderSheet = graphics.newImageSheet( "unitTestAssets/sliderSheet.png", sliderFrames )

	local sliderH = widget.newSlider
	{
		sheet = sliderSheet,
		leftFrame = 1,
		middleFrame = 2,
		rightFrame = 3,
		frameWidth = 64,
		frameHeight = 64,
		fillFrame = 5,
		fillFrameWidth = 64,
		handleFrame = 4,
		handleWidth = 64,
		handleHeight = 64,
		width = 400,
		top = 10,
		left= 0,
		value = 40
	}
	sliderH.x = display.contentCenterX
	sliderH.y = display.contentCenterY+180

	-- Skinned (vertical)
	local sliderFramesVertical = {
		frames = {
			{ x=0, y=0, width=64, height=64 },
			{ x=0, y=64, width=64, height=64 },
			{ x=0, y=128, width=64, height=64 },
			{ x=0, y=194, width=64, height=64 },
			{ x=0, y=262, width=64, height=64 }
		}, sheetContentWidth = 64, sheetContentHeight = 332
	}
	local sliderSheetVertical = graphics.newImageSheet( "unitTestAssets/sliderSheetVertical.png", sliderFramesVertical )

	local sliderV = widget.newSlider
	{
		sheet = sliderSheetVertical,
		topFrame = 1,
		middleVerticalFrame = 2,
		bottomFrame = 3,
		frameWidth = 64,
		frameHeight = 64,
		fillVerticalFrame = 5,
		fillFrameHeight = 64,
		handleFrame = 4,
		handleWidth = 64,
		handleHeight = 64,
		orientation = "vertical",
		height = 300,
		top = 10,
		left = 0,
		value = 40
	}
	sliderV.x = display.contentCenterX+120
	sliderV.y = display.contentCenterY-50
	
	

	----------------------------------------------------------------------------------------------------------------
	--											TESTS
	----------------------------------------------------------------------------------------------------------------
	
	--Test setValue()
	if TEST_SET_VALUE then
		testTimer = timer.performWithDelay( 1000, function()
			sliderHorizontal:setValue( 0 )
			sliderVertical:setValue( 0 )
			sliderResult:setText( "Slider at " .. sliderHorizontal.value .. "%" )
		end, 1 )
	end
end

function scene:didExitScene( event )
	--Cancel test timer if active
	if testTimer ~= nil then
		timer.cancel( testTimer )
		testTimer = nil
	end
	
	storyboard.removeAll()
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

return scene

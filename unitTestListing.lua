-- Copyright (C) 2013 Corona Inc. All Rights Reserved.

local widget = require( "widget" )

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

local USE_ANDROID_THEME = false
local USE_IOS7_THEME = true

local isGraphicsV1 = ( 1 == display.getDefault( "graphicsCompatibility" ) )

local topGrayColor = { 0.92, 0.92, 0.92, 1 }
local separatorColor = { 0.77, 0.77, 0.77, 1 }
local headerTextColor = { 0, 0, 0, 1 }

if isGraphicsV1 then
	widget._convertColorToV1( topGrayColor )
	widget._convertColorToV1( separatorColor )	
	widget._convertColorToV1( headerTextColor )
end

function scene:createScene( event )	
	local group = self.view
	
	-- Set theme
	if USE_ANDROID_THEME then
		widget.setTheme( "widget_theme_android" )
	end
	
	if USE_IOS7_THEME then
		--widget.setTheme( "widget_theme_ios7" )
	end
	
	--Display an iOS style background
	local background
	
	local xAnchor, yAnchor
	
	if not isGraphicsV1 then
		xAnchor = display.contentCenterX
		yAnchor = display.contentCenterY
	else
		xAnchor = 0
		yAnchor = 0
	end
	
	if USE_IOS7_THEME then
		background = display.newRect( xAnchor, yAnchor, display.contentWidth, display.contentHeight )
	else
		background = display.newImage( "unitTestAssets/background.png" )
		background.x, background.y = xAnchor, yAnchor
	end

	group:insert( background )

	local scrollView = widget.newScrollView
	{
		left = 0,
		top = 40,
		--x = display.contentWidth * 0.5,
		--y = display.contentHeight * 0.5 + 20,
		width = display.contentWidth,
		height = display.contentHeight - 40,
		horizontalScrollDisabled = true,
		hideScrollBar = true,
		hideBackground = true,
	}
	group:insert( scrollView )
	
	if USE_IOS7_THEME then
		-- create a white background, 40px tall, to mask / hide the scrollView
		local topMask = display.newRect( 0, 0, display.contentWidth, 40 )
		if not isGraphicsV1 then
			topMask.x = topMask.x + topMask.contentWidth * 0.5
			topMask.y = topMask.y + topMask.contentHeight * 0.5
		end
		topMask:setFillColor( unpack( topGrayColor ) )
		topMask.alpha = 0
		group:insert( topMask )
	end
	
	--Create a title to make the menu visibly clear
	
	-- create some skinning variables
	local fontUsed = native.systemFont
	local headerTextSize = 20
	local separatorColor = { unpack( separatorColor ) }
	
	if USE_IOS7_THEME then
		fontUsed = "HelveticaNeue-Medium"
		headerTextSize = 17
	end
	
	local title = display.newEmbossedText( group, "Select a unit test to view", 0, 0, fontUsed, headerTextSize )
	title:setFillColor( unpack( headerTextColor ) )
	title.x, title.y = display.contentCenterX, 20
	group:insert( title )
	
	if USE_IOS7_THEME then
		local separator = display.newRect( group, 0, title.contentHeight + title.y, display.contentWidth, 0.5 )
		separator:setFillColor( unpack ( separatorColor ) )
	end
	

	
	--Go to selected unit test
	local function gotoSelection( event )
		local phase = event.phase
		
		if "moved" == phase then		
			local dy = math.abs( event.y - event.yStart )
		
			if dy > 15 then
				scrollView:takeFocus( event )
			end
		elseif "ended" == phase then
			local targetScene = event.target.id
		
			storyboard.gotoScene( targetScene )
		end
		
		return true
	end

	-- spinner unit test
	local spinnerButton = widget.newButton
	{
	    id = "spinner",
	    left = 0,
	    top = 10,
	    label = "Spinner",
	    width = display.contentWidth, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( spinnerButton )
	
	
	-- switch unit test
	local switchButton = widget.newButton
	{
	    id = "switch",
	    left = 60,
	    top = spinnerButton.y + 30,
	    label = "Switch",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( switchButton )
	
	
	-- Stepper unit test
	local stepperButton = widget.newButton
	{
	    id = "stepper",
	    left = 60,
	    top = switchButton.y + 30,
	    label = "Stepper",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( stepperButton )
	
	
	-- Search field unit test
	local searchFieldButton = widget.newButton
	{
	    id = "searchField",
	    left = 60,
	    top = stepperButton.y + 30,
	    label = "Search Field",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( searchFieldButton )
	
	-- progressView unit test
	local progressViewButton = widget.newButton
	{
	    id = "progressView",
	    left = 60,
	    top = searchFieldButton.y + 30,
	    label = "Progress View",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( progressViewButton )
	
	-- segmentedControl unit test
	local segmentedControlButton = widget.newButton
	{
	    id = "segmentedControl",
	    left = 0,
	    top = progressViewButton.y + 30,
	    label = "Segmented Control",
	    width = display.contentWidth, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( segmentedControlButton )
	
	-- button unit test
	local buttonButton = widget.newButton
	{
	    id = "button",
	    left = 60,
	    top = segmentedControlButton.y + 30,
	    label = "Button",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( buttonButton )
	
	-- tabBar unit test
	local tabBarButton = widget.newButton
	{
	    id = "tabBar",
	    left = 60,
	    top = buttonButton.y + 30,
	    label = "TabBar",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( tabBarButton )
	
	-- slider unit test
	local sliderButton = widget.newButton
	{
	    id = "slider",
	    left = 60,
	    top = tabBarButton.y + 30,
	    label = "Slider",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( sliderButton )
	
	-- picker unit test
	local pickerButton = widget.newButton
	{
	    id = "picker",
	    left = 60,
	    top = sliderButton.y + 30,
	    label = "Picker",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( pickerButton )
	
	-- tableView unit test
	local tableViewButton = widget.newButton
	{
	    id = "tableView",
	    left = 60,
	    top = pickerButton.y + 30,
	    label = "TableView",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( tableViewButton )
	
	-- scrollView unit test
	local scrollViewButton = widget.newButton
	{
	    id = "scrollView",
	    left = 60,
	    top = tableViewButton.y + 30,
	    label = "ScrollView",
	    width = 200, height = 52,
	    cornerRadius = 8,
	    onEvent = gotoSelection
	}
	scrollView:insert( scrollViewButton )
end

function scene:didExitScene( event )
	storyboard.removeAll()
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "didExitScene", scene )

return scene

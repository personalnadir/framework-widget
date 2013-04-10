--[[
	Copyright:
		Copyright (C) 2013 Corona Inc. All Rights Reserved.
		
	File: 
		widget.lua
--]]

local widget = 
{
	version = "2.0",
	_directoryPath = "",
}

---------------------------------------------------------------------------------
-- PRIVATE METHODS
---------------------------------------------------------------------------------

-- Modify factory function to ensure widgets are properly cleaned on group removal
local cached_displayNewGroup = display.newGroup
function display.newGroup()
	local newGroup = cached_displayNewGroup()
	
	-- Function to find/remove widgets within group
	local function removeWidgets( group )
		if group.numChildren then
			for i = group.numChildren, 1, -1 do
				if group[i]._isWidget then
					group[i]:removeSelf()
				
				elseif not group[i]._isWidget and group[i].numChildren then
					-- Nested group (that is not a widget)
					removeWidgets( group[i] )
				end
			end
		end
	end
	
	-- Store a reference to the original removeSelf method
	local cached_removeSelf = newGroup.removeSelf
	
	-- Subclass the removeSelf method
	function newGroup:removeSelf()
		-- Remove widgets first
		removeWidgets( self )
		
		-- Continue removing the group as usual
		if self.parent and self.parent.remove then
			self.parent:remove( self )
		end
	end
	
	return newGroup
end

-- Override removeSelf() method for new widgets
local function _removeSelf( self )
	-- All widget objects can add a finalize method for cleanup
	local finalize = self._finalize
	
	-- If this widget has a finalize function
	if type( finalize ) == "function" then
		finalize( self )
	end

	-- Remove the object
	self:_removeSelf()
	self = nil
end


-- Dummy function to remove focus from a widget, any widget can override this function to remove focus if needed.
function widget._loseFocus()
	return
end

-- Widget constructor. Every widget object is created from this method
function widget._new( options )
	local newWidget = display.newGroup() -- All Widget* objects are display groups
	newWidget.x = options.left or 0
	newWidget.y = options.top or 0
	newWidget.id = options.id or "widget*"
	newWidget.baseDir = options.baseDir or system.ResourceDirectory
	newWidget._isWidget = true
	newWidget._widgetType = options.widgetType
	newWidget._removeSelf = newWidget.removeSelf
	newWidget.removeSelf = _removeSelf
	newWidget._loseFocus = widget._loseFocus
	
	return newWidget
end

-- Function to retrieve a frame index from an imageSheet data file
function widget._getFrameIndex( theme, frame )
	if theme then
		if theme.data then
			if "function" == type( require( theme.data ).getFrameIndex ) then
				return require( theme.data ):getFrameIndex( frame )
			end
		end
	end
end

-- Function to check if the requirements for creating a widget have been met
function widget._checkRequirements( options, theme, widgetName )
	-- If we are using single images, just return
	if options.defaultFile or options.overFile then
		return
	end
	
	-- If there isn't an options table and there isn't a theme set, throw an error
	local noParams = not options and not theme
	
	if noParams then
		error( "WARNING: Either you haven't set a theme using widget.setTheme or the widget theme you are using does not support " .. widgetName, 3 )
	end
	
	-- If the user hasn't provided the necessary image sheet lua file (either via custom sheet or widget theme)
	local noData = not options.data and not theme.data

	if noData then
		if widget.theme then
			error( "ERROR: " .. widgetName .. ": theme data file expected, got nil", 3 )
		else
			error( "ERROR: " .. widgetName .. ": Attempt to create a widget with no custom imageSheet data set and no theme set, if you want to use a theme, you must call widget.setTheme( theme )", 3 )
		end
	end
	
	-- Throw error if the user hasn't defined a sheet and has defined data or vice versa.
	local noSheet = not options.sheet and not theme.sheet
	
	if noSheet then
		if widget.theme then
			error( "ERROR: " .. widgetName .. ": Theme sheet expected, got nil", 3 )
		else
			error( "ERROR: " .. widgetName .. ": Attempt to create a widget with no custom imageSheet set and no theme set, if you want to use a theme, you must call widget.setTheme( theme )", 3 )
		end
	end		
end

-- Set the current theme from a lua theme file
function widget.setTheme( themeModule )
	-- Returns table with theme data
	widget.theme = require( themeModule )
end

-- Function to retrieve a widget's theme settings
local function _getTheme( widgetTheme, options )	
	local theme = nil
		
	-- If a theme has been set
	if widget.theme then
		theme = widget.theme[widgetTheme]
	end
	
	-- If a theme exists
	if theme then
		-- Style parameter optionally set by user
		if options and options.style then
			local style = theme[options.style]
			
			-- For themes that support various "styles" per widget
			if style then
				theme = style
			end
		end
	end
	
	return theme
end

-- Function to check if an object is within bounds
function widget._isWithinBounds( object, event )
	local bounds = object.contentBounds
    local x, y = event.x, event.y
	local isWithinBounds = true
		
	if "table" == type( bounds ) then
		if "number" == type( x ) and "number" == type( y ) then
			isWithinBounds = bounds.xMin <= x and bounds.xMax >= x and bounds.yMin <= y and bounds.yMax >= y
		end
	end
	
	return isWithinBounds
end

------------------------------------------------------------------------------------------
-- PUBLIC METHODS
------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- newScrollView widget
-----------------------------------------------------------------------------------------

function widget.newScrollView( options )	
	return require( widget._directoryPath .. "widget_scrollview" ).new( options )
end

-----------------------------------------------------------------------------------------
-- newTableView widget
-----------------------------------------------------------------------------------------

function widget.newTableView( options )
	return require( widget._directoryPath .. "widget_tableview" ).new( options )
end

-----------------------------------------------------------------------------------------
-- newPickerWheel widget
-----------------------------------------------------------------------------------------

function widget.newPickerWheel( options )
	local theme = _getTheme( "pickerWheel", options )
	
	return require( widget._directoryPath .. "widget_pickerWheel" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newSlider widget
-----------------------------------------------------------------------------------------

function widget.newSlider( options )	
	local theme = _getTheme( "slider", options )
	
	return require( widget._directoryPath .. "widget_slider" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newTabBar widget
-----------------------------------------------------------------------------------------

function widget.newTabBar( options )
	local theme = _getTheme( "tabBar", options )
	
	return require( widget._directoryPath .. "widget_tabbar" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newButton widget
-----------------------------------------------------------------------------------------

function widget.newButton( options )
	local theme = _getTheme( "button", options )
	
	return require( widget._directoryPath .. "widget_button" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newSpinner widget
-----------------------------------------------------------------------------------------

function widget.newSpinner( options )
	local theme = _getTheme( "spinner", options )

	return require( widget._directoryPath .. "widget_spinner" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newSwitch widget
-----------------------------------------------------------------------------------------

function widget.newSwitch( options )
	local theme = _getTheme( "switch", options )
	
	return require( widget._directoryPath .. "widget_switch" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newStepper widget
-----------------------------------------------------------------------------------------

function widget.newStepper( options )
	local theme = _getTheme( "stepper", options )
	
	return require( widget._directoryPath .. "widget_stepper" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newSearchField widget
-----------------------------------------------------------------------------------------

function widget.newSearchField( options )
	local theme = _getTheme( "searchField", options )
	
	return require( widget._directoryPath .. "widget_searchField" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newProgressView widget
-----------------------------------------------------------------------------------------

function widget.newProgressView( options )
	local theme = _getTheme( "progressView", options )
	
	return require( widget._directoryPath .. "widget_progressView" ).new( options, theme )
end

-----------------------------------------------------------------------------------------
-- newSegmentedControl widget
-----------------------------------------------------------------------------------------

function widget.newSegmentedControl( options )
	local theme = _getTheme( "segmentedControl", options )
	
	return require( widget._directoryPath .. "widget_segmentedControl" ).new( options, theme )
end


-- Get platform
local isAndroid = "Android" == system.getInfo( "platformName" )
local defaultTheme = "widget_theme_ios"

if isAndroid then
	defaultTheme = "widget_theme_android"
end

-- Set the default theme
widget.setTheme( defaultTheme )

return widget

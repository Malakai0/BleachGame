--[[

    This module will let me keep track of the framework / game as it is.
    HOPEFULLY doing this will help me get a better idea of what I need to do moving forward.

    So;

    Right now,
    I have a Camera Controller that will allow for better control over the camera so adding weapons that manipulate the camera pog easy.
    Alongside this is a Class Controller which will make for changing classes real simple.

    And all the general game loop stuff will be dealt with in the System Controller, which will run each system in Modules->Systems.

    The Gui Controller is sort of a side-controller which will be used by Systems to do stuff regarding UI.

    My next goal is to implement WEAPONS. My first thought is a Weapon Controller, but which may be BETTER, is an INVENTORY CONTROLLER!!
    This will NOT do anything in terms of GUI, but it will handle equipping / unequipping items (including weapons) and just random shit lol

    The proposed system will make for easier connection handling, too.

]]--

return {}
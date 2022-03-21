--[[

    Class - CameraProfile

    CameraProfile.Name - the name of the profile.
    CameraProfile.Controller - a reference to the CameraController.
    CameraProfile.Environment - a reference to a custom environment that is instantiated when the class is initialized.

    CameraProfile.Priority - an abritrary number; of all the active profiles, the highest is used.
    CameraProfile:Initialize() - where all the camera setup stuff should be done; CameraTypes, Subjects, etc.
    CameraProfile:Update(deltaTime: number) - each frame, this will call and should update the camera's position.

    All camera profiles inherit _std.lua

]]--

return {}
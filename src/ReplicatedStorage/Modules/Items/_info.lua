--[[

    Class - PlayerItem

    --// Contructor \\--

    PlayerItem.new(Name, Owner?, State?)

    --// Fields \\--

    PlayerItem.Name - A string; the name of the Item.
    PlayerItem.Owner - A Player or nil; the owner, duh.
    PlayerItem.State - A table; this is an optional table that holds the state of the item.
    PlayerItem.Trove - A Trove used to keep track of all connections to prevent memory leaks. Destroyed when :Destroy() is called.
    PlayerItem.Player - A reference to the player. NOTE: THIS IS NOT SET AUTOMATICALLY, SET IT UP IN :Init()
    PlayerItem.Animations - A table of animations used by the item.
    PlayerItem.Model? - A reference to the model, if any. NOTE: THIS IS NOT SET AUTOMATICALLY, SET IT UP IN :Init()

    --// User-defined \\--
    PlayerItem:Init() - Called when the PlayerItem is instantiated, used to set up model
    PlayerItem:Equip() - This is user-set - Called when the item is equipped
    PlayerItem:Unequip() - This is user-set - Called when the item is unequipped
    PlayerItem:Activated() - This is user-set - Called when the item is activated
    PlayerItem:Unactivated() - This is user-set - Called when the item is unactivated

    --// Stock methods \\--
    PlayerItem:PlayAnimation(Animation) - Plays an animation on the player.
    PlayerItem:PlayToolAnimation(Animation) - Plays an animation on the player's tool.
    PlayerItem:SpawnAt(CFrame) - Will spawn the item at any CFrame ()
    PlayerItem:ApplyWeld(C1: CFrame, C0: CFrame?) - Applies a weld.. C1 is unusually put first because if C0 is nil, it will be relative to the HumanoidRootPart.
    PlayerItem:Destroy() - Calls :Unequip(), destroys the model (if any) and cleans up all connections. Completely poof'd.

    --// PRIVATE \\--
    PlayerItem._weld - The reference to the current weld used for holding the item.
    PlayerItem:_equip(_use_default_animation: boolean) - Internal method for equipping the item.
    PlayerItem:_unequip() - Internal method for unequipping the item.

]]--

return {}
local Rp = game:GetService("ReplicatedStorage")
local Hit = Rp:WaitForChild("Hit")
local Stunned = Rp:WaitForChild("Stunned")

local Uis = game:GetService("UserInputService")
local Player = game.Players.LocalPlayer

local Char = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Char:WaitForChild("Humanoid")
local animator = Humanoid:WaitForChild("Animator")

local Tool = script.Parent
Tool.CanBeDropped = false

local animationshit = {
	"rbxassetid://72370523228326", -- M1
	"rbxassetid://80431748539200",
	"rbxassetid://134344364292470"
}

local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://116499030936337"
local Track = animator:LoadAnimation(animation)
Track.Priority = Enum.AnimationPriority.Action

local AnimWalk = Instance.new("Animation")
AnimWalk.AnimationId = "rbxassetid://101769643004293"
local TrackWalk = animator:LoadAnimation(AnimWalk)
TrackWalk.Priority = Enum.AnimationPriority.Action

local Equipped = false

Tool.Equipped:Connect(function()
	-- Se stunnati, impedisce di equipaggiare l'arma
	if Char:GetAttribute("IsStunned") == true then
		task.defer(function() Humanoid:UnequipTools() end)
		return
	end

	Equipped = true
	Humanoid.WalkSpeed = 10
	for _, idle in pairs(animator:GetPlayingAnimationTracks()) do
		if idle.Name == "idle" then
			idle:Stop()
		end
	end
	Track:Play()
end)

Tool.Unequipped:Connect(function()
	Equipped = false
	Humanoid.WalkSpeed = 16
	Track:Stop()
end)

local HitTrack= {}
for i, AnimHit in pairs(animationshit) do
	local animation = Instance.new("Animation")
	animation.AnimationId = AnimHit
	HitTrack[i] = animator:LoadAnimation(animation)
	HitTrack[i].Priority = Enum.AnimationPriority.Action4
end

local comboReset = nil
local comboIndex = 1
local db = false

Uis.InputBegan:Connect(function(key, mess)
	if mess then return end

	if Char:GetAttribute("IsStunned") == true then return end

	if key.UserInputType == Enum.UserInputType.MouseButton1 then
		if Equipped then
			if db then return end
			db = true

			if comboReset then
				task.cancel(comboReset)  
			end

			for _, track in pairs(HitTrack) do
				track:Stop()
			end

			HitTrack[comboIndex]:Play()
			Hit:FireServer()

			comboIndex = comboIndex + 1
			if comboIndex > #HitTrack then
				comboIndex = 1
			end

			task.delay(0.6, function()
				for _, track in pairs(HitTrack) do
					track:Stop()
				end
			end)

			comboReset = task.delay(1, function()
				comboIndex = 1
			end)

			task.wait(0.6)
			db = false
		end
	end
end)

Humanoid.Running:Connect(function(speed)
	if not Equipped then
		TrackWalk:Stop()
		return
	end

	if speed > 1 and Equipped then
		if not TrackWalk.IsPlaying then
			TrackWalk:Play()
		end
	else
		TrackWalk:Stop()
	end
end)

local stunnedPlayers = {}
Stunned.OnClientEvent:Connect(function(HumanoidNem, IsStunnedState)
	--Se il valore è falso allora ignora lo stun
	if not IsStunnedState then return end	

	--Aggiunge il player stunnato nel table dei player stunnati
	if stunnedPlayers[HumanoidNem] then return end
	stunnedPlayers[HumanoidNem] = true

	--Gli toglie l'arma
	HumanoidNem:UnequipTools()

	local AnimatorNem = HumanoidNem:WaitForChild("Animator")
	local AnimationStun = Instance.new("Animation")
	AnimationStun.AnimationId = "rbxassetid://104672965073268"

	local trackStun = AnimatorNem:LoadAnimation(AnimationStun)
	trackStun:Play()

	--Set anim a falso
	HumanoidNem.WalkSpeed = 0
	Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)

	task.delay(0.8, function()
		--Lo toglie dal table (il player attaccato) se passano 0.8 secondi non visti
		stunnedPlayers[HumanoidNem] = false
	
		if HumanoidNem and HumanoidNem.Parent then
			HumanoidNem.WalkSpeed = 16
			Humanoid:SetStateEnabled(Enum.HumanoidStateType.Jumping, true)
		end
	end)
end)
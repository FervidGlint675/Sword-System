local Rp = game:GetService("ReplicatedStorage")
local Hit = Rp:WaitForChild("Hit")
local Stunned = Rp:WaitForChild("Stunned")

--Debounce Per player che tocca hitbox
local db = {} 

Hit.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end

	--Se l'attributto stunned è true allora skippa tutta sta parte
	if char:GetAttribute("IsStunned") == true then 
		return 
	end

	
	--Azione di debounce
	if db[char] then return end
	db[char] = true

	--Se passano 0.5 secondi senza che succede niente debounce è su false
	task.delay(0.5, function()
		db[char] = false
	end)

	local hrp = char:WaitForChild("HumanoidRootPart", 3)
	if not hrp then return end

	local Hitbox = Instance.new("Part")
	Hitbox.Size = Vector3.new(5,5,5)
	Hitbox.Color = Color3.new(0.737255, 0.0588235, 0.0588235)
	Hitbox.Transparency = 0.75
	Hitbox.Anchored = true
	Hitbox.CanCollide = false
	Hitbox.CFrame = hrp.CFrame * CFrame.new(0, 0, -4)
	Hitbox.Parent = workspace

	--Riporta le persone colpite
	local giaColpito = {}

	Hitbox.Touched:Connect(function(hit)
		local Charnem = hit.Parent
		if not Charnem then return end
		if Charnem == char then return end

		local Humnem = Charnem:FindFirstChild("Humanoid")
		if not Humnem then return end
		--Se il charnem (il nemico) è gia stato colpito allora ignora
		if giaColpito[Charnem] then return end 
		
		giaColpito[Charnem] = true

		--setta che il charnem è stunned ( dico lattrbuto setta to true)
		Charnem:SetAttribute("IsStunned", true)
		Humnem.WalkSpeed = 0
		Humnem.JumpPower = 0


		--Prende il player dal char
		local PlayerWhoGotHit = game.Players:GetPlayerFromCharacter(Charnem)
		--Se abbiamo un player mandiamo il RemoteEvent
		if PlayerWhoGotHit then
			--Con il player hittato, il suo humanoid, e l'attributo se è stunnato
			Stunned:FireClient(PlayerWhoGotHit, Humnem, true)
		end
	
		Humnem:TakeDamage(math.random(9,12))

	
		task.delay(0.8, function()
			if Charnem and Charnem.Parent then
				--Se passano 0.8 senza che succede nulla è settato tutto come prima
				Charnem:SetAttribute("IsStunned", false)
				if Humnem and Humnem.Parent then
					Humnem.WalkSpeed = 16
					Humnem.JumpPower = 50
				end
			end
			
			--Riporta tutto alla normalità anche nel client
			if PlayerWhoGotHit and Humnem and Humnem.Parent then
				Stunned:FireClient(PlayerWhoGotHit, Humnem, false)
			end
		end)
	end)

	game:GetService("Debris"):AddItem(Hitbox, 0.3)
end)
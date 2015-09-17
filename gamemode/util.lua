function AccessorFuncDT(tbl, varname, name)
	tbl["Get" .. name] = function(s) return s.dt and s.dt[varname] end
	tbl["Set" .. name] = function(s, v) if s.dt then s.dt[varname] = v end end
end

function util.SimpleTime(seconds, fmt)
	if not seconds then seconds = 0 end

    local ms = (seconds - math.floor(seconds)) * 100
    seconds = math.floor(seconds)
    local s = seconds % 60
    seconds = (seconds - s) / 60
    local m = seconds % 60

    return string.format(fmt, m, s, ms)
end

function ents.GetByName(name, returnent)
	if returnent then return ents.FindByName(name)[1] end
	physent = ents.FindByName(name)[1]:GetPhysicsObject()
	return physent
end

function team.GetOpposing(teamnum)
	return teamnum == TEAM_RED and TEAM_BLUE or TEAM_RED
end

--[[----------------------------------------------------
	Explosion
----------------------------------------------------]]--

FX_NONE			= 0

-- explosion
FX_EXPLOSION_NOSMOKE	= 1
FX_EXPLOSION_NOSOUND	= 2
FX_EXPLOSION_NOLIGHT	= 4
FX_EXPLOSION_NOEMBERS	= 8


--[[----------------------------------------------------
	Materials
----------------------------------------------------]]--
local fire_cloud = {
	"effects/fire_cloud1",
	"effects/fire_cloud2",
}
local embers = {
	"effects/fire_embers1",
	"effects/fire_embers2",
	"effects/fire_embers3",
}
local flecks = {
	"effects/fleck_cement1",
	"effects/fleck_cement2",
}


--[[----------------------------------------------------
	EasyParticle
----------------------------------------------------]]--
function EasyParticle(emitter, material, pos, velocity, start_size, end_size, start_alpha, end_alpha, color, life, gravity, air_resistance, collision, lighting)
	local particle = emitter:Add( material, pos )

	particle:SetVelocity( velocity )
	particle:SetDieTime( life )
	particle:SetStartSize( start_size )
	particle:SetEndSize( end_size )
	particle:SetStartAlpha( start_alpha )
	particle:SetEndAlpha( end_alpha )
	particle:SetGravity( gravity or Vector( 0, 0, 0 ) )
	particle:SetAirResistance( air_resistance or 0 )
	particle:SetCollide( collision or false )
	particle:SetLighting( lighting or false )
	particle:SetColor( color.r, color.g, color.b )

	return particle
end


--[[----------------------------------------------------
	GetNormalizedColorTintAndLuminosity
----------------------------------------------------]]--
function GetNormalizedColorTintAndLuminosity(color)
	local luminosity = (color.r * 0.3) + (color.g * 0.59) + (color.b * 0.11)

	local tint = color / math.max(color.r, math.max(color.g, color.b))

	return tint, luminosity
end


--[[----------------------------------------------------
	Explosion
----------------------------------------------------]]--
function Explosion(pos, normal, color, flags)
	local i

	-- get world lighting
	local light_color = render.GetLightColor(pos + normal * 32)
	local tint, luminosity = GetNormalizedColorTintAndLuminosity(light_color)

	-- scale luminosity
	luminosity = luminosity * 255

	-- sound
	if flags and FX_EXPLOSION_NOSOUND == 0 then
		WorldSound("BaseExplosionEffect.Sound", pos, 100, 200)
	end

	-- light
	if flags and FX_EXPLOSION_NOLIGHT == 0 then
		local dynlight = DynamicLight(0)
		dynlight.Pos = pos
		dynlight.Size = 255
		dynlight.Decay = 200
		dynlight.R = color.r
		dynlight.G = color.g
		dynlight.B = color.b
		dynlight.Brightness = 3
		dynlight.DieTime = CurTime() + 0.1
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(64, 128)

	-- smoke
	if flags and FX_EXPLOSION_NOSMOKE == 0 then
		-- stage 1
		for i = 1, 4 do
			local color = math.Rand(luminosity * 0.25, luminosity * 0.5)

			local velocity = (VectorRand() + normal * math.Rand(1, 6)):Normalize()
			local force = velocity * math.Rand(1, 750) * math.abs(normal:DotProduct(velocity))

			local particle = EasyParticle(
				emitter,
				"particles/smokey",
				pos,
				force,
				72, 144,
				128, 0,
				Color(light_color.r * color, light_color.g * color, light_color.b * color),
				math.Rand(2, 3),
				nil,
				500,
				nil,
				nil
			)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-2, 2))
		end

		-- stage 2
		for i = 1, 4 do
			local ofs = pos + VectorRand() * math.Rand(-16, 16)

			local color = math.Rand(luminosity * 0.25, luminosity * 0.5)

			local velocity = (VectorRand() + normal * math.Rand(1, 6)):Normalize()
			local force = velocity * math.Rand(1, 2000) * math.abs(normal:DotProduct(velocity))

			local particle = EasyParticle(
				emitter,
				"particles/smokey",
				ofs,
				force,
				math.Rand( 32, 64 ), math.Rand( 64, 128 ),
				math.Rand( 64, 128 ), 0,
				Color( light_color.r * color, light_color.g * color, light_color.b * color ),
				math.Rand( 0.5, 1 ),
				nil,
				500,
				nil,
				nil
			)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-8, 8))
		end

		-- shockwave
		for i = 1, 32 do
			local angle = (360 / 32) * i

			-- calculate direction
			local dir = normal:Angle():Right():Angle()
			dir:RotateAroundAxis(normal, angle)
			dir = dir:Forward() + VectorRand() * 0.15

			local ofs = pos + VectorRand() * math.Rand(-16, 16)
			local color = math.Rand(luminosity * 0.25, luminosity * 0.5)
			local force = dir * math.Rand(500, 2000)

			local particle = EasyParticle(
				emitter,
				"particles/smokey",
				ofs,
				force,
				72, 144,
				math.Rand(16, 32), 0,
				Color(light_color.r * color, light_color.g * color, light_color.b * color),
				math.Rand(0.5, 1),
				nil,
				500,
				nil,
				nil
			)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-8, 8))
		end
	end

	-- embers
	if flags and FX_EXPLOSION_NOEMBERS == 0 then
		for i = 1, 32 do
			local ofs = pos + VectorRand() * math.Rand(-32, 32)

			local velocity = (VectorRand() + normal * math.Rand(1, 6)):Normalize()
			local force = velocity * math.Rand(1, 1000) * math.abs(normal:DotProduct(velocity))

			local particle = EasyParticle(
				emitter,
				table.Random(embers),
				ofs,
				force,
				1, 1,
				255, 0,
				color,
				math.Rand(1, 3),
				Vector(0, 0, -600),
				500,
				true,
				nil
			)

			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-32, 32))
			particle:SetBounce(0.2)
		end
	end

	-- fireballs
	for i = 1, 32 do
		local ofs = pos + VectorRand() * math.Rand(-48, 48)

		local size = math.Rand(16, 48)
		local velocity = (VectorRand() + normal * math.Rand(1, 6)):GetNormal()
		local force = velocity * math.Rand(400, 800) * math.abs(normal:DotProduct(velocity))

		local particle = EasyParticle(
			emitter,
			table.Random(fire_cloud),
			ofs,
			force,
			size, size * 1.5,
			255, 0,
			color,
			math.Rand(0.1, 0.2),
			Vector(0, 0, -600),
			500,
			true,
			nil
		)

		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-32, 32))
		particle:SetBounce(0.2)
	end

	-- flecks
	for i = 1, 32 do
		local ofs = pos + VectorRand() * math.Rand(-32, 32)

		local size = math.Rand(1, 3)
		local velocity = (VectorRand() + normal * math.Rand(1, 6)):GetNormal()
		local force = velocity * math.Rand(1, 1000) * math.abs(normal:DotProduct(velocity))

		local particle = EasyParticle(
			emitter,
			table.Random(flecks),
			ofs,
			force,
			size, size,
			255, 0,
			color,
			math.Rand(0.1, 0.2),
			Vector(0, 0, -600),
			500,
			true,
			true
		)

		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-32, 32))
		particle:SetBounce(0.2)
	end

	emitter:Finish()
end

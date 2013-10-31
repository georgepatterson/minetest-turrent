ARROW_DAMAGE = 2
ARROW_VELOCITY = 2
minetest.register_node("gunz:turret", {
	description = "WAR ROCK",
	tiles = {"default_stone.png"},
	is_ground_content = true,
	groups = {cracky=3, stone=1},
	drop = 'default:cobble',
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_abm({
	nodenames = {"gunz:turret"},
	interval = 5,
	chance = 1,
	action = function(pos, node)
	--pos.y=pos.y+1
	--if minetest.env:get_node(pos).name == "default:dirt_with_grass" then
	local objects = minetest.env:get_objects_inside_radius(pos, 17)
		for _,obj in ipairs(objects) do
			if obj:is_player() then
				local obj_p = obj:getpos()
				local calc = {x=obj_p.x - pos.x,y=obj_p.y+1 - pos.y,z=obj_p.z - pos.z}
				local bullet=minetest.env:add_entity({x=pos.x,y=pos.y,z=pos.z}, "gunz:arrow_entity")
				bullet:setvelocity({x=calc.x * ARROW_VELOCITY,y=calc.y * ARROW_VELOCITY,z=calc.z * ARROW_VELOCITY})
				music_handle=minetest.sound_play("laser", 
					{ pos = pos, gain = 1.0, 
					 max_hear_distance = 24,
					}) 
			end
		end
	end
})

-- The Arrow Entity

THROWING_ARROW_ENTITY={
	physical = false,
	timer=0,
	visual_size = {x=0.5, y=0.5},
	textures = {"bullet.png"},
	lastpos={},
	collisionbox = {-0.17,-0.17,-0.17,0.17,0.17,0.17},
}
-- Arrow_entity.on_step()--> called when arrow is moving
THROWING_ARROW_ENTITY.on_step = function(self, dtime)
	self.timer=self.timer+dtime
	local pos = self.object:getpos()
	local node = minetest.env:get_node(pos)
	if self.timer > 2 then
		self.object:remove()
	end
	-- When arrow is away from player (after 0.2 seconds): Cause damage to mobs and players
	if self.timer>0.2 then
		local objs = minetest.env:get_objects_inside_radius({x=pos.x,y=pos.y,z=pos.z}, 1.5)
		for k, obj in pairs(objs) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp()-ARROW_DAMAGE)
				self.object:remove()
			end
		end
	end

	-- Become item when hitting a node
	if self.lastpos.x~=nil then --If there is no lastpos for some reason
		if node.name ~= "air" and node.name ~= "gunz:turret" then
			minetest.env:add_item(self.lastpos, 'throwing:arrow')
			self.object:remove()
		end
	end
	self.lastpos={x=pos.x, y=pos.y, z=pos.z} -- Set lastpos-->Item will be added at last pos outside the node
end

minetest.register_entity("gunz:arrow_entity", THROWING_ARROW_ENTITY)
/turf/open/floor
	//NOTE: Floor code has been refactored, many procs were removed and refactored
	//- you should use istype() if you want to find out whether a floor has a certain type
	//- floor_tile is now a path, and not a tile obj
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	base_icon_state = "floor"
	baseturfs = /turf/open/floor/plating

	footstep = FOOTSTEP_FLOOR
	barefootstep = FOOTSTEP_HARD_BAREFOOT
	clawfootstep = FOOTSTEP_HARD_CLAW
	heavyfootstep = FOOTSTEP_GENERIC_HEAVY
	flags_1 = CAN_BE_DIRTY_1 | NO_SCREENTIPS_1

	thermal_conductivity = 0.04
	heat_capacity = 10000
	intact = 1
	tiled_dirt = TRUE

	var/icon_plating = "plating"
	var/broken = 0
	var/burnt = 0
	var/floor_tile = null //tile that this floor drops
	var/list/broken_states
	var/list/burnt_states


/turf/open/floor/Initialize(mapload)

	if (!broken_states)
		broken_states = typelist("broken_states", list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5"))
	else
		broken_states = typelist("broken_states", broken_states)
	burnt_states = typelist("burnt_states", burnt_states)
	if(!broken && broken_states && (icon_state in broken_states))
		broken = TRUE
	if(!burnt && burnt_states && (icon_state in burnt_states))
		burnt = TRUE
	. = ..()
	if(mapload && prob(33))
		MakeDirty()
	if(is_station_level(z))
		GLOB.station_turfs += src

/turf/open/floor/Destroy()
	if(is_station_level(z))
		GLOB.station_turfs -= src
	return ..()

/turf/open/floor/ex_act(severity, target)
	var/shielded = is_shielded()
	..()
	if(severity != 1 && shielded && target != src)
		return
	if(target == src)
		ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		return
	if(target != null)
		severity = 3

	switch(severity)
		if(1)
			ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
		if(2)
			switch(pick(1,2;75,3))
				if(1)
					if(!length(baseturfs) || !ispath(baseturfs[baseturfs.len-1], /turf/open/floor))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
						ReplaceWithLattice()
					else
						ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
				if(2)
					ScrapeAway(2, flags = CHANGETURF_INHERIT_AIR)
				if(3)
					if(prob(80))
						ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
					else
						break_tile()
					hotspot_expose(1000,CELL_VOLUME)
					if(prob(33))
						new /obj/item/stack/sheet/iron(src)
		if(3)
			if (prob(50))
				src.break_tile()
				src.hotspot_expose(1000,CELL_VOLUME)

/turf/open/floor/is_shielded()
	for(var/obj/structure/A in contents)
		if(A.level == 3)
			return 1

/turf/open/floor/blob_act(obj/structure/blob/B)
	return

/turf/open/floor/update_icon()
	. = ..()
	update_visuals()

/turf/open/floor/attack_paw(mob/user)
	return attack_hand(user)

/turf/open/floor/proc/gets_drilled()
	return

/turf/open/floor/proc/break_tile_to_plating()
	var/turf/open/floor/plating/T = make_plating()
	if(!istype(T))
		return
	T.break_tile()

/turf/open/floor/proc/break_tile()
	if(broken)
		return
	icon_state = pick(broken_states)
	broken = 1

/turf/open/floor/burn_tile()
	if(broken || burnt)
		return
	if(burnt_states.len)
		icon_state = pick(burnt_states)
	else
		icon_state = pick(broken_states)
	burnt = 1

/turf/open/floor/proc/make_plating()
	return ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ChangeTurf(path, new_baseturf, flags)
	if(!isfloorturf(src))
		return ..() //fucking turfs switch the fucking src of the fucking running procs
	if(!ispath(path, /turf/open/floor))
		return ..()
	var/old_dir = dir
	var/turf/open/floor/W = ..()
	W.setDir(old_dir)
	W.update_icon()
	return W

/turf/open/floor/attackby(obj/item/C, mob/user, params)
	if(!C || !user)
		return 1
	if(..())
		return 1
	if(intact && istype(C, /obj/item/stack/tile))
		try_replace_tile(C, user, params)
	return 0

/turf/open/floor/crowbar_act(mob/living/user, obj/item/I)
	return intact ? pry_tile(I, user) : FALSE

/turf/open/floor/proc/try_replace_tile(obj/item/stack/tile/T, mob/user, params)
	if(T.turf_type == type)
		return
	var/obj/item/CB = user.is_holding_tool_quality(TOOL_CROWBAR)
	if(!CB)
		return
	var/turf/open/floor/plating/P = pry_tile(CB, user, TRUE)
	if(!istype(P))
		return
	P.attackby(T, user, params)

/turf/open/floor/proc/pry_tile(obj/item/I, mob/user, silent = FALSE)
	if(src.liquids)
		if(src.liquids.liquid_state != LIQUID_STATE_PUDDLE)
			to_chat(user, "<span class ='warning'>The weight of the water stops you from removing the [src].</span>")
			return
	I.play_tool_sound(src, 80)
	return remove_tile(user, silent)

/turf/open/floor/proc/remove_tile(mob/user, silent = FALSE, make_tile = TRUE)
	if(broken || burnt)
		broken = 0
		burnt = 0
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the broken plating.</span>")
	else
		if(user && !silent)
			to_chat(user, "<span class='notice'>You remove the floor tile.</span>")
		if(floor_tile && make_tile)
			new floor_tile(src)
	return make_plating()

/turf/open/floor/singularity_pull(S, current_size)
	..()
	if(current_size == STAGE_THREE)
		if(prob(30))
			if(floor_tile)
				new floor_tile(src)
				make_plating()
	else if(current_size == STAGE_FOUR)
		if(prob(50))
			if(floor_tile)
				new floor_tile(src)
				make_plating()
	else if(current_size >= STAGE_FIVE)
		if(floor_tile)
			if(prob(70))
				new floor_tile(src)
				make_plating()
		else if(prob(50))
			ReplaceWithLattice()

/turf/open/floor/narsie_act(force, ignore_mobs, probability = 20)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/engine/cult, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/ratvar_act(force, ignore_mobs)
	. = ..()
	if(.)
		ChangeTurf(/turf/open/floor/clockwork, flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/acid_melt()
	ScrapeAway(flags = CHANGETURF_INHERIT_AIR)

/turf/open/floor/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_FLOORWALL)
			return list("mode" = RCD_FLOORWALL, "delay" = 20, "cost" = 16)
		if(RCD_LADDER)
			return list("mode" = RCD_LADDER, "delay" = 25, "cost" = 16)
		if(RCD_AIRLOCK)
			if(the_rcd.airlock_glass)
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 20)
			else
				return list("mode" = RCD_AIRLOCK, "delay" = 50, "cost" = 16)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 50, "cost" = 33)
		if(RCD_WINDOWGRILLE)
			return list("mode" = RCD_WINDOWGRILLE, "delay" = 10, "cost" = 4)
		if(RCD_MACHINE)
			return list("mode" = RCD_MACHINE, "delay" = 20, "cost" = 25)
		if(RCD_COMPUTER)
			return list("mode" = RCD_COMPUTER, "delay" = 20, "cost" = 25)
		if(RCD_FURNISHING)
			return list("mode" = RCD_FURNISHING, "delay" = the_rcd.furnish_delay, "cost" = the_rcd.furnish_cost)
	return FALSE

/turf/open/floor/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_FLOORWALL)
			to_chat(user, "<span class='notice'>You build a wall.</span>")
			PlaceOnTop(/turf/closed/wall)
			return TRUE
		if(RCD_LADDER)
			to_chat(user, "<span class='notice'>You build a ladder.</span>")
			var/obj/structure/ladder/Ladder = new(src)
			Ladder.anchored = TRUE
			return TRUE
		if(RCD_AIRLOCK)
			if(locate(/obj/machinery/door) in src)
				return FALSE
			if(ispath(the_rcd.airlock_type, /obj/machinery/door/window))
				to_chat(user, "<span class='notice'>You build a windoor.</span>")
				var/obj/machinery/door/window/new_window = new the_rcd.airlock_type(src, user.dir, the_rcd.airlock_electronics?.unres_sides)
				if(the_rcd.airlock_electronics)
					new_window.name = the_rcd.airlock_electronics.passed_name || initial(new_window.name)
					if(the_rcd.airlock_electronics.one_access)
						new_window.req_one_access = the_rcd.airlock_electronics.accesses.Copy()
					else
						new_window.req_access = the_rcd.airlock_electronics.accesses.Copy()
				new_window.autoclose = TRUE
				new_window.update_icon()
				return TRUE
			to_chat(user, "<span class='notice'>You build an airlock.</span>")
			var/obj/machinery/door/airlock/new_airlock = new the_rcd.airlock_type(src)
			new_airlock.electronics = new /obj/item/electronics/airlock(new_airlock)
			if(the_rcd.airlock_electronics)
				new_airlock.electronics.accesses = the_rcd.airlock_electronics.accesses.Copy()
				new_airlock.electronics.one_access = the_rcd.airlock_electronics.one_access
				new_airlock.electronics.unres_sides = the_rcd.airlock_electronics.unres_sides
				new_airlock.electronics.passed_name = the_rcd.airlock_electronics.passed_name
				new_airlock.electronics.passed_cycle_id = the_rcd.airlock_electronics.passed_cycle_id
			if(new_airlock.electronics.one_access)
				new_airlock.req_one_access = new_airlock.electronics.accesses
			else
				new_airlock.req_access = new_airlock.electronics.accesses
			if(new_airlock.electronics.unres_sides)
				new_airlock.unres_sides = new_airlock.electronics.unres_sides
			if(new_airlock.electronics.passed_name)
				new_airlock.name = sanitize(new_airlock.electronics.passed_name)
			if(new_airlock.electronics.passed_cycle_id)
				new_airlock.closeOtherId = new_airlock.electronics.passed_cycle_id
				new_airlock.update_other_id()
			new_airlock.autoclose = TRUE
			new_airlock.update_icon()
			return TRUE
		if(RCD_DECONSTRUCT)
			if(ScrapeAway(flags = CHANGETURF_INHERIT_AIR) == src)
				return FALSE
			to_chat(user, "<span class='notice'>You deconstruct [src].</span>")
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/grille) in src)
				return FALSE
			to_chat(user, "<span class='notice'>You construct the grille.</span>")
			var/obj/structure/grille/new_grille = new(src)
			new_grille.anchored = TRUE
			return TRUE
		if(RCD_MACHINE)
			if(locate(/obj/structure/frame/machine) in src)
				return FALSE
			var/obj/structure/frame/machine/new_machine = new(src)
			new_machine.state = 2
			new_machine.icon_state = "box_1"
			new_machine.anchored = TRUE
			return TRUE
		if(RCD_COMPUTER)
			if(locate(/obj/structure/frame/computer) in src)
				return FALSE
			var/obj/structure/frame/computer/new_computer = new(src)
			new_computer.anchored = TRUE
			new_computer.state = 1
			new_computer.setDir(the_rcd.computer_dir)
			return TRUE
		if(RCD_FURNISHING)
			if(locate(the_rcd.furnish_type) in src)
				return FALSE
			var/atom/new_furnish = new the_rcd.furnish_type(src)
			new_furnish.setDir(user.dir)
			return TRUE

	return FALSE

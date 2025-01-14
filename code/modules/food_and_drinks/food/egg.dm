
////////////////////////////////////////////EGGS////////////////////////////////////////////

/obj/item/food/chocolateegg
	name = "chocolate egg"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolateegg"
	w_class = WEIGHT_CLASS_TINY
	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/cocoa = 2, /datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("chocolate" = 4, "sweetness" = 1)
	foodtypes = JUNKFOOD | SUGAR

/obj/item/food/egg
	name = "egg"
	desc = "An egg!"
	icon_state = "egg"
	food_reagents = list(/datum/reagent/consumable/eggyolk = 5)
	microwaved_type = /obj/item/food/boiledegg
	foodtypes = MEAT | RAW
	w_class = WEIGHT_CLASS_TINY
	var/static/chick_count = 0 //I copied this from the chicken_count (note the "en" in there) variable from chicken code.
	ant_attracting = FALSE
	decomp_type = /obj/item/food/egg/rotten
	decomp_req_handle = TRUE //so laid eggs can actually become chickens

/obj/item/food/egg/rotten
	food_reagents = list(/datum/reagent/consumable/eggrot = 10)
	microwaved_type = /obj/item/food/boiledegg/rotten
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/egg/gland
	desc = "An egg! It looks weird..."

/obj/item/food/egg/gland/Initialize()
	. = ..()
	reagents.add_reagent(get_random_reagent_id(), 15)

	var/color = mix_color_from_reagents(reagents.reagent_list)
	add_atom_colour(color, FIXED_COLOUR_PRIORITY)

/obj/item/food/egg/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		var/turf/T = get_turf(hit_atom)
		new /obj/effect/decal/cleanable/food/egg_smudge(T)
		if(prob(13)) //Roughly a 1/8 (12.5%) chance to make a chick, as in Minecraft. I decided not to include the chances for the creation of multiple chicks from the impact of one egg, since that'd probably require nested prob()s or something (and people might think that it was a bug, anyway).
			if(chick_count < 5) //Chicken code uses this MAX_CHICKENS variable, so I figured that I'd use it again here. Even this check and the check in chicken code both use the MAX_CHICKENS variable, they use independent counter variables and thus are independent of each other.
				new /mob/living/simple_animal/chick(T)
				chick_count++
		reagents.reaction(hit_atom, TOUCH)
		qdel(src)

/obj/item/food/egg/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/C = W
		var/clr = C.crayon_color

		if(!(clr in list("blue", "green", "mime", "orange", "purple", "rainbow", "red", "yellow")))
			to_chat(usr, "<span class='notice'>[src] refuses to take on this colour!</span>")
			return

		to_chat(usr, "<span class='notice'>You colour [src] with [W].</span>")
		icon_state = "egg-[clr]"
	else if(istype(W, /obj/item/stamp/clown))
		var/clowntype = pick("grock", "grimaldi", "rainbow", "chaos", "joker", "sexy", "standard", "bobble", "krusty", "bozo", "pennywise", "ronald", "jacobs", "kelly", "popov", "cluwne")
		icon_state = "egg-clown-[clowntype]"
		desc = "An egg that has been decorated with the grotesque, robustable likeness of a clown's face. "
		to_chat(usr, "<span class='notice'>You stamp [src] with [W], creating an artistic and not remotely horrifying likeness of clown makeup.</span>")

	else if(is_reagent_container(W))
		var/obj/item/reagent_containers/dunk_test_container = W
		if(dunk_test_container.is_drainable() && dunk_test_container.reagents.has_reagent(/datum/reagent/water))
			to_chat(user, span_notice("You check if [src] is rotten."))
			if(istype(src, /obj/item/food/egg/rotten))
				to_chat(user, span_warning("[src] floats in the [dunk_test_container]!"))
			else
				to_chat(user, span_notice("[src] sinks into the [dunk_test_container]!"))
	else
		..()

/obj/item/food/egg/blue
	icon_state = "egg-blue"

/obj/item/food/egg/green
	icon_state = "egg-green"

/obj/item/food/egg/mime
	icon_state = "egg-mime"

/obj/item/food/egg/orange
	icon_state = "egg-orange"

/obj/item/food/egg/purple
	icon_state = "egg-purple"

/obj/item/food/egg/rainbow
	icon_state = "egg-rainbow"

/obj/item/food/egg/red
	icon_state = "egg-red"

/obj/item/food/egg/yellow
	icon_state = "egg-yellow"

/obj/item/food/friedegg
	name = "fried egg"
	desc = "A fried egg, with a touch of salt and pepper."
	icon_state = "friedegg"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	w_class = WEIGHT_CLASS_TINY
	bite_consumption = 1
	tastes = list("egg" = 4, "salt" = 1, "pepper" = 1)
	foodtypes = MEAT | FRIED | BREAKFAST
	food_buffs = STATUS_EFFECT_FOOD_STAM_TINY

/obj/item/food/boiledegg
	name = "boiled egg"
	desc = "A hard boiled egg."
	icon_state = "egg"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 1)
	tastes = list("egg" = 1)
	w_class = WEIGHT_CLASS_TINY
	foodtypes = MEAT | BREAKFAST
	food_buffs = STATUS_EFFECT_FOOD_STAM_TINY
	ant_attracting = FALSE
	decomp_type = /obj/item/food/boiledegg/rotten

/obj/item/food/boiledegg/rotten
	food_reagents = list(/datum/reagent/consumable/eggrot = 10)
	tastes = list("rotten egg" = 1)
	w_class = WEIGHT_CLASS_TINY
	foodtypes = GROSS
	preserved_food = TRUE

/obj/item/food/omelette	//FUCK THIS
	name = "omelette du fromage"
	desc = "That's all you can say!"
	icon_state = "omelette"

	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 3)
	bite_consumption = 1
	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("egg" = 1, "cheese" = 1)
	foodtypes = MEAT | BREAKFAST | DAIRY
	food_buffs = STATUS_EFFECT_FOOD_STAM_MEDIUM

/obj/item/food/omelette/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/kitchen/fork))
		var/obj/item/kitchen/fork/F = W
		if(F.forkload)
			to_chat(user, "<span class='warning'>You already have omelette on your fork!</span>")
		else
			F.icon_state = "forkloaded"
			user.visible_message("<span class='notice'>[user] takes a piece of omelette with [user.p_their()] fork!</span>", \
				"<span class='notice'>You take a piece of omelette with your fork.</span>")

			var/datum/reagent/R = pick(reagents.reagent_list)
			reagents.remove_reagent(R.type, 1)
			F.forkload = R
			if(reagents.total_volume <= 0)
				qdel(src)
		return
	..()

/obj/item/food/benedict
	name = "eggs benedict"
	desc = "There is only one egg on this, how rude."
	icon_state = "benedict"
	food_reagents = list(/datum/reagent/consumable/nutriment/vitamin = 6, /datum/reagent/consumable/nutriment = 3)

	w_class = WEIGHT_CLASS_NORMAL
	tastes = list("egg" = 1, "bacon" = 1, "bun" = 1)
	foodtypes = MEAT | BREAKFAST | GRAIN
	food_buffs = STATUS_EFFECT_STAM_REGEN_MEDIUM

//A beast that fire freezing blasts.
/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "A territorial beast, covered in a thick shell that absorbs energy. Its stare causes victims to freeze from the inside."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	move_to_delay = 20
	projectiletype = /obj/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_time = 30
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attack_verb_continuous = "bites into"
	attack_verb_simple = "bite into"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	aggro_vision_range = 9
	turns_per_move = 5
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER})
	var/lava_drinker = TRUE
	var/warmed_up = FALSE

/obj/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = ENERGY
	temperature = -50 // Cools you down! per hit!

/obj/projectile/temp/basilisk/heated
	name = "energy blast"
	icon_state= "chronobolt"
	damage = 40
	damage_type = BRUTE
	nodamage = FALSE
	temperature = 0


/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		var/atom/target_from = GET_TARGETS_FROM(src)
		if(isliving(target) && !target.Adjacent(target_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity, target)
	switch(severity)
		if(EXPLODE_DEVASTATE)
			gib()
		if(EXPLODE_HEAVY)
			adjustBruteLoss(140)
		if(EXPLODE_LIGHT)
			adjustBruteLoss(110)

/mob/living/simple_animal/hostile/asteroid/basilisk/AttackingTarget()
	. = ..()
	if(lava_drinker && !warmed_up && istype(target, /turf/open/lava))
		visible_message(span_warning("[src] begins to drink from [target]..."))
		if(do_after(src, 70, target = target))
			visible_message(span_warning("[src] begins to fire up!"))
			fully_heal()
			icon_state = "Basilisk_alert"
			set_varspeed(0)
			warmed_up = TRUE
			projectiletype = /obj/projectile/temp/basilisk/heated
			addtimer(CALLBACK(src, .proc/cool_down), 3000)

/mob/living/simple_animal/hostile/asteroid/basilisk/proc/cool_down()
	visible_message(span_warning("[src] appears to be cooling down..."))
	if(stat != DEAD)
		icon_state = "Basilisk"
	set_varspeed(3)
	warmed_up = FALSE
	projectiletype = /obj/projectile/temp/basilisk

//Watcher
/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "A levitating, eye-like creature held aloft by winglike formations of sinew. A sharp spine of crystal protrudes from its body."
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	health_doll_icon = "watcher"
	pixel_x = -10
	base_pixel_x = -10
	throw_message = "bounces harmlessly off of"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attack_verb_continuous = "impales"
	attack_verb_simple = "impale"
	combat_mode = TRUE
	speak_emote = list("telepathically cries")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = null // doesn't bite unlike the parent type.
	stat_attack = HARD_CRIT
	robust_searching = 1
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	gold_core_spawnable = NO_SPAWN
	loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)
	lava_drinker = FALSE
	search_objects = 1
	wanted_objects = list(/obj/item/pen/survival, /obj/item/stack/ore/diamond)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/Initialize()
	. = ..()
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		consume_bait()

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/proc/consume_bait()
	for(var/obj/potential_consumption in view(1, src))
		if(istype(potential_consumption, /obj/item/stack/ore/diamond))
			qdel(potential_consumption)
			visible_message(span_notice("[src] consumes [potential_consumption], and it disappears! ...At least, you think."))
		else if(istype(potential_consumption, /obj/item/pen/survival))
			qdel(potential_consumption)
			visible_message(span_notice("[src] examines [potential_consumption] closer, and telekinetically shatters the pen."))

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random/Initialize()
	. = ..()
	if(prob(1))
		if(prob(75))
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing(loc)
		else
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing
	name = "magmawing watcher"
	desc = "When raised very close to lava, some watchers adapt to the extreme heat and use lava as both a weapon and wings."
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_aggro = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_system = MOVABLE_LIGHT
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA
	projectiletype = /obj/projectile/temp/basilisk/magmawing
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_mod = 60

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing
	name = "icewing watcher"
	desc = "Very rarely, some watchers will eke out an existence far from heat sources. In the absence of warmth, they become icy and fragile but fire much stronger freezing blasts."
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_aggro = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectiletype = /obj/projectile/temp/basilisk/icewing
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_mod = 30

/obj/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	icon_state = "lava"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	temperature = 200 // Heats you up! per hit!

/obj/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if (istype(L))
			L.adjust_fire_stacks(0.1)
			L.IgniteMob()

/obj/projectile/temp/basilisk/icewing
	damage = 5
	damage_type = BURN
	nodamage = FALSE

/obj/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE


/mob/living/simple_animal/hostile/asteroid/slugrocket
	name = "slugrocket"
	desc = "A slugrocket."
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "cyberslug"
	icon_living = "cyberslug"
	icon_aggro = "cyberslug"
	icon_dead = "cyberslug"
	icon_gib = "syndicate_gib"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	move_to_delay = 70
	projectiletype = /obj/projectile/beam/laser
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "targets"
	ranged_cooldown_time = 70
	throw_message = "does nothing against the hard shell of"
	vision_range = 5
	speed = 1
	maxHealth = 500
	health = 500
	harm_intent_damage = 20
	obj_damage = 60
	melee_damage_lower = 20
	melee_damage_upper = 20
	attack_verb_continuous = "bites into"
	attack_verb_simple = "bite into"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	aggro_vision_range = 9
	turns_per_move = 10
	var/artillery_ready = TRUE
	var/arming = FALSE
	var/timerid
	var/current_ammo_type = /obj/structure/closet/supplypod/acidpod,
	var/ammo_list = list(/obj/structure/closet/supplypod/missilepod,
						 /obj/structure/closet/supplypod/shrapnelpod,
						 /obj/structure/closet/supplypod/acidpod)
/obj/structure/closet/crate/slugga

/obj/structure/closet/crate/slugga/open(mob/living/user, force = FALSE)
	. = ..()
	new /mob/living/simple_animal/hostile/asteroid/slugrocket (get_turf(src))

/mob/living/simple_animal/hostile/asteroid/slugrocket/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target))
			try_fire_artillery(target)


/mob/living/simple_animal/hostile/asteroid/slugrocket/proc/rearm_artillery()
	if(arming)
		return
	visible_message(span_warning("[src] is rearming the artillery rockets"))
	timerid = addtimer(CALLBACK(src, .proc/ready_arty), 5 SECONDS, TIMER_STOPPABLE | TIMER_LOOP )
	current_ammo_type = pick(ammo_list)
	arming = TRUE

/mob/living/simple_animal/hostile/asteroid/slugrocket/proc/ready_arty()
	artillery_ready = TRUE
	arming = FALSE

/mob/living/simple_animal/hostile/asteroid/slugrocket/proc/fire_artillery(target)
	new /obj/effect/pod_landingzone(get_turf(target), current_ammo_type, 50)
	artillery_ready = FALSE
	deltimer(timerid)
	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(0, src)
	smoke.start()


/mob/living/simple_animal/hostile/asteroid/slugrocket/proc/try_fire_artillery(mob/living/target)
	if(!artillery_ready)
		rearm_artillery()
		return
	fire_artillery(target)

/obj/structure/closet/supplypod/missilepod
	effectMissile = TRUE
	damage = 50
	explosionSize = list(0,0,3,4)
	style = STYLE_MISSILE

/obj/structure/closet/supplypod/shrapnelpod
	effectMissile = TRUE
	effectShrapnel = TRUE
	style = STYLE_MISSILE

/obj/structure/closet/supplypod/acidpod
	effectShrapnel = TRUE
	effectMissile = TRUE
	shrapnel_type = /obj/projectile/acid
	shrapnel_magnitude = 1
	style = STYLE_RED_MISSILE


/obj/projectile/acid
	name = "acid bolt"
	icon_state = "neurotoxin"
	damage = 5
	damage_type = BURN
	nodamage = TRUE
	flag = ENERGY
	impact_effect_type = /obj/effect/temp_visual/impact_effect/neurotoxin

/obj/projectile/acid/Initialize(mapload, param_color)
	. = ..()
	create_reagents(500, NO_REACT)
	reagents.add_reagent(/datum/reagent/toxin/acid/fluacid, 500)

/obj/projectile/acid/on_hit(atom/target, blocked = FALSE)
	..()
	var/datum/effect_system/smoke_spread/chem/smoke_machine/s = new
	s.set_up(reagents, 1, 24, loc)
	s.start()
	return BULLET_ACT_HIT

/obj/structure/closet/crate/bobba

/obj/structure/closet/crate/bobba/open(mob/living/user, force = FALSE)
	. = ..()
	new /mob/living/simple_animal/hostile/asteroid/bobbyworm (get_turf(src))


/mob/living/simple_animal/hostile/asteroid/bobbyworm
	name = "bobbyworm"
	desc = "A bobbyworm."
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "bobbitworm"
	icon_living = "bobbitworm"
	icon_aggro = "bobbitworm"
	icon_dead = "bobbitworm"
	icon_gib = "bobbitworm"
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
	move_to_delay = 0
	projectiletype = /obj/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "stares"
	ranged_cooldown_time = 30
	throw_message = "does nothing against the hard shell of"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 25
	obj_damage = 20
	melee_damage_lower = 25
	melee_damage_upper = 25
	attack_verb_continuous = "bites into"
	attack_verb_simple = "bite into"
	speak_emote = list("chitters")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	attack_vis_effect = ATTACK_EFFECT_BITE
	aggro_vision_range = 5
	turns_per_move = 1
	var/is_underwater = FALSE

/mob/living/simple_animal/hostile/asteroid/bobbyworm/proc/go_down()
	icon_state = "bobbitworm_underwater"
	icon_living = "bobbitworm_underwater"
	icon_aggro = "bobbitworm_underwater"
	icon_dead = "bobbitworm_underwater"
	icon_gib = "bobbitworm_underwater"
	ranged = 0
	is_underwater = TRUE
	move_to_delay = 5


/mob/living/simple_animal/hostile/asteroid/bobbyworm/proc/go_up()
	icon_state = "bobbitworm"
	icon_living = "bobbitworm"
	icon_aggro = "bobbitworm"
	icon_dead = "bobbitworm"
	icon_gib = "bobbitworm"
	ranged = 1
	is_underwater = FALSE
	move_to_delay = 0

/mob/living/simple_animal/hostile/asteroid/bobbyworm/GiveTarget(new_target)
	if(is_underwater)
		return
	..()


/mob/living/simple_animal/hostile/asteroid/bobbyworm/Life()
	if(prob(20))
		if(is_underwater)
			go_up()
		else
			go_down()
	var/x = get_turf(src)
	if(!istype(x, /turf/open/acid/smooth))
		gib()

/mob/living/simple_animal/hostile/asteroid/bobbyworm/Move(x, anydir)
	if(istype(x, /turf/open/acid/smooth))
		return..()
extends CharacterBody2D
@onready var gravity = 2000
@onready var jump_power = -1000
@onready var walk = 350
@onready var run = 700
@onready var dash_power = 3500
@onready var healthregn = 5
@onready var health = 100
@onready var knockback = Vector2(200,-300)
@onready var cursed_energy = 100
@onready var dash_charm = false
@onready var DASHCHECK = $PIVOT/DASHCHECK
@onready var DASHCHECK2 =$PIVOT/DASHCHECK2
@onready var DASHCHECK3 =$PIVOT/DASHCHECK3
@onready var cam = $"../Came(1152_0, 648_0)"
var injured_y = false
var injured = false
var shaking = false
var can_get_hit = true
var GRAVITY : float
var was_on_floor = false
var was_running = false
var double_jump = true
var can_dash = true
var lastdir = 1
var dir = 0
var movement_locked = false
var paralysed = false
var move_s = move_stat.normal
var status_s = status_stat.normal
var is_crawling = false
var was_on_wall = false
var just_on_wall = false
var Is_on_wall
var Is_on_wall_only
var Get_wall_normal
enum move_stat {normal,running,dashing}
enum status_stat {died,hurt,healing,preheal,injured,normal}
enum combat_stat {healing,moraba3,r2,l2}
func tween(object : Object , property : NodePath , end : Variant , dur : float):
	create_tween().tween_property(object,property,end,dur)
func tween_ignore_time(object : Object , property : NodePath , end : Variant , dur : float):
	var twen = create_tween()
	twen.set.ignore_time_scale(true)
	twen.tween_property(object,property,end,dur)
func _physics_process(delta: float) -> void:

		#==========MY FUNCTIONS==========

#region =====@IS ON WALL/IS ON WALL ONLY=====
	Is_on_wall = test_move(global_transform,Vector2(0.2,0)) or test_move(global_transform,Vector2(-0.2,0))
	Is_on_wall_only = Is_on_wall and not is_on_floor()
																														#endregion
#region =====@GET WALL NORMAL=====
	if test_move(global_transform,Vector2(0.2,0)):
		Get_wall_normal = 1
	elif test_move(global_transform,Vector2(-0.2,0)):
		Get_wall_normal = -1
	else:
		Get_wall_normal = 0
	if test_move(global_transform,Vector2(0.2,0)) and test_move(global_transform,Vector2(-0.2,0)):
		Get_wall_normal = 0
																														#endregion

		#==========INPUT/DIR==========

#region =====DIR/LASTDIR/PIVOT DIR=====
	if movement_locked or paralysed:
		if is_on_floor():
			dir = 0
	else:
		dir = Input.get_axis("ui_left","ui_right")
	if dir != 0:
		lastdir = dir
	$PIVOT.scale.x = -lastdir
																													#endregion
	var jump_normal = Input.is_action_just_pressed("ui_up")
	var run_pressed = Input.is_action_pressed("run") and not injured and dir != 0 and not is_crawling
	var jump_run = run_pressed and jump_normal
	var dash_normal = Input.is_action_just_pressed("dash") and not is_crawling
	var dash_wall = Input.is_action_just_pressed("dash") and is_crawling
	var jump_dir0_wall = jump_normal and is_crawling and dir == 0
	var jump_dir_sur_wall = jump_normal and is_crawling and dir == Get_wall_normal
	var jump_dir_contre_wall = jump_normal and is_crawling and -dir == Get_wall_normal
	var is_healing = Input.is_action_pressed("ui_down") and is_on_floor() and velocity == Vector2.ZERO

 #==========VARIABLES UPDATES==========

#region =====@KNOCKBACK=====
	knockback = Vector2(-lastdir*200,-350)
																												#endregion ----------
#region =====@CLAMPS : HEALTH=====
	health = clamp(health,0,100)
																												#endregion ----------
#region =====@WAS ON FLOOR ET DOUBLE JUMP=====
	if is_on_floor() or is_crawling:
		double_jump = true
	if is_on_floor():
		was_on_floor = true
	if velocity.y < 0:
		was_on_floor = false
																												#endregion ----------
#region =====@WAS RUNNING=====
	if Input.is_action_pressed("run") and dir !=0 and $run_paralys.is_stopped():
		was_running = true
																												#endregion ----------
#region =====@JUST_NOW_ON_WALL=====
	just_on_wall = Is_on_wall_only and not was_on_wall 
																												#endregion

		#==========STATES/LOCKS==========

#@STATUS AWLAWIYAT = 1 DIED 2 HURT 3 HEALING 4 PREHEAL 5 INJURED 6 NORMAL
#region =====@DASHING=====
	if dash_normal or dash_wall:
		if can_dash:
			move_s = move_stat.dashing
																												#endregion ----------
#region =====@RUNNING=====
	elif run_pressed:
		if is_on_floor() or jump_run:
			move_s = move_stat.running
																												#endregion ----------
#region =====@NORMAL AND WALKING=====
	elif move_s != move_stat.dashing and not jump_run:
		move_s = move_stat.normal
		if status_s != status_stat.injured:
			status_s = status_stat.normal
		if is_crawling :
			move_s = move_stat.normal
																												#endregion ----------
#region =====@DEATHHHHHH=====
	if health == 0:
		status_s = status_stat.died
		paralysed = true
		get_tree().reload_current_scene()
																												#endregion ----------
#region =====@HEALING=====
	if health < 100 and cursed_energy != 0:
		if is_healing and $healtimer.is_stopped():
			if status_s != status_stat.healing:
				status_s = status_stat.preheal
			$healtimer.start()
		if Input.is_action_just_released("ui_down") and not $healtimer.is_stopped():
			#reverse preheal aw ymkn anoher stat
			$healtimer.stop()
																												#endregion ----------
#region =====@INJURED=====
	if 2400 <= velocity.y :
		injured_y = true
	if injured_y and is_on_floor():
		injured_y = false
		injured = true
		health -= 20
		move_s = move_stat.normal
	if injured and status_s != status_stat.preheal:
		status_s = status_stat.injured
																												#endregion
#region =====@COYOTE: FALLING_JUMP START=====
	if was_on_floor and 0<velocity.y:
		$falling_jump.start()
		was_on_floor = false
																												#endregion ----------
#region =====@RUN PARALYS AND FRENAMAN=====
	if was_running:     
		if not run_pressed and is_on_floor():
			velocity.x = move_toward(velocity.x,0,delta*6500)
			if not movement_locked:
				movement_locked = true
				$run_paralys.start()
																												#endregion ----------
#region =====@PARALYS=====
	if paralysed:
		velocity.x = 0
																												#endregion ----------
#region =====@CRAWLING STAT=====
	is_crawling = Is_on_wall_only and not injured
	if paralysed:
		is_crawling = false
																													#endregion ----------

		#==========GRAVITY/COYOTE AFFECTION TO IT==========

#region =====@GRAVITY=====
	if not is_on_floor() and is_crawling == false and move_s != move_stat.dashing:
		GRAVITY = gravity
		if not $falling_jump.is_stopped():
			GRAVITY *= 0.3
		velocity.y += GRAVITY*delta
																												#endregion ----------

		#==========MOVEMENT==========
	if not movement_locked and not paralysed:

#=====@NORMAL JUMPS=====
		if jump_normal and not injured:
		#region =====FLOOR_JUMPS
			if is_on_floor():
				velocity.y = jump_power
				was_on_floor = false
																												#endregion
		#region =====COYOTE_JUMPS
			elif not $falling_jump.is_stopped():
				velocity.y = jump_power
																													#endregion
		#region =====DOUBLE_JUMPS
			elif double_jump:
				was_on_floor= false 
				velocity.y = jump_power
				double_jump = false
																													#endregion
#region =====@WALL JUMPS=====
		if $walljump_null.is_stopped() and $walljump_contre.is_stopped():
			if jump_dir0_wall :
				velocity.x = -walk*Get_wall_normal
				$walljump_null.start()
			if jump_dir_sur_wall :
				velocity.x = -walk*Get_wall_normal
				$walljump_contre.start()
			if jump_dir_contre_wall :
				velocity.x = walk*dir
																												#endregion
#region =====@RUN JUMP=====
		if jump_run:
			velocity = Vector2(lastdir*run,jump_power)
																												#endregion
#region =====@INJURED JUMP=====
		if jump_normal and injured and is_on_floor():
			@warning_ignore("integer_division")
			velocity.y = jump_power/2
																													#endregion
#region =====@WALK NORMAL=====
		if move_s == move_stat.normal and $walljump_contre.is_stopped() and $walljump_null.is_stopped() and not injured:
			velocity.x = walk*dir
																												#endregion
#region =====@WALK INJURED=====
		if move_s == move_stat.normal and injured :
			velocity.x = walk*dir/2
																												#endregion
#region =====@RUNING=====
		if move_s == move_stat.running and is_on_floor():
			var target_speed = run * dir 
			velocity.x = move_toward(velocity.x, target_speed, delta*13000)
																												#endregion
		if Input.is_action_just_released("ui_up") and velocity.y < 0: #=====@HIGHT JUMP FOR ALL CASES===== 
			velocity.y *= 0.4
		 #==========DEBUGING==========
#region =====@DASH NORMAL AND ITS LOCK=====
		if move_s == move_stat.dashing and can_dash and not injured:
			if can_get_hit:
				DASHCHECK.force_raycast_update()
				DASHCHECK2.force_raycast_update()
				DASHCHECK3.force_raycast_update()
				if DASHCHECK.is_colliding():
					dash_hurt1()
				elif DASHCHECK2.is_colliding():
					dash_hurt2()
				elif DASHCHECK3.is_colliding():
					dash_hurt3()
				else:
					can_dash = false
					velocity.y = 0
					movement_locked = true
					$dashcool.start()
					$dash_dashlock.start()
					if dash_normal:
						velocity.x = dash_power*lastdir
																													#endregion
#region =====@DASH WALL=====
					if dash_wall :
						velocity.x = -dash_power*Get_wall_normal
																													#endregion
#region =====@CRAWLING FREN AND TASFIR Y=====
	if just_on_wall:
		velocity.y = 0
		if move_s == move_stat.dashing and not paralysed:
			movement_locked = false
			move_s = move_stat.normal
	if not movement_locked and not paralysed:
		if is_crawling and not jump_normal and 0 <= velocity.y:
			velocity.y = 10000*delta
																												#endregion

	move_and_slide()        #=====MOVE AND SLIDE=====

		#==========COMBAT AND EFFECTS==========

#region =====@SHAKING=====
	if shaking:
		cam.shake(delta)
																												#endregion
#region =====@FREEZE TIME IF DAMAGED=====
	if not $freeze_time_hurt.is_stopped():
		Engine.time_scale = 0
																												#endregion
#region =====@GET DAMAGED AND DASHING=====
	if move_s == move_stat.dashing:
		DASHCHECK.force_raycast_update()
		DASHCHECK2.force_raycast_update()
		DASHCHECK2.force_raycast_update()
		if can_get_hit:
			if DASHCHECK.is_colliding():
				dash_hurt1()
			elif DASHCHECK2.is_colliding():
				dash_hurt2()
			elif DASHCHECK3.is_colliding():
				dash_hurt3()
																												#endregion

		#==========VARIABLES UPDATES FOR ENDFRAME==========

#region =====@WAS_ON_WALL=====
	was_on_wall = Is_on_wall
																												#endregion

		#==========DEBUGING==========

	#-----DEBUG PRINT
	var debugging = false
	if debugging :
		print( " HEALTH: ",health," GET_WALL_NORMAL: ",Get_wall_normal," IS ON WALL: ",Is_on_wall_only," X: ",velocity.x," Y: ",velocity.y," JUST_ON_WALL: ",just_on_wall," MOVE STAT: ",move_s," MOVEMENT_LOCKED: ",movement_locked)
	#-----CONDITIONS FOR BREAKPOINTS
	if is_crawling and jump_normal:
		pass
																												

		#==========TESTIING==========

	var testing = false
	if testing :
		print (position)
																												

func _on_dashcool_timeout() -> void:
	can_dash = true
@warning_ignore("unused_parameter")
func _on_area_2d_body_entered(body: Node2D) -> void:
	if can_get_hit and move_s != move_stat.dashing:
		health -= $"../enemy".damage 
		if health != 0 :
			status_s = status_stat.hurt
		movement_locked = true
		$run_paralys.stop()
		velocity = knockback
		$freeze_start.start()
		move_s = move_stat.normal
		shaking = true
		can_get_hit = false
		$can_get_hit.start()
		$knockback_lock.start()
func _on_run_paralys_timeout() -> void:
	was_running = false
	movement_locked = false
func _on_healtimer_timeout() -> void:
	if status_s != status_stat.hurt:
		status_s = status_stat.healing
	health += healthregn
	cursed_energy -= 20
	injured = false
func _on_can_get_hit_timeout() -> void:
	can_get_hit = true
func _on_freeze_time_hurt_timeout() -> void:
	Engine.time_scale = 1
func _on_dash_dashlock_timeout() -> void:
	if movement_locked:
		movement_locked = false
		move_s = move_stat.normal
		if not is_crawling:
			velocity.x = walk*dir
func dash_hurt1():
	if not dash_charm:
		var collision_point = DASHCHECK.get_collision_point()
		global_position.x = collision_point.x - (20*lastdir)
		health -= $"../enemy".damage 
		if health != 0 :
			status_s = status_stat.hurt
		movement_locked = true
		$dash_dashlock.stop()
		velocity = knockback
		$freeze_start.start()
		move_s = move_stat.normal
		shaking = true
		can_get_hit = false
		can_dash = false
		$knockback_lock.start()
		$dashcool.start()
		$can_get_hit.start()
func dash_hurt2():
	if not dash_charm:
		var collision_point = DASHCHECK2.get_collision_point()
		global_position.x = collision_point.x - (20*lastdir)
		health -= $"../enemy".damage 
		if health != 0 :
			status_s = status_stat.hurt
		movement_locked = true
		$dash_dashlock.stop()
		velocity = knockback
		$freeze_start.start()
		move_s = move_stat.normal
		shaking = true
		can_get_hit = false
		can_dash = false
		$dashcool.start()
		$can_get_hit.start()
		$knockback_lock.start()
func dash_hurt3():
	if not dash_charm:
		var collision_point = DASHCHECK3.get_collision_point()
		global_position.x = collision_point.x - (20*lastdir)
		health -= $"../enemy".damage 
		if health != 0 :
			status_s = status_stat.hurt
		movement_locked = true
		$dash_dashlock.stop()
		velocity = knockback
		$freeze_start.start()
		move_s = move_stat.normal
		shaking = true
		can_get_hit = false
		can_dash = false
		$dashcool.start()
		$can_get_hit.start()
		$knockback_lock.start()
func _on_freeze_start_timeout() -> void:
	$freeze_time_hurt.start()
func _on_knockback_lock_timeout() -> void:
	movement_locked = false
#MOXKILAT : 0
#IDAFAT FOR DABA : COUNTER DASH

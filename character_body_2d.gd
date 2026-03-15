extends CharacterBody2D
@onready var gravity = 1900
@onready var jump = -1000
@onready var walk = 250
@onready var run = 650
@onready var dash = 12000
@onready var falling_jump = $falling_jump
@onready var maxhealth = 100
@onready var healthregn = 5
@onready var health = maxhealth
var was_running = false
var double_jump = true
var was_on_floor = false
var can_dash = true
var lastdir = 1
var dir 
var mouvement_locked = false
func _physics_process(delta): 
	if Input.is_action_just_pressed("run"):
		was_running = true
	if is_on_floor():
		was_on_floor = true
		falling_jump.stop()
	if was_on_floor and not is_on_floor():
		falling_jump.start()
		was_on_floor = false
	var is_running = Input.is_action_pressed("run")
	if mouvement_locked :
		dir =0
		is_running = false
	else:
		dir = Input.get_axis("ui_left", "ui_right")
	if dir != 0:
		lastdir = dir
		if is_running:
			var target_speed = run * dir
			velocity.x = move_toward(velocity.x, target_speed, delta*13000)
		else:
			velocity.x = walk * dir
	elif is_running == false:
				velocity.x = 0
	if was_running and not mouvement_locked:
		if dir==0 or not is_running:
			velocity.x = move_toward(velocity.x,0,delta*(6500))
			if abs(velocity.x)<10:
				mouvement_locked = true
				$runparalys.start()
	if not is_on_floor():
		var GRAVITY = gravity
		if not falling_jump.is_stopped():
			GRAVITY *= 0.3
		velocity.y += GRAVITY*delta
	elif not Input.is_action_just_pressed("ui_up"):
		velocity.y = 0
		double_jump = true
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = jump
			was_on_floor = false
		elif not falling_jump.is_stopped():
			velocity.y = jump
		elif double_jump:
			was_on_floor=false
			velocity.y = jump
			double_jump = false
	if Input.is_action_just_pressed("dash") and can_dash:
		$dashcool.start()
		velocity.x = dash*lastdir
		can_dash = false
	if health!=maxhealth:
		health = move_toward(health, maxhealth, healthregn*delta)
	move_and_slide()
	print("dir:", dir, " DELTA:", delta, " is_running:", is_running, " X:", velocity.x," Y:", velocity.y)#"HEALTH:", health, " LASTDIR:", lastdir," ON FLOOR:", is_on_floor(),
	 #" TIMER STOPPED:", falling_jump.is_stopped()," CAN DOUBLE JUMP:", double_jump)
func _on_dashcool_timeout() -> void:
	can_dash = true
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy20"):
		health-=20
func _on_runparalys_timeout() -> void:
	was_running= false
	mouvement_locked = false

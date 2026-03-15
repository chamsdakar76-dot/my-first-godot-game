extends Camera2D
@onready var shake_dur = 0.15
@onready var shake_power = 15
@onready var player = $"../player"
var func_ready_finished = false
var dead_zone_x = 130
var dead_zone_y = 230
var shake_timer = 0.15
var shake_position : Vector2
var base_position : Vector2
var offset_speed = 10
var target : Vector2
var lookahead_x = 100
var lookahead_y = 50
func _physics_process(delta: float) -> void:
	if func_ready_finished:
		if player.global_position.x >= global_position.x - dead_zone_x:
			if player.velocity.x != 0:
				global_position.x = player.global_position.x + dead_zone_x
			else:
				global_position.x = lerp(global_position.x,player.global_position.x,offset_speed*delta)
		if player.global_position.x >= global_position.x + dead_zone_x:
			if player.velocity.x != 0:
				global_position.x = player.global_position.x - dead_zone_x
			else:
				global_position.x = lerp(global_position.x,player.global_position.x,offset_speed*delta)
		if player.global_position.y >= global_position.y - dead_zone_y:
			if player.velocity.y != 0:
				global_position.y = player.global_position.y + dead_zone_y
			else:
				global_position.y = lerp(global_position.y,player.global_position.y,offset_speed*delta)
		if player.global_position.y >= global_position.y + dead_zone_y:
			if player.velocity.y != 0:
				global_position.y = player.global_position.y - dead_zone_y
			else:
				global_position.y = lerp(global_position.y,player.global_position.y,offset_speed*delta)
	shake_position = Vector2(randf_range(1,-1),0)*shake_power 
	base_position = player.global_position
func shake (delta):
	shake_timer -= delta
	global_position = shake_position + base_position
	if shake_timer <= 0:
		global_position = base_position
		player.shaking = false
		shake_timer = shake_dur
func _ready() -> void:
	global_position = player.global_position
	func_ready_finished = true

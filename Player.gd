extends KinematicBody2D


onready var raycast_ground = $GroundRay
onready var ani = $AnimationPlayer
onready var stand_shape = $StandingCollisionShape
onready var sprite = $Sprite
const UP = Vector2(0, -1)

export var gravity = 1000
export var acceleration = 2000
export var deacceleration = 2000
export var max_horizontal_speed = 400
export var max_fall_speed = 1000
export var standing_friction = 2000
export var current_friction = 2000
export var jump_height = -700
export var double_jump_height = -400
var slide_friction = 600
var squash_speed = 0.1

var air_jump_pressed : bool = false
var is_double_jumping : bool = false
var can_double_jump : bool = false
var coyote_time : bool = false
var touching_ground : bool = false
var is_jumping : bool = false

var hSpeed = 0
var vSpeed = 0

var motion: Vector2 = Vector2.ZERO

func _check_ground_logic():
	if(touching_ground and !raycast_ground.is_colliding()):
		touching_ground = false
		coyote_time = true
		yield(get_tree().create_timer(0.2), "timeout")
		coyote_time = false
		
	#if(!touching_ground and raycast_ground.is_colliding()):
	touching_ground = raycast_ground.is_colliding()
	if(touching_ground):
		is_jumping = false
		can_double_jump = true
		motion.y = 0
		vSpeed = 0

func _handle_movement(delta):
	# if we're touching a wall, we should stop accelerating, to stop sticking
	if(is_on_wall()):
		hSpeed = 0
		motion.x = 0

	#right
	if(Input.is_action_pressed("ui_right")):
		if(hSpeed < max_horizontal_speed):
			hSpeed += acceleration * delta
			sprite.flip_h = false
			if(touching_ground):
				print("right1")
				ani.play("Run")
		else:
			sprite.flip_h = false
			if(touching_ground):
				print("right2")
				ani.play("Run")
	elif(Input.is_action_pressed("ui_left")):
		if(hSpeed > -max_horizontal_speed):
			hSpeed -= acceleration * delta
			sprite.flip_h = true
			if(touching_ground):
				print("left1")
				ani.play("Run")
		else:
			sprite.flip_h = true
			if(touching_ground):
				print("left2")
				ani.play("Run")
	else:
		if(touching_ground):
			print("idle1")
			ani.play("Idle")
			#else:
			#	if(abs(hSpeed) < 0.2):
			#		ani.stop()
			#		ani.frame = 1
		hSpeed -= min(abs(hSpeed), current_friction * delta) * sign(hSpeed)

func _handle_jumping():
	if(Input.is_action_just_pressed("jump") and coyote_time):
		vSpeed += jump_height
		is_jumping = true
		#can_double_jump = true
	
	if(touching_ground):
		if((Input.is_action_just_pressed("jump") or air_jump_pressed) and !is_jumping):
			vSpeed = jump_height
			is_jumping = true
			touching_ground = false
	else:
		if(vSpeed < 0 and !Input.is_action_pressed("jump") and !is_double_jumping):
			vSpeed = max(vSpeed, jump_height / 2)
		if(!coyote_time and Input.is_action_just_pressed("jump") and can_double_jump):
			vSpeed = double_jump_height
			is_double_jumping = true
			can_double_jump = false
			ani.play("Jump")
	
		#jump animati:on logic
		if(!is_double_jumping and vSpeed < 0):
			ani.play("Jump")
		elif(!is_double_jumping and vSpeed > 0):
			ani.play("Fall")
		elif(is_double_jumping and sprite.frame == 0):
			is_double_jumping = false
	
		if(Input.is_action_just_pressed("jump")):
			air_jump_pressed = true
			yield(get_tree().create_timer(0.1),"timeout")
			air_jump_pressed = false

func _do_physics(delta):
	if(is_on_ceiling()):
		motion.y = 10
		vSpeed = 10
	
	vSpeed += gravity * delta
	if(vSpeed > max_fall_speed):
		vSpeed = max_fall_speed
	
	motion.x = hSpeed
	motion.y = vSpeed
	
	motion = move_and_slide(motion, UP)

func _physics_process(delta):
	_check_ground_logic()
	_handle_input(delta)
	_do_physics(delta)

func _handle_input(delta):
	_handle_movement(delta)
	_handle_jumping()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

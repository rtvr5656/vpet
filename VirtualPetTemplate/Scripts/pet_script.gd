extends Node2D

var grav = 0.05
var force = Vector2.ZERO
var speed = 2

var secure_zone = 10

var can_fall = true
var can_move = true
var movement_type = 1

var moving = false
var falling = false
var movement = 0

@onready var sprite = $petSprite

var max_move_focus = 300
var min_move_focus = 50
var max_rest_time = 5
var min_rest_time = 0
var max_msg_cooldown = 5

var move_focus = 0
var focus = "x"
var rest_time = 0
var action = "idle"
var msg = ["Hello","Hi","test"]
var msg_cooldown = 0

var rng = RandomNumberGenerator.new()



func gravity():
	while can_fall:
		await get_tree().create_timer(0.01).timeout
		if get_window().position.y < DisplayServer.screen_get_size().y - get_window().size.y - secure_zone:
			falling = true
			force.y += grav
		else:
			falling = false

func move():
	while can_move:
		await get_tree().create_timer(0.01).timeout
		if not falling:
			rng.randomize()
			if movement_type == 1:
				
				if move_focus == 0:
					if rest_time == 0:
						focus = "x"
						if rng.randi_range(1,100) == 1:
							moving = true
							var final_speed = rng.randf_range(-speed, speed)
							
							force.x = final_speed
							movement = final_speed
							move_focus = rng.randi_range(min_move_focus, max_move_focus)
							rest_time = rng.randi_range(min_rest_time, max_rest_time)
						else:
							moving = false
					else:
						moving = false
						rest_time -= 1
						await get_tree().create_timer(1.0).timeout
				else:
					moving = true
					if focus == "x":
						force.x = movement
					elif focus == "y":
						force.y = movement
					move_focus -= 1
			
			elif movement_type == 2:
				
				if move_focus == 0:
					if rest_time == 0:
						if rng.randi_range(1,100) == 1:
							moving = true
							var final_speed = rng.randf_range(-speed, speed)
							
							if rng.randi_range(1,2) == 1:
								focus = "x"
								
								force.x = final_speed
								movement = final_speed
								move_focus = rng.randi_range(min_move_focus, max_move_focus)
								rest_time = rng.randi_range(min_rest_time, max_rest_time)
							else:
								focus = "y"
								
								force.y = final_speed
								movement = final_speed
								move_focus = rng.randi_range(min_move_focus, max_move_focus)
								rest_time = rng.randi_range(min_rest_time, max_rest_time)
						else:
							moving = false
					else:
						moving = false
						rest_time -= 1
						await get_tree().create_timer(1.0).timeout
				else:
					moving = true
					if focus == "x":
						force.x = movement
					elif focus == "y":
						force.y = movement
					move_focus -= 1


func cooldown():
	while true:
		await get_tree().create_timer(1.0).timeout
		if msg_cooldown > 0:
			msg_cooldown -= 1


func _ready():
	gravity()
	move()
	cooldown()

func _process(delta):
	if force.x < 0 and force.x > -1:
		force.x = -1
	
	if get_window().position.x >= secure_zone and get_window().position.x < DisplayServer.screen_get_size().x - get_window().size.x - secure_zone and get_window().position.y >= secure_zone and get_window().position.y < DisplayServer.screen_get_size().y - get_window().size.y + secure_zone:
		get_window().position += Vector2i(ceil(force.x), ceil(force.y))
		
	elif get_window().position.x >= DisplayServer.screen_get_size().x - get_window().size.x - secure_zone:
		rng.randomize()
		
		focus == "x"
		movement = -speed
		move_focus = rng.randi_range(min_move_focus, max_move_focus)
		get_window().position += Vector2i(ceil(force.x), ceil(force.y))
		
	elif get_window().position.x < secure_zone:
		rng.randomize()
		
		focus == "x"
		movement = speed
		move_focus = rng.randi_range(min_move_focus, max_move_focus)
		get_window().position += Vector2i(ceil(force.x), ceil(force.y))
		
	elif get_window().position.y >= DisplayServer.screen_get_size().y - get_window().size.y - secure_zone:
		rng.randomize()
		
		focus == "y"
		movement = -speed
		move_focus = rng.randi_range(min_move_focus, max_move_focus)
		get_window().position += Vector2i(ceil(force.x), ceil(force.y))
		
	elif get_window().position.y < secure_zone:
		rng.randomize()
		
		focus == "y"
		movement = speed
		move_focus = rng.randi_range(min_move_focus, max_move_focus)
		get_window().position += Vector2i(ceil(force.x), ceil(force.y))
	
	if !moving and !falling:
		force = Vector2(0,0)
	
	if force.y < 0:
		action = "moving up"
	elif force.y > 0:
		action = "moving down"
	elif force.x < 0:
		action = "moving left"
	elif force.x > 0:
		action = "moving right"
	else:
		action = "idle"
	
	if action == "idle":
		sprite.play("idle")
	elif action == "moving right":
		sprite.play("walking")
		sprite.flip_h = false
	elif action == "moving left":
		sprite.play("walking")
		sprite.flip_h = true
	elif action == "moving down":
		sprite.play("falling")
	elif action == "moving up":
		sprite.play("going_up")
	

func _input(event):
	if event.is_action_pressed("interact"):
		if msg_cooldown == 0:
			msg_cooldown = max_msg_cooldown
			
			$msg.visible = true
			rng.randomize()
			$msg/Background/Text.text = msg[rng.randi_range(0, msg.size()-1)]
			await get_tree().create_timer(2.5).timeout
			$msg.visible = false

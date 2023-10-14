extends Node

var game_running : bool
var game_over : bool
var score
@export var points : int = 1

var scroll
@export var SCROLL_SPEED : int = 4

var screen_size : Vector2i
var ground_height : int

var pipes : Array
@export var PIPE_DELAY : int = 100
@export var PIPE_RANGE : int = 200
@export var pipe_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	new_game()
	
func new_game():
	$GameOverScreen.hide()
	game_running = false
	game_over = false
	pipes.clear()
	get_tree().call_group("pipes", "queue_free")
	
	score = 0
	update_score(score)
	scroll = 0
	generate_pipes()
	$Bird.reset()

func _input(event):
	if game_over == false:
		if Input.is_action_just_pressed("flap"):
			if game_running == false:
				start_game()
			else:
				if $Bird.flying:
					$Bird.flap()
					check_top()
				

func start_game():
	game_running = true
	$Bird.flying = true
	$Bird.flap()
	$PipeTimer.start()
				
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		scroll += SCROLL_SPEED
		
		# Reset scroll
		if scroll >= screen_size.x:
			scroll = 0
		
		# Move ground 
		$Ground.position.x = -scroll
		for pipe in pipes:
			pipe.position.x -= SCROLL_SPEED

func _on_pipe_timer_timeout():
	generate_pipes()

func generate_pipes():
	var pipe = pipe_scene.instantiate()
	pipe.position.x = screen_size.x + PIPE_DELAY
	pipe.position.y = (screen_size.y - ground_height) / 2 + randi_range(-PIPE_RANGE, PIPE_RANGE)
	pipe.hit.connect(bird_hit)
	pipe.passed_pipes.connect(passed_pipes)
	add_child(pipe)
	pipes.append(pipe)

func passed_pipes():
	update_score(points)

func update_score(value):
	score += value
	$ScoreLabel.text = str(score)
	
func check_top():
	if $Bird.position.y < 0:
		$Bird.falling = true
		stop_game()
		
func bird_hit():
	$Bird.falling = true
	stop_game()

func stop_game():
	$PipeTimer.stop()
	$Bird.flying = false
	game_over = true
	game_running = false
	$GameOverScreen.show()

func _on_ground_hit():
	$Bird.falling = false
	stop_game()

func _on_game_over_screen_exit_game():
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_game_over_screen_restart_game():
	new_game()

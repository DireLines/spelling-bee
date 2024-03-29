extends CharacterBody2D

@onready var commonWords = "res://Words/common.txt"
@onready var area_2d = $Area2D
@onready var audio_player = $AudioPlayer
@onready var tts = get_tree().get_root().get_node("Main/TextToSpeechProcess");

var killphrase = ""
var hit_letters = []
var sound: AudioStreamWAV

var speed = 70
var show_unhit_letters = false
var should_speak = true

var player

func initialize():
	player = get_tree().get_root().get_node("Main/Bee")
	var theta = randf() * 2 * PI
	var offset = (Vector2(cos(theta), sin(theta)) * sqrt(randf())).normalized() * 500
	position = player.position + offset
	$Timer.timeout.connect(talk)
	$Timer.wait_time = randf_range(0.7,3)
	area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	var file : FileAccess = FileAccess.open(commonWords, FileAccess.READ)
	var words = file.get_as_text().split("\n")
	var found_good_word = false
	var word = ""
	while !found_good_word:
		word = words[randi_range(0,len(words)-1)]
		if len(word) > 2 and len(word) < 7:
			found_good_word = true
	set_killphrase(word)

func _physics_process(delta):
	if !player:
		return
	var origin = position
	var target = player.position
	var direction = (target - origin).normalized()
	velocity = direction * speed
	move_and_slide()

func set_killphrase(phrase):
	killphrase = phrase.to_upper().replace("\n", "").replace("\r", "")
	hit_letters = []
	for letter in killphrase:
		hit_letters.append(false)
	await tts.set_killphrase_audio(audio_player,phrase)
	refresh_killphrase_display()

func _on_body_entered(body):
	var label = body.get_node_or_null("Letter")
	if label == null:
		return
	var letter = label.text
	var letter_index = get_next_hittable_letter_index()
	if letter_index == -1:
		print("enemy already dead")
		return # all letters hit - enemy already dead
	var needed_letter = killphrase[letter_index]
	if letter == needed_letter:
		hit_letter(letter_index)
		body.queue_free()
	else:
		#make enemy bullet
		body.set_collision_layer_value(2,false)
		body.set_collision_layer_value(4,true)
		#reflect back at source
		body.linear_velocity *= -0.8

func get_next_hittable_letter_index():
	for i in range(len(killphrase)):
		if !hit_letters[i]:
			return i
	return -1 # all letters hit

func hit_letter(index):
	if index < 0 or index >= len(hit_letters):
		return #bad index
	if hit_letters[index]:
		return # letter already hit
	hit_letters[index] = true
	#TODO play bullet sfx and stuff
	refresh_killphrase_display()
	for hit in hit_letters:
		if !hit:
			return # not all letters hit yet
	#TODO play death sfx and stuff
	die()

func die():
	player.score += len(killphrase)
	queue_free()

func refresh_killphrase_display():
	var unhit_color = Color.WHITE
	var hit_color = Color.INDIAN_RED
	if !show_unhit_letters:
		unhit_color = Color.TRANSPARENT
	var colors = []
	for hit in hit_letters:
		if hit:
			colors.append(hit_color)
		else:
			colors.append(unhit_color)
	set_text(killphrase,colors)

func set_text(word: String, colors):
	assert(word.length() == colors.size(), "word length and colors length must match.")
	var text = "[center]"
	for i in range(word.length()):
		var color = colors[i].to_html()
		var ch = word[i]
		text += "[color=%s]%s" % [color, ch]
	get_node("Word").text = text

func talk():
	if should_speak:
		$AnimationPlayer.play("Talk")
		audio_player.play()

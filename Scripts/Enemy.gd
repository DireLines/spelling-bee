extends CharacterBody2D

var speaker_class = preload("res://Scripts/Speaker.cs")
@onready var commonWords = "res://Words/common.txt"
@onready var area_2d = $Area2D
@onready var audio_player = $AudioPlayer

var killphrase = ""
var hit_letters = []
var sound: AudioStreamWAV

func _ready():
	$Timer.timeout.connect(talk)
	$Timer.wait_time = randf_range(1,2)
	area_2d.connect("body_entered", Callable(self, "_on_body_entered"))
	var file : FileAccess = FileAccess.open(commonWords, FileAccess.READ)
	var words = file.get_as_text().split("\n")
	set_killphrase(words[randi_range(0,len(words)-1)])

func set_killphrase(phrase):
	killphrase = phrase.to_upper()
	hit_letters = []
	for letter in killphrase:
		hit_letters.append(false)
	audio_player.stream = speaker_class.GetKillphraseAudio(phrase)
	refresh_killphrase_display()

func _on_body_entered(body):
	var label = body.get_node_or_null("Letter")
	if label != null:
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
			#TODO move body to enemy bullet layer
			body.linear_velocity *= -0.8

#
#func _on_body_exited(body):
	#pass

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
	queue_free()

func refresh_killphrase_display():
	var unhit_color = Color.WHITE
	var hit_color = Color.INDIAN_RED
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
	$AnimationPlayer.play("Talk")
	audio_player.play()

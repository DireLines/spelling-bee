extends Node2D

var mutex: Mutex
var semaphore: Semaphore
var thread: Thread
var exit_thread := false

var audio_player: AudioStreamPlayer2D = null
var killphrase = ""

var speaker_class = preload("res://Scripts/Speaker.cs")

# The thread will start here.
func _init():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	exit_thread = false

	thread = Thread.new()
	thread.start(_thread_function)


func _thread_function():
	while true:
		semaphore.wait() # Wait until posted.

		mutex.lock()
		var should_exit = exit_thread # Protect with Mutex.
		mutex.unlock()

		if should_exit:
			break

		mutex.lock()
		audio_player.stream = speaker_class.GetKillphraseAudio(killphrase)
		#counter += 1 # Increment counter, protect with Mutex.
		mutex.unlock()


func set_killphrase_audio(player: AudioStreamPlayer2D, phrase: String):
	audio_player = player
	killphrase = phrase
	semaphore.post() # Make the thread process.

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	mutex.lock()
	exit_thread = true # Protect with Mutex.
	mutex.unlock()

	# Unblock by posting.
	semaphore.post()

	# Wait until it exits.
	thread.wait_to_finish()

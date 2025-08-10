class_name Balloon extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.

signal on_prev(line_id: String)
signal on_next(prev_line: DialogueLine, new_line: DialogueLine)
#signal on_save()
#signal on_load()
#
#func save():
	#on_save.emit()
#func save():
	#on_load.emit()

## The action to use for advancing the dialogue
@export var next_action: StringName = &"Next"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"Next"

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var history: Array[String] = []

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			# The dialogue has finished so close the balloon
			queue_free()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

var is_skip_button_pressed: bool = false;
var show_buttons = true;

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu
@onready var one_response_menu: DialogueResponsesMenu = %OneResponseMenu
@onready var character_label_container: TextureRect = %CharacterLabelContainer
@onready var back_button: Button = %BackButton
@onready var skip_button: Button = %SkipButton

@onready var text_panels: Control = %TextPanels

@onready var screen_text: DialogueLabel = %ScreenText
@onready var letter_click: AudioStreamPlayer = $LetterClick

var is_skipping: bool:
	get():
		return DialogueManager.is_skipping
	set(value):
		DialogueManager.is_skipping = value

func _ready() -> void:
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action
	if one_response_menu.next_action.is_empty():
		one_response_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)
	dialogue_label.spoke.connect(_spoke)
	screen_text.spoke.connect(_spoke)

func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()

#func _unhandled_input(event: InputEvent) -> void:
	

func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()
	
	if dialogue_line.tags.has("screen"): 
		balloon.show()
		text_panels.hide()
		
		responses_menu.hide()
		responses_menu.responses = dialogue_line.responses
		
		one_response_menu.hide()
		one_response_menu.responses = dialogue_line.responses
		
		screen_text.show();
		screen_text.modulate = Color.WHITE;
		screen_text.dialogue_line = dialogue_line
		
		if not dialogue_line.text.is_empty():
			screen_text.type_out()
			await screen_text.finished_typing
	else:
		if screen_text.visible:
			get_tree().create_tween()\
					.tween_property(screen_text, "modulate", Color.TRANSPARENT, 1)\
					.finished.connect(func (): screen_text.hide())
			
		
		text_panels.show();
		character_label_container.visible = not dialogue_line.character.is_empty()
		character_label.text = tr(dialogue_line.character, "dialogue")

		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.responses = dialogue_line.responses
		
		one_response_menu.hide()
		one_response_menu.responses = dialogue_line.responses
		
		if show_buttons:
			back_button.visible = not history.is_empty()
			
			skip_button.visible = GameState.read_messages.has(dialogue_line.id)
			if not skip_button.visible:
				is_skip_button_pressed = false;
		else:
			back_button.visible = false;
			skip_button.visible = false;
			is_skip_button_pressed = false;
	
		# Show our balloon
		balloon.show()
		will_hide_balloon = false

		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

	# Wait for input
	if dialogue_line.responses.size() > 0:
		balloon.focus_mode = Control.FOCUS_NONE
		if dialogue_line.responses.size() > 1:
			responses_menu.show()
		else:
			one_response_menu.show();
	elif dialogue_line.time != "":
		var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
		if not is_skipping:
			await get_tree().create_timer(time).timeout
		next(dialogue_line.next_id)
	else:
		is_waiting_for_input = true
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()


func set_line(line_id: String):
	self.dialogue_line = await resource.get_next_dialogue_line(line_id, temporary_game_states);

## Go to the next line
func next(next_id: String) -> void:
	if dialogue_line and not dialogue_line.tags.has("screen"):
		history.push_back(dialogue_line.id)
	var prev_line = dialogue_line
	set_line(next_id);
	on_next.emit(prev_line, dialogue_line)


## Go to the prev line
func prev() -> void:
	var last_line_id = history.back()
	if last_line_id:
		on_prev.emit(last_line_id)
		history.pop_back()
		#self.dialogue_line = await resource.get_next_dialogue_line(last_line_id, temporary_game_states)

#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if Input.is_action_just_pressed("Back"):
		_on_back_pressed();
		get_viewport().set_input_as_handled()
	#print("gui 1")
	if dialogue_label.is_typing or screen_text.is_typing:
		var mouse_was_clicked: bool = \
				event is InputEventMouseButton and \
				event.button_index == MOUSE_BUTTON_LEFT and \
				event.is_pressed()
				
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			#get_viewport().set_input_as_handled()
			if(dialogue_label.is_typing):
				dialogue_label.skip_typing()
			else:
				screen_text.skip_typing()
			return

	#print("gui 2")

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	#get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	one_response_menu.hide();
	responses_menu.hide();
	next(response.next_id)

func _on_back_pressed() -> void:
	prev()

func _spoke(_letter: String, _letter_index: int, _speed: float):
	if dialogue_line.tags.has("clicking"):
		letter_click.play()

func _on_skip_button_button_down() -> void:
	is_skip_button_pressed = true;
	#print("button_down") #TODO чомусь іноді кнопка не клікається коли пишеться текст

func _on_skip_button_button_up() -> void:
	is_skip_button_pressed = false;

#endregion

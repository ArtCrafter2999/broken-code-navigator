class_name SettingsScreen;
extends Control

signal back_pressed;

@onready var window_button: RadioButton = %WindowButton
@onready var full_screen_button: RadioButton = %FullScreenButton
@onready var sfx_slider: LabeledSlider = %SfxSlider
@onready var music_slider: LabeledSlider = %MusicSlider
@onready var voice_slider: LabeledSlider = %VoiceSlider
@onready var noise: CheckBox = %Noise
@onready var chromatic_abberation: CheckBox = %ChromaticAbberation

var opened = false;

func open():
	if opened: return;
	opened = true;
	full_screen_button.button_pressed = \
			GameState.settings["window_mode"] == DisplayServer.WINDOW_MODE_FULLSCREEN;
	window_button.button_pressed = \
			GameState.settings["window_mode"] == DisplayServer.WINDOW_MODE_WINDOWED;
	sfx_slider.set_value_no_signal(GameState.settings[&"sfx_volume"])
	music_slider.set_value_no_signal(GameState.settings[&"music_volume"])
	voice_slider.set_value_no_signal(GameState.settings[&"voice_volume"])
	noise.button_pressed = GameState.settings["noise"]
	chromatic_abberation.button_pressed = GameState.settings["chromatic_abberation"]
	show();
	create_tween().tween_property(self, "modulate", Color.WHITE, 0.5).from(Color.TRANSPARENT);
	
func close():
	if not opened: return;
	opened = false;
	await create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.5).finished
	print("hidden")
	hide();

func _on_window_button_pressed() -> void:
	GameState.settings[&"window_mode"] = DisplayServer.WINDOW_MODE_WINDOWED
	GameState.save();


func _on_full_screen_button_pressed() -> void:
	GameState.settings[&"window_mode"] = DisplayServer.WINDOW_MODE_FULLSCREEN
	GameState.save();


func _on_noise_toggled(toggled_on: bool) -> void:
	GameState.settings[&"noise"] = toggled_on
	GameState.save();


func _on_chromatic_abberation_toggled(toggled_on: bool) -> void:
	GameState.settings[&"chromatic_abberation"] = toggled_on
	GameState.save();


func _on_sfx_slider_value_changed(value: float) -> void:
	GameState.settings[&"sfx_volume"] = value
	GameState.save();


func _on_music_slider_value_changed(value: float) -> void:
	GameState.settings[&"music_volume"] = value
	GameState.save();


func _on_voice_slider_value_changed(value: float) -> void:
	GameState.settings[&"voice_volume"] = value
	GameState.save();


func _on_back_button_pressed() -> void:
	back_pressed.emit()

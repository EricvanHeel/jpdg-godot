class_name HeaderNode
extends HBoxContainer

@export var left_button: Button
@export var title_label: Label
@export var right_button: Button

signal left_pressed
signal right_pressed

func _ready() -> void:
	left_button.pressed.connect(_emit_left_pressed)
	right_button.pressed.connect(_emit_right_pressed)

func setup(left_texture: String, right_texture: String, title_text: String, title_font: String = "White Chalk.ttf") -> void:
	_setup_button(left_button, left_texture)
	_setup_button(right_button, right_texture)
	title_label.text = title_text
	title_label.add_theme_font_override("font", load("res://assets/fonts/%s" % title_font))

static func _setup_button(button: Button, texture_string: String) -> void:
	if not texture_string:
		var style: StyleBoxEmpty = StyleBoxEmpty.new()
		button.disabled = true
		button.add_theme_stylebox_override("disabled", style)
		return
	var style: StyleBoxTexture = StyleBoxTexture.new()
	style.texture = load("res://assets/images/%s.png" % texture_string)
	var button_styles = ["normal", "pressed", "hover", "disabled", "focus"]
	for style_name in button_styles:
		if style_name == "disabled":
			var disabled_style = style.duplicate()
			disabled_style.modulate_color = "0b2416"
			button.add_theme_stylebox_override(style_name, disabled_style)
			continue
		button.add_theme_stylebox_override(style_name, style)

func _emit_left_pressed() -> void:
	left_pressed.emit()

func _emit_right_pressed() -> void:
	right_pressed.emit()

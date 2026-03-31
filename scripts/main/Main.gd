extends Control
## Main menu. Procedurally built so no child nodes are needed in the scene editor.

func _ready() -> void:
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.04, 0.10)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "ROGUE KAIJU"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var coins_label := Label.new()
	coins_label.text = "Coins: %d" % MetaProgression.kaiju_coins
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(coins_label)

	_add_button(vbox, "START RUN",  _on_start)
	_add_button(vbox, "UPGRADES",   _on_upgrades)
	_add_button(vbox, "QUIT",       get_tree().quit)


func _add_button(parent: Control, label: String, callable: Callable) -> void:
	var btn := Button.new()
	btn.text = label
	btn.pressed.connect(callable)
	parent.add_child(btn)


func _on_start() -> void:
	GameManager.start_run()


func _on_upgrades() -> void:
	# Placeholder — meta upgrade screen not yet built
	pass

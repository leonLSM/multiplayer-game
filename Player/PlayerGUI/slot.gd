extends PanelContainer

signal use_item

var type = Items

func set_icon(image):
	$MarginContainer/ItemImage.texture = image

func set_quantity(amount):
	$QuantityLabel.text = str(int($QuantityLabel.text) + amount)
	if int($QuantityLabel.text) <= 0:
		queue_free()

func _on_button_pressed() -> void:
	emit_signal('use_item', type)
	set_quantity(-1)

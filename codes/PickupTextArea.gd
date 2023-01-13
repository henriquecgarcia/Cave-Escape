extends GridContainer

const pText = preload("res://scenes/PickupText_Label.tscn")

func SetPickupText(text := ""):
	if text == "":
		return
	var t = pText.instance()
	add_child(t)
	t.text = text
	t.rect_rotation = 180
	t.rect_position -= t.rect_size

extends SceneTree

func _init() -> void:
	var csv_path := "res://locale/ui.csv"
	var file := FileAccess.open(csv_path, FileAccess.READ)
	if file == null:
		push_error("Cannot open ui.csv")
		quit(1)
		return
	var header := file.get_csv_line()
	if header.size() < 3:
		push_error("Bad CSV header")
		quit(1)
		return
	var en := Translation.new()
	en.locale = "en"
	var fr := Translation.new()
	fr.locale = "fr"
	while not file.eof_reached():
		var row := file.get_csv_line()
		if row.is_empty() or row[0].is_empty():
			continue
		if row.size() < 3:
			continue
		var key := row[0]
		en.add_message(key, row[1])
		fr.add_message(key, row[2])
	ResourceSaver.save(en, "res://locale/ui.en.translation")
	ResourceSaver.save(fr, "res://locale/ui.fr.translation")
	print("Saved translations en=%d fr=%d" % [en.get_message_list().size(), fr.get_message_list().size()])
	quit(0)

extends Control

@onready var tree: Tree = $VBox/Tree
@onready var path_label: Label = $VBox/Toolbar/PathLabel
@onready var open_dialog: FileDialog = $OpenDialog
@onready var save_dialog: FileDialog = $SaveDialog

var current_file_path: String = ""
var column_keys: Array = []

func _ready() -> void:
	# 初始化 Tree 设置
	tree.set_column_titles_visible(true)
	tree.set_hide_root(true)
	tree.set_select_mode(Tree.SELECT_ROW)
	
	path_label.text = tr("NO_FILE_SELECTED")
	
	# 连接文件拖拽信号
	get_window().files_dropped.connect(_on_files_dropped)

func _on_files_dropped(files: PackedStringArray) -> void:
	if files.size() > 0:
		var file_path = files[0]
		if file_path.to_lower().ends_with(".json"):
			load_json(file_path)

func _on_open_btn_pressed() -> void:
	open_dialog.popup_centered()

func _on_save_btn_pressed() -> void:
	if current_file_path.is_empty():
		save_dialog.popup_centered()
	else:
		save_json(current_file_path)

func _on_add_btn_pressed() -> void:
	if column_keys.is_empty():
		return
	
	var root = tree.get_root()
	if not root:
		root = tree.create_item()
	
	var new_item = tree.create_item(root)
	for i in range(column_keys.size()):
		new_item.set_text(i, "")
		new_item.set_editable(i, true)

func _on_open_dialog_file_selected(path: String) -> void:
	load_json(path)

func _on_save_dialog_file_selected(path: String) -> void:
	save_json(path)

func load_json(path: String) -> void:
	if not FileAccess.file_exists(path):
		return
	
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error(tr("JSON_PARSE_ERROR") + ": " + json.get_error_message())
		return
	
	var data = json.data
	if typeof(data) != TYPE_ARRAY:
		push_error(tr("ROOT_MUST_BE_ARRAY"))
		return
	
	current_file_path = path
	path_label.text = path
	
	populate_tree(data)

func populate_tree(data: Array) -> void:
	tree.clear()
	column_keys.clear()
	
	if data.is_empty():
		return
	
	# 获取表头 (从第一个字典获取)
	var first_item = data[0]
	if typeof(first_item) != TYPE_DICTIONARY:
		push_error(tr("ITEMS_MUST_BE_DICT"))
		return
	
	column_keys = first_item.keys()
	tree.columns = column_keys.size()
	
	for i in range(column_keys.size()):
		tree.set_column_title(i, column_keys[i])
		tree.set_column_expand(i, true)
	
	var root = tree.create_item()
	
	for entry in data:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		
		var item = tree.create_item(root)
		for i in range(column_keys.size()):
			var key = column_keys[i]
			var val = entry.get(key, "")
			
			var display_text = ""
			if typeof(val) == TYPE_FLOAT:
				if is_equal_approx(val, round(val)):
					display_text = str(int(val))
				else:
					display_text = str(val)
			elif val == null:
				display_text = "null"
			else:
				display_text = str(val)
				
			item.set_text(i, display_text)
			item.set_editable(i, true)

func save_json(path: String) -> void:
	var root = tree.get_root()
	if not root:
		return
	
	var data = []
	var item = root.get_first_child()
	
	while item:
		var entry = {}
		for i in range(column_keys.size()):
			var key = column_keys[i]
			var val_str = item.get_text(i)
			
			# 尝试转换回数字，如果可能的话
			if val_str.is_valid_int():
				entry[key] = val_str.to_int()
			elif val_str.is_valid_float():
				entry[key] = val_str.to_float()
			elif val_str.to_lower() == "true":
				entry[key] = true
			elif val_str.to_lower() == "false":
				entry[key] = false
			elif val_str == "null":
				entry[key] = null
			else:
				entry[key] = val_str
		
		data.append(entry)
		item = item.get_next()
	
	var json_string = JSON.stringify(data, "\t")
	
	if OS.has_feature("web"):
		var filename = path.get_file()
		if filename.is_empty(): filename = "data.json"
		web_save(json_string, filename)
		return

	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json_string)
	file.close()
	
	current_file_path = path
	path_label.text = path
	print(tr("FILE_SAVED") + ": ", path)

func web_save(content: String, filename: String) -> void:
	if not OS.has_feature("web"):
		return
	
	var base64_content = Marshalls.raw_to_base64(content.to_utf8_buffer())
	var js_code = """
	(function() {
		const base64 = '%s';
		const bin = atob(base64);
		const buf = new Uint8Array(bin.length);
		for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
		const blob = new Blob([buf], {type: 'application/json'});
		const url = URL.createObjectURL(blob);
		const a = document.createElement('a');
		a.href = url;
		a.download = '%s';
		a.click();
		URL.revokeObjectURL(url);
	})()
	""" % [base64_content, filename]
	
	if JavaScriptBridge.has_method("eval"):
		JavaScriptBridge.eval(js_code)

func _on_tree_item_edited() -> void:
	# 可以在这里处理实时保存或标记未保存更改
	pass

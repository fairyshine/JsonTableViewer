<p align="center">
  <img src="assets/icon.png" width="128" height="128" alt="JSON Table Viewer Icon">
</p>

# JSON Table Viewer

[![Godot Engine](https://img.shields.io/badge/Godot-4.x-blue?logo=godot-engine&logoColor=white)](https://godotengine.org)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A JSON data viewer and editor developed with the Godot engine. It converts specific JSON structures into intuitive 2D tables for easy viewing and quick editing.

## ✨ Key Features

- **Tabular Display**: Automatically converts JSON lists into 2D tables.
- **Automatic Header Recognition**: Generates headers based on JSON dictionary keys, maintaining original order.
- **Real-time Editing**: Supports direct data modification and saving within the table.
- **Structured Support**: Optimized for "List of Objects" formats.

## 📂 Data Format Requirements

To be correctly parsed as a table, the JSON file should follow this structure:

1. The root node must be an **Array**.
2. Each item in the list must be a **Dictionary/Object**.
3. It is recommended that all dictionaries have the same keys, which will serve as column names.

### Example Data (`example.json`)

```json
[
  {
    "id": 0,
    "name": "Physique",
    "var": "physique",
    "description": "Basic physical attributes"
  },
  {
    "id": 1,
    "name": "Wisdom",
    "var": "wisdom",
    "description": "Logic and knowledge base"
  }
]
```

## 🚀 How to Use

### Application Usage
1. **Open File**: Run the program and select the `.json` file you want to view.
2. **View Data**: The program will automatically parse and render the data as a table.
3. **Edit Data**: Click a cell to edit its value.
4. **Save Changes**: Click the save button to write the modified data back to the JSON file.

## 🛠️ Development

This project is developed using **Godot 4.x**.

### Project Structure
- `scenes/`: Contains scene files (e.g., `main.tscn`).
- `scripts/`: Contains GDScript files (e.g., `main.gd`).
- `assets/`: Contains assets like fonts and icons.
- `localization/`: Contains multi-language translation files.
- `data/`: Contains example JSON data.

## 📄 License

This project is licensed under the [MIT License](LICENSE).

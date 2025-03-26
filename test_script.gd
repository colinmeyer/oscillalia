extends SceneTree

func _init():
    print("Starting test...")
    
    # Check if core scene files exist and can be loaded
    var resources = [
        "res://scenes/Main.tscn",
        "res://scenes/ui/MainMenu.tscn",
        "res://scenes/level/Level.tscn",
        "res://scenes/player/Player.tscn"
    ]
    
    for res_path in resources:
        if ResourceLoader.exists(res_path):
            print("File exists: " + res_path)
        else:
            print("File missing: " + res_path)
    
    # Verify directory structure
    var directories = [
        "res://assets/audio/music",
        "res://assets/audio/sfx",
        "res://resources/levels",
        "res://scenes/ui",
        "res://scenes/level",
        "res://scenes/player",
        "res://scenes/npcs"
    ]
    
    var dir = DirAccess.open("res://")
    for directory in directories:
        if dir.dir_exists(directory):
            print("Directory exists: " + directory)
        else:
            print("Warning: Directory missing: " + directory)
    
    # Verify presence of level data
    if ResourceLoader.exists("res://resources/levels/level_1.tres"):
        print("Level data file exists")
    else:
        print("Warning: Could not find level data file")
    
    print("Test complete!")
    quit()
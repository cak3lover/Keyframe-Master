tool
extends EditorPlugin

var Btn;
var Animation_player_path=''; # Stores the Currently Selected Animation Player Path

## Add Keys Tab ##
var UI=load("res://addons/Keyframe Master/UI.tscn").instance(); #Loads an instance of Visual UI
var UI_Keyframe_prop=UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/Keyframe_prop_LineEdit'); # Line edit for mentioning Keyframe Property

var UI_UpdateMode=UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/UpdateMode_Dropdown'); # Dropdown for selecting Update Mode
var UI_InterpolationMode=UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/InterpolationMode_Dropdown'); # Dropdown for selecting Interpolation Mode
var UI_LoopwrapMode=UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/LoopWrapMode_Dropdown'); # Dropdown for selecting Loop Wrap Mode

## Mod Keys Tab ##
var MoveTime= UI.get_node("Transparent Background/Input container/TabContainer/Mod Keys/MoveTime"); # Select to what time you want to Move / Duplicate your keys 
var Selected_only=UI.get_node('Transparent Background/Input container/TabContainer/Mod Keys/Selected'); # Select to what time you want to Move / Duplicate your keys 


### Adding keyframes ###

func add_frames(): # Adds frames of the property of the currently selected nodes at the current position of the timebar 
	print("Keyframe Master: Adding frames...");
	
	if !has_node(Animation_player_path): # Checks if any AnimationPlayer is currently selected or not
		push_warning("Keyframe Master Warning: AnimationPlayer Node does not exist!");
		return;

	var ani_player=get_node(Animation_player_path); #gets currently Selected AnimationPlayer Node

	if(ani_player.assigned_animation==''): # Checks if any Animation is currently assigned to the selected AnimationPlayer or not
		push_warning("Keyframe Master Warning: No current Animation selected!");
		return;

	var ani=ani_player.get_animation(ani_player.assigned_animation); #gets currently assigned Animation
	var all_selected_nodes=get_editor_interface().get_selection().get_selected_nodes();  #gets currently Selected/highlighted Nodes in the scene

	for selected_node in all_selected_nodes: #loops through each of the selected nodes individually
	
		var path=String(ani_player.get_node(ani_player.root_node).get_path_to(selected_node));  # gets path to the node 
		if UI_Keyframe_prop.text in selected_node: # checks if the node has the property of which we would like to add a keyframe of
			
			var complete_path=path+':'+UI_Keyframe_prop.text; # Creates track name by joining path & property
			var track_indx=ani.find_track(complete_path); # Gets track index if it already exists otherwise returns -1
			
			if(track_indx==-1): # if track doesn't already exist then create a new one
				track_indx=ani.add_track(0);
				ani.track_set_path(track_indx,complete_path);

			ani.value_track_set_update_mode(track_indx,Animation['UPDATE_'+UI_UpdateMode.get_item_text(UI_UpdateMode.selected)]); # Sets update mode of key
			ani.track_set_interpolation_type(track_indx,Animation['INTERPOLATION_'+UI_InterpolationMode.get_item_text(UI_InterpolationMode.selected)]); # Sets interpolation mode of key
			ani.track_set_interpolation_loop_wrap(track_indx,UI_LoopwrapMode.selected==0); # Sets loop wrap of keyframe
			
			ani.track_insert_key(track_indx,ani_player.current_animation_position,selected_node[UI_Keyframe_prop.text]); # Adds created key to Animation

	print("Keyframe Master: Added frames!");

func remove_frames(): # Removes frames of the property of the currently selected nodes at the current position of the timebar 
	print("Keyframe Master: Removing frames...");
	
	if !has_node(Animation_player_path):
		push_warning("Keyframe Master Warning: AnimationPlayer Node does not exist!"); # Checks if any AnimationPlayer is currently selected or not
		return;

	var ani_player=get_node(Animation_player_path) #gets currently Selected AnimationPlayer Node

	if(ani_player.assigned_animation==''): # Checks if any Animation is currently assigned to the selected AnimationPlayer or not
		push_warning("Keyframe Master Warning: No current Animation selected!");
		return;

	var ani=ani_player.get_animation(ani_player.assigned_animation); #gets currently assigned Animation
	var all_selected_nodes=get_editor_interface().get_selection().get_selected_nodes(); #gets currently Selected/highlighted Nodes in the scene

	for selected_node in all_selected_nodes: #loops through each of the selected nodes individually
		
		var path=String(ani_player.get_node(ani_player.root_node).get_path_to(selected_node)); # gets path to the node 
		if UI_Keyframe_prop.text in selected_node: # checks if the node has the property of which we would like to add a keyframe of
			
			var complete_path=path+':'+UI_Keyframe_prop.text; # Creates track name by joining path & property
			var track_indx=ani.find_track(complete_path);  #gets currently Selected/highlighted Nodes in the scene

			if(track_indx!=-1): # if track already exist
				ani.track_remove_key_at_position(track_indx,ani_player.current_animation_position); # Deletes key
				if(ani.track_get_key_count(track_indx)==0): # if track is empty after deleting key then delete empty track as well
					ani.remove_track(track_indx);

	print("Keyframe Master: Removed frames!");

### Modifying Keyframes ###

func move_keyframes(): # Moves all or Selected Node's Keyframes on the current timebar to the 'MoveTime' position  
	
	print("Keyframe Master: Moving frames...");
	
	if !has_node(Animation_player_path): # Checks if any AnimationPlayer is currently selected or not
		push_warning("Keyframe Master Warning: AnimationPlayer Node not selected!");
		return;

	var ani_player=get_node(Animation_player_path); #gets currently Selected AnimationPlayer Node

	if(ani_player.assigned_animation==''):  # Checks if any Animation is currently assigned to the selected AnimationPlayer or not
		push_warning("Keyframe Master Warning: No current Animation selected!");
		return;
		
	var move_to_time=float(MoveTime.get_line_edit().text); #gets time at which keyframe is to be moved
	if(move_to_time>ani_player.current_animation_length):  # if user inputs a wrong time which is greater than Animation Time length
		push_warning("Keyframe Master Warning: Move time exceeds animation length!");
		return;
	
	var selected_nodes;
	if(Selected_only.pressed==true): #if `selected only` option is selected then only selected node's keyframes get be moved
		selected_nodes=get_editor_interface().get_selection().get_selected_nodes(); #gives you all editor selected nodes
		
	var ani_root_node=ani_player.get_node(ani_player.root_node); # gets the AnimationPlayer node so that selected nodes can be listed
	var curr_ani=ani_player.get_animation(ani_player.assigned_animation) # gets the AnimationPlayer's currently assigned animation
	var track_count=curr_ani.get_track_count() #gets number of tracks to loop from
	
	for track_indx in track_count: # loops through all the tracks
		
		if(Selected_only.pressed==true): #if `selected only` is pressed then get all the currently selected nodes into one variable
			if(!(ani_root_node.get_node(curr_ani.track_get_path(track_indx)) in selected_nodes)):
				continue;
		
		var current_key=curr_ani.track_find_key(track_indx,ani_player.current_animation_position,true) #finds key which is currently on the Animation Bar
		if current_key ==-1:
			continue
		
		var temp_key_data=curr_ani.track_get_key_value(track_indx, current_key); #gets key data
		curr_ani.track_remove_key_at_position(track_indx, ani_player.current_animation_position); #removes that key frame
		curr_ani.track_insert_key(track_indx,move_to_time,temp_key_data); #adds the keyframe at new position
	
	print("Keyframe Master: Moved frames!");

func duplicate_keyframes(): # Duplicates all or Selected Node's Keyframes on the current timebar to the 'MoveTime' position  
	
	print("Keyframe Master: Duplicating frames...");
	
	if !has_node(Animation_player_path): # Checks if any AnimationPlayer is currently selected or not
		push_warning("Keyframe Master Warning: AnimationPlayer Node not selected!");
		return;

	var ani_player=get_node(Animation_player_path); #gets currently Selected AnimationPlayer Node

	if(ani_player.assigned_animation==''):  # Checks if any Animation is currently assigned to the selected AnimationPlayer or not
		push_warning("Keyframe Master Warning: No current Animation selected!");
		return;
		
	var move_to_time=float(MoveTime.get_line_edit().text); #gets time at which keyframe is to be duplicated
	if(move_to_time>ani_player.current_animation_length):
		push_warning("Keyframe Master Warning: Move time exceeds animation length!");
		return;
	
	var selected_nodes;
	if(Selected_only.pressed==true):  # if user inputs a wrong time which is greater than Animation Time length
		selected_nodes=get_editor_interface().get_selection().get_selected_nodes();
		
	var ani_root_node=ani_player.get_node(ani_player.root_node); # gets the AnimationPlayer node so that selected nodes can be listed
	var curr_ani=ani_player.get_animation(ani_player.assigned_animation) # gets the AnimationPlayer's currently assigned animation
	var track_count=curr_ani.get_track_count() #gets number of tracks to loop from
	
	for track_indx in track_count: # loops through all the tracks
		
		if(Selected_only.pressed==true): #if `selected only` is pressed then get all the currently selected nodes into one variable
			if(!(ani_root_node.get_node(curr_ani.track_get_path(track_indx)) in selected_nodes)):
				continue;
		
		
		var current_key=curr_ani.track_find_key(track_indx,ani_player.current_animation_position,true) #finds key which is currently on the Animation Bar
		if current_key ==-1:
			continue
		
		var temp_key_data=curr_ani.track_get_key_value(track_indx, current_key); #gets key data

		curr_ani.track_insert_key(track_indx,move_to_time,temp_key_data); #Duplicates the key
	
	print("Keyframe Master: Duplicated frames!");

### Common ###

func handles(object):
	return object is AnimationPlayer

func edit(object):
	Animation_player_path = String(self.get_path_to(object));

func _notification(what):
	if(what==MainLoop.NOTIFICATION_WM_QUIT_REQUEST):
		close_UI();

func show_UI():
	get_editor_interface().add_child(UI)

func close_UI():
	if(get_editor_interface().has_node(UI.name)):
		get_editor_interface().remove_child(UI);

func _enter_tree():
	Btn=Button.new();
	Btn.name="Key_btn"
	Btn.text=" Keyframe Master ";
	Btn.flat=true;
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,Btn);
	Btn.connect("pressed",self,"show_UI");

func _init():

	# adding keyframes #
	UI.get_node('Transparent Background').connect("pressed",self,"close_UI")
	UI.get_node('Transparent Background/Input container/Close_btn').connect("pressed",self,"close_UI")

	UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/Remove_btn').connect("pressed",self,"remove_frames")
	UI.get_node('Transparent Background/Input container/TabContainer/Add Keys/Add_btn').connect("pressed",self,"add_frames")
	
	UI_UpdateMode.add_item("CONTINUOUS",0);
	UI_UpdateMode.add_item("DISCRETE",1);
	UI_UpdateMode.add_item("TRIGGER",2);
	UI_UpdateMode.add_item("CAPTURE",3);
	
	UI_InterpolationMode.add_item("LINEAR",0);
	UI_InterpolationMode.add_item("NEAREST",1);
	UI_InterpolationMode.add_item("CUBIC",2);

	UI_LoopwrapMode.add_item("WRAP LOOP",0);
	UI_LoopwrapMode.add_item("CLAMP LOOP",1);

	# modifying keyframes #
	
	UI.get_node("Transparent Background/Input container/TabContainer/Mod Keys/Move").connect("pressed",self,"move_keyframes");
	UI.get_node("Transparent Background/Input container/TabContainer/Mod Keys/Duplicate").connect("pressed",self,"duplicate_keyframes");

func _exit_tree():
	remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU,Btn)
	close_UI();

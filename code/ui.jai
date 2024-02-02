subwindow_info: Subwindow_Info;
subwindow_init: bool;
current_theme: s32 = xx Default_Themes.Freddie_Freeloader;
theme: Overall_Theme;
k: float;

hovering_ui: bool;

change_type_index: s32;
change_level: s32;
change_input: s32;

level_name: string;

ui_window :: (k: float, title: string, info: *Subwindow_Info, is_init: *bool, theme: Overall_Theme) {
  if !<<is_init {
    r := get_rect(7.5*k, 3*k, 4.2*k + 0.1*k, 5.3*k);
    subwindow_info.rect = r;
    subwindow_info.draw = draw_subwindow;
    subwindow_info.title_text = title;
    <<is_init = true;
  }
  
  subwindow_theme := theme.subwindow_theme;
  if info.open {
    subwindow_state := add_subwindow(info, *subwindow_theme);
  }
}

ui_button :: inline (stride: float, r: *Rect, label: string, theme: *Button_Theme, loc:=#caller_location, identifier:=1) -> bool {
  pressed := button(<<r, label, theme, loc=loc, identifier=identifier);
  r.y -= stride;
  
  return pressed;
}

ui_menu_button :: inline (stride: float, sub_r: Rect, r: *Rect, label: string, theme: *Button_Theme, location: Menu_Location, loc:=#caller_location) -> bool {
  if button(<<r, label, theme, loc=loc) {
    menu_location = location;
    r.y = sub_r.y + sub_r.h - stride;
    return true;
  }
  r.y -= stride;
  return false;
}

ui_label :: inline (stride: float, r: *Rect, text: string, theme: *Label_Theme) {
  label(<<r, text, theme);
  r.y -= stride;
}

ui_dropdown :: (stride: float, r: *Rect, choices: [] string, value_pointer: *s32, theme: *Dropdown_Theme, loc:=#caller_location) {
  dropdown(<<r, choices, value_pointer, theme, loc=loc);
  r.y -= stride;
}

draw_subwindow :: (subwindow: Rect, data: *void) {
  stride := 0.6*k;
  r := get_rect(subwindow.x + 0.1/2*k, subwindow.y + subwindow.h - stride,
                4.2*k, xx font.character_height + 0.1*k);
  
  button_theme := *theme.button_theme;
  label_theme := *theme.label_theme;
  dropdown_theme := *theme.dropdown_theme;
  text_input_theme := *theme.text_input_theme;
  
  if menu_location == {
    case .MAIN;
    if ui_menu_button(stride, subwindow, *r, "Items", button_theme, .ITEMS) return;
    if ui_menu_button(stride, subwindow, *r, "Input", button_theme, .INPUT) return;
    if ui_menu_button(stride, subwindow, *r, "Goto Level", button_theme, .GOTO_LEVEL) return;
    
    if ui_button(stride, *r, "Place Entity", button_theme) {
      placing_terrain = true;
      open_manager_window = false;
      return;
    }
    
    if ui_menu_button(stride, subwindow, *r, "Generate Level Code", button_theme, .GENERATE_LEVEL) return;
    
    if ui_button(stride, *r, "Reset Players", button_theme) {
      reset_players();
      simulation_enabled = false;
      return;
    }
    
    if ui_button(stride, *r, "Kill Players", button_theme) {
      delete_players();
      simulation_enabled = false;
      pause_mode = false;
      return;
    }
    
    ui_menu_button(stride, subwindow, *r, "Quit", button_theme, .QUIT);
    
    case .ITEMS;
    if ui_menu_button(stride, subwindow, *r, "Platforms", button_theme, .PLATFORMS) return;
    
    if ui_button(stride, *r, "Basic Trap", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = TRAP_COLOR;
      placement_info.type = .TRAP;
      placement_info.trap_data = .{};
      
      placing_item = true;
      open_manager_window = false;
      return;
    }
    
    if ui_menu_button(stride, subwindow, *r, "Attacks", button_theme, .ATTACKS) return;
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .PLATFORMS;
    if ui_button(stride, *r, "Basic Platform", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = .{0, 1, 0, 1};
      placement_info.type = .PLATFORM;
      placement_info.platform_data = .{.BASIC, 1};
      
      placing_item = true;
      open_manager_window = false;
      return;
    }
    
    if ui_button(stride, *r, "Slower Platform", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = .{1, 1, 0, 1};
      placement_info.type = .PLATFORM;
      placement_info.platform_data = .{.SLOWER, 2};
      
      placing_item = true;
      open_manager_window = false;
      return;
    }
    
    if ui_button(stride, *r, "Speeder Platform", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = .{0.7, 0.7, 1, 1};
      placement_info.type = .PLATFORM;
      placement_info.platform_data = .{.SPEEDER, 0.5};
      
      placing_item = true;
      open_manager_window = false;
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .ITEMS);
    
    case .ATTACKS;
    if ui_button(stride, *r, "Zipper Attack", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = .{1, 0, 0, 1};
      placement_info.type = .ATTACK;
      placement_info.attack_data = .{.ZIPPER, .{.ZIPPER, .{100, 0}, 3}, 5, 5};
      
      placing_item = true;
      open_manager_window = false;
      return;
    }
    
    if ui_button(stride, *r, "Launcher Attack", button_theme) {
      placement_info.size = .{5, 5};
      placement_info.color = .{1, 0, 0, 1};
      placement_info.type = .ATTACK;
      placement_info.attack_data = .{.LAUNCHER, .{.LAUNCHER, .{50, 100}, 3}, 5, 5};
      
      placing_item = true;
      open_manager_window = false;
      return;
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .ITEMS);
    
    case .GOTO_LEVEL;
    for 0..(Level.LEVEL_COUNT-1) {
      if ui_button(stride, *r, level_names[it], button_theme, identifier=xx it) {
        switch_levels(it);
        return;
      }
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .PHYSICS;
    if ui_button(stride, *r, "Toggle Sim", button_theme) {
      simulation_enabled = !simulation_enabled;
      return;
    }
    
    if ui_button(stride, *r, "Reset", button_theme) {
      reset_players();
      simulation_enabled = false;
      return;
    }
    
    // ui_slider("Speed", slider_color_info, 1000, *speed);
    // ui_slider("Jump Force", slider_color_info, 200, *jump_force);
    // ui_slider("Gravity", slider_color_info, 500, *gravity);
    // ui_slider("Friction", slider_color_info, 10, *friction);
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .ENTITY_EDITOR;
    if entity_selected {
      using entity := *entities[selected_entity];
      
      if ui_button(stride, *r, "Delete", button_theme) {
        delete_entity(entity);
        entity_selected = false;
        menu_location = .MAIN;
        return;
      }
      
      ui_label(stride, *r, "Change Entity Type:", label_theme);
      
      entity_type_strings: [4] string : .["None",
                                          "Player Spawn",
                                          "Level Select",
                                          "Sign"];
      ui_dropdown(stride, *r, entity_type_strings, *change_type_index, dropdown_theme);
      if ui_button(stride, *r, "Change", button_theme) {
        if change_type_index == {
          case 0;
          type = .NONE;
          collidable = true;
          size = GRID_SIZE;
          
          case 1;
          if type == .PLAYER_SPAWN {
            print("Already a Player Spawn!\n");
          }
          else {
            if num_player_spawns >= MAX_PLAYERS {
              print("At max PLAYER_SPAWN capacity!\n");
            }
            else {
              change_type_index = 0;
              type = .PLAYER_SPAWN;
              collidable = false;
              player_id = num_player_spawns;
              player_spawns[num_player_spawns] = entity;
              num_player_spawns += 1;
              
              size = GRID_SIZE;
              
              if player_id == {
                case 0; color = PLAYER_SPAWN_1_COLOR;
                case 1; color = PLAYER_SPAWN_2_COLOR;
                case 2; color = PLAYER_SPAWN_3_COLOR;
                case 3; color = PLAYER_SPAWN_4_COLOR;
              }
            }
          }
          
          case 2;
          if type == .LEVEL_SELECT {
            print("Already a Level Select!\n");
          }
          else {
            type = .LEVEL_SELECT;
          }
          
          case 3;
          if type == .SIGN {
            print("Already a Sign!\n");
          }
          else {
            type = .SIGN;
            text_data.color = .{0, 0, 0, 1};
            collidable = false;
          }
        }
      }
      
      if type == {
        case .LEVEL_SELECT;
        ui_label(stride, *r, "Change Level:", label_theme);
        ui_dropdown(stride, *r, level_names, *change_level, dropdown_theme);
        if ui_button(stride, *r, "Change", button_theme) {
          level = xx change_level;
          return;
        }
        
        case .SIGN;
        ui_label(stride, *r, "Change Sign Text:", label_theme);
        action, new_text := text_input(r, text_data.text, text_input_theme);
        r.y -= stride;
        if action & .ENTERED text_data.text = copy_string(new_text);
        
        case .PLAYER_SPAWN;
        controller_strings: [..] string;
        for 0..(num_inputs - 1) {
          array_add(*controller_strings, control_type_strings[it]);
        }
        
        ui_label(stride, *r, "Change Controller:", label_theme);
        ui_dropdown(stride, *r, controller_strings, *change_input, dropdown_theme);
        if ui_button(stride, *r, "Change", button_theme) {
          taken: bool = false;
          for 0..(num_player_spawns - 1) {
            if player_spawns[it].control_type == xx change_input {
              taken = true;
              break;
            }
          }
          if !taken control_type = xx change_input;
          return;
        }
        
        case .PLAYER;
        controller_strings: [..] string;
        for 0..(num_inputs - 1) {
          array_add(*controller_strings, control_type_strings[it]);
        }
        
        ui_label(stride, *r, "Change Controller:", label_theme);
        ui_dropdown(stride, *r, controller_strings, *change_input, dropdown_theme);
        if ui_button(stride, *r, "Change", button_theme) {
          taken: bool = false;
          for 0..(num_player_spawns - 1) {
            if player_spawns[it].control_type == xx change_input {
              taken = true;
              break;
            }
          }
          if !taken {
            control_type = xx change_input;
            player_spawns[player_id].control_type = xx change_input;
          }
          return;
        }
      }
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .INPUT;
    if ui_button(stride, *r, "Detect Controllers", button_theme) {
      init_gamepad();
      return;
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .GENERATE_LEVEL;
    ui_label(stride, *r, "Level Name:", label_theme);
    action, new_text := text_input(r, level_name, text_input_theme);
    r.y -= stride;
    if action & .ENTERED level_name = copy_string(new_text);
    
    if ui_button(stride, *r, "Generate", button_theme) {
      print("% :: () {\n", level_name);
      
      for 0..(num_entities-1) {
        using entity := entities[it];
        
        if type == .PLAYER || type == .PLATFORM || type == .TRAP || type == .ATTACK {
          continue;
        }
        
        print("entity_% := create_entity(.%, .%, .%, .%);\n", it, pos, size, color, type);
        
        if type == {
          case .LEVEL_SELECT;
          print("entity_%.level = .%;\n", it, level);
          
          case .SIGN;
          print("entity_%.text_data.color = .%;\n", it, text_data.color);
          print("entity_%.text_data.text = \"%\";\n", it, text_data.text);
        }
      }
      
      print("}\n");
      return;
    }
    
    ui_menu_button(stride, subwindow, *r, "Back", button_theme, .MAIN);
    
    case .QUIT;
    quit = true;
  }
}

Menu_Location :: enum {
  MAIN;
  ITEMS;
  PLATFORMS;
  ATTACKS;
  GOTO_LEVEL;
  PHYSICS;
  ENTITY_EDITOR;
  INPUT;
  GENERATE_LEVEL;
  
  QUIT;
}
menu_location: Menu_Location;

Text :: struct {
  str: string;
  pos: Vector2;
  color: Vector4;
}
text_to_render: [128]Text = ---;
text_to_render_count: s32;
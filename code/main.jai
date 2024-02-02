quit: bool;
main :: () {
  init_gamepad();
  
  num_inputs += Gamepad.gamepads_connected;
  
  ASPECT_RATIO :: 16.0 / 9.0;
  
  window_width = 800;
  window_height = cast(s32)(window_width / ASPECT_RATIO);
  
  grids_x = xx (window_width / GRID_SIZE.x + 1);
  grids_y = xx (window_height / GRID_SIZE.y + 1);
  
  half_window_width = window_width / 2;
  half_window_height = window_height / 2;
  
  window = create_window(window_width, window_height, "Game 1");
  Simp.set_render_target(window);
  ui_init();
  
  font = Simp.get_font_at_size(".", "RandyGG.ttf", FONT_SIZE);
  ui_font = Simp.get_font_at_size(".", "RandyGG.ttf", FONT_SIZE);
  assert(font != null);
  assert(ui_font != null);
  
  {
    theme_proc := default_theme_procs[current_theme];
    theme = theme_proc();
    
    theme.button_theme.enable_variable_frame_thickness = true;
    theme.button_theme.label_theme.alignment = .Center;
  }
  
  level_select();
  
  last_time: float64;
  while !quit {
    time := get_time();
    delta_time := cast(float)(time - last_time);
    last_time = time;
    
    Input.update_window_events();
    Gamepad.update_gamepads();
    for Input.get_window_resizes() {
      Simp.update_window(it.window);
      
      if it.window == window {
        window_width = it.width;
        window_height = it.height;
        
        grids_x = xx (window_width / GRID_SIZE.x + 1);
        grids_y = xx (window_height / GRID_SIZE.y + 1);
        
        half_window_width = window_width / 2;
        half_window_height = window_height / 2;
      }
    }
    
    // NOTE: get_mouse_pointer_position is based on
    //       top left but we render from bottom left
    mouse_x, mouse_y = get_mouse_pointer_position();
    mouse_y = window_height - mouse_y;
    
    {
      grid_hovering_x = xx (mouse_x / GRID_SIZE.x);
      grid_hovering_y = xx (mouse_y / GRID_SIZE.y);
    }
    
    for Input.events_this_frame {
      if it.type == .QUIT {
        quit = true;
        break;
      }
      
      getrect_handle_event(it);
      
      if it.type == .KEYBOARD {
        if it.key_code == {
          case .ARROW_LEFT; keys.left = it.key_pressed;
          case .ARROW_RIGHT; keys.right = it.key_pressed;
          
          case .ESCAPE;
          if it.key_pressed active_widget_deactivate_all();
          keys.escape = it.key_pressed;
          
          case .ENTER; keys.enter = it.key_pressed;
          case .SPACEBAR; keys.space = it.key_pressed;
          
          case .MOUSE_BUTTON_LEFT; keys.mouse_left = it.key_pressed;
          
          case #char "R"; keys.r = it.key_pressed;
          
          // case #char "O"; if !placing_item open_manager_window = true;
          // case #char "C"; if !placing_item open_manager_window = false;
          
          case #char "E";
          if it.key_pressed {
            if simulation_enabled {
              simulation_enabled = false;
              open_manager_window = true;
              if num_players > 0
                pause_mode = true;
            }
            else {
              simulation_enabled = true;
              pause_mode = false;
              if num_players != num_player_spawns {
                delete_players();
                spawn_players();
              }
            }
          }
        }
      }
    }
    
    if simulation_enabled open_manager_window = false;
    
    Simp.clear_render_target(0.1, 0.1, 0.1, 1);
    Simp.immediate_begin();
    Simp.set_shader_for_color();
    
    {
      ui_per_frame_update(window, window_width, window_height, time);
      k = min(window_height * 0.1, 60);
      
      ui_font = Simp.get_font_at_size(".", "Randygg.ttf", xx (0.3*k));
      
      theme.subwindow_theme.title_bar.font = ui_font;
      theme.subwindow_theme.close_button.font = ui_font;
      
      theme.button_theme.font = ui_font;
      
      theme.label_theme.font = ui_font;
      
      theme.dropdown_theme.theme_for_current_value.font = ui_font;
      theme.dropdown_theme.theme_for_each_choice.font = ui_font;
      theme.dropdown_theme.theme_for_current_choice.font = ui_font;
      
      theme.text_input_theme.font = ui_font;
      
      if open_manager_window {
        ui_window(k, "Manager", *subwindow_info, *subwindow_init, theme);
        r := subwindow_info.rect;
        if (xx mouse_x > r.x && xx mouse_x < r.x + r.w &&
            xx mouse_y > r.y && xx mouse_y < r.y + r.h) {
          hovering_ui = true;
        }
        else {
          hovering_ui = false;
        }
      }
      else {
        hovering_ui = false;
      }
    }
    
    if in_game && !placed_objects_for_round {
      if placing_item || placing_terrain || open_level_name_window {
        if simulation_enabled simulation_was_enabled = true;
        simulation_enabled = false;
      }
      else if simulation_was_enabled {
        simulation_enabled = true;
        simulation_was_enabled = false;
      }
      
      if keys.escape && !last_keys.escape {
        if placing_item {
          open_manager_window = true;
          placing_item = false;
        }
        else if placing_terrain {
          open_manager_window = true;
          placing_terrain = false;
          placed_first_terrain_point = false;
        }
        else if open_level_name_window {
          open_manager_window = true;
          open_level_name_window = false;
          reset(*level_name_builder);
        }
      }
      
      if keys.mouse_left && !last_keys.mouse_left {
        if placing_item {
          pos: Vector2 = .{grid_hovering_x*GRID_SIZE.x + GRID_SIZE.x/2, grid_hovering_y*GRID_SIZE.y + GRID_SIZE.y/2};
          pos.x -= half_window_width;
          pos.y -= half_window_height;
          
          item := create_entity(pos, placement_info.size,
                                placement_info.color, placement_info.type);
          
          if placement_info.type == {
            case .PLATFORM; item.platform_data = placement_info.platform_data;
            case .TRAP; item.trap_data = placement_info.trap_data;
            case .ATTACK; item.attack_data = placement_info.attack_data;
          }
          
          open_manager_window = true;
          placing_item = false;
        }
        
        if placing_terrain {
          if !placed_first_terrain_point {
            first_terrain_point = .{grid_hovering_x*GRID_SIZE.x - half_window_width, grid_hovering_y*GRID_SIZE.y - half_window_height};
            placed_first_terrain_point = true;
          }
          else {
            window_size: Vector2 = .{xx half_window_width, xx half_window_height};
            
            second_point: Vector2 = .{grid_hovering_x*GRID_SIZE.x, grid_hovering_y*GRID_SIZE.y};
            first_point := first_terrain_point + window_size;
            if xx mouse_x > first_point.x second_point.x += GRID_SIZE.x;
            else first_point.x += GRID_SIZE.x;
            if xx mouse_y > first_point.y second_point.y += GRID_SIZE.y;
            else first_point.y += GRID_SIZE.y;
            
            is_right := second_point.x > first_point.x;
            is_top := second_point.y > first_point.y;
            
            size: Vector2 = .{abs(second_point.x - first_point.x), abs(second_point.y - first_point.y)};
            half_size := size/2;
            
            pos: Vector2 = ---;
            if is_right pos.x = first_point.x + half_size.x;
            else pos.x = second_point.x + half_size.x;
            
            if is_top pos.y = first_point.y + half_size.y;
            else pos.y = second_point.y + half_size.y;
            
            create_entity(pos - window_size, size, .{1, 1, 1, 1}, .NONE);
            
            open_manager_window = true;
            placed_first_terrain_point = false;
            placing_terrain = false;
          }
        }
      }
    }
    
    if keys.r && !last_keys.r {
      reset_players();
      simulation_enabled = false;
    }
    
    // Level Editor
    if !simulation_enabled {
      entity_hovered_this_frame: bool;
      for 0..(num_entities - 1) {
        entity := *entities[it];
        if !entity.active continue;
        
        half_size := entity.size / 2;
        left := entity.pos.x - half_size.x + half_window_width;
        right := entity.pos.x + half_size.x + half_window_width;
        top := entity.pos.y + half_size.y + half_window_height;
        bottom := entity.pos.y - half_size.y + half_window_height;
        
        if (!hovering_ui &&
            xx mouse_x > left && xx mouse_x < right &&
            xx mouse_y > bottom && xx mouse_y < top) {
          hovered_entity = it;
          entity_hovered = true;
          entity_hovered_this_frame = true;
        }
      }
      
      entity_selected_this_frame: bool;
      if !entity_hovered_this_frame {
        entity_hovered = false;
      }
      if !keys.mouse_left && last_keys.mouse_left {
        if entity_hovered_this_frame {
          selected_entity = hovered_entity;
          entity_selected = true;
          entity_selected_this_frame = true;
          menu_location = .ENTITY_EDITOR;
        }
      }
      else if keys.mouse_left && !last_keys.mouse_left && !entity_hovered && entity_selected && !hovering_ui {
        entity_selected = false;
        menu_location = .MAIN;
      }
      
      if (entity_selected && keys.mouse_left && !hovering_ui &&
          !(entity_hovered && hovered_entity != selected_entity)) {
        using entity := *entities[selected_entity];
        pos.x = grid_hovering_x*GRID_SIZE.x + GRID_SIZE.x/2 - half_window_width;
        pos.y = grid_hovering_y*GRID_SIZE.y + GRID_SIZE.y/2 - half_window_height;
        
        if (cast(u32)(size.x / GRID_SIZE.x) % 2) == 0
          pos.x -= GRID_SIZE.x/2;
        if (cast(u32)(size.y / GRID_SIZE.y) % 2) == 0
          pos.y -= GRID_SIZE.y/2;
      }
    }
    
    if simulation_enabled {
      if in_game {
        // TODO(evan):
        // Prevent the players from moving
        // Draw quad for object select background
        // Display each available object to place
        // Have each player, in turn, place an object
        // After the last player goes, let the players move
        // Once all of the players die or make it, reset the steps
        // After one of the players meets a certain goal, end the game and annouce the winner
        // Bring everyone back to the level select
      }
      
      // Update Entities
      for 0..(num_entities - 1) {
        using entity := *entities[it];
        last_pos = entity.pos;
        if type == {
          case .PLAYER; update_player(entity, delta_time);
          case .TRAP; update_trap(entity, delta_time);
          case .ATTACK; update_attack(entity, delta_time);
        }
      }
      
      // Collide Entities
      for first_it: 0..(num_entities - 1) {
        first := *entities[first_it];
        if !first.active || !first.collidable continue;
        
        half_first_size := first.size/2;
        first_left := first.pos.x - half_first_size.x;
        first_right := first_left + first.size.x;
        first_top := first.pos.y + half_first_size.y;
        first_bottom := first_top - first.size.y;
        
        // NOTE: This will check for all types with collide functions
        if first.type == .PLAYER || first.type == .LEVEL_SELECT {
          for second_it: 0..(num_entities - 1) {
            if first_it == second_it continue;
            
            second := *entities[second_it];
            if !second.active || !second.collidable continue;
            
            half_second_size := second.size/2;
            second_left := second.pos.x - half_second_size.x;
            second_right := second_left + second.size.x;
            second_top := second.pos.y + half_second_size.y;
            second_bottom := second_top - second.size.y;
            
            if (first_right >= second_left &&
                first_left <= second_right &&
                first_top >= second_bottom &&
                first_bottom <= second_top) {
              already_collided: bool = false;
              for 0..(first.num_entities_colliding_with - 1) {
                if first.entities_colliding_with[it] == second.index already_collided = true;
              }
              
              if already_collided continue;
              
              if first.type == {
                case .PLAYER; start_collide_player(first, second, delta_time);
                case .LEVEL_SELECT; if second.type == .PLAYER switch_levels(first.level);
              }
              
              first.entities_colliding_with[first.num_entities_colliding_with] = second.index;
              first.num_entities_colliding_with += 1;
            }
            else {
              already_collided: bool = false;
              index: s64;
              for 0..(first.num_entities_colliding_with - 1) {
                if first.entities_colliding_with[it] == second.index {
                  already_collided = true;
                  index = it;
                }
              }
              
              if !already_collided continue;
              
              if first.type == .PLAYER stop_collide_player(first, second);
              
              // NOTE: If we uncollide with anything, we uncollide with everything
              //       so that we recollide with everything again
              first.num_entities_colliding_with = 0;
            }
          }
        }
      }
    }
    
    if !simulation_enabled {
      for y:0..(grids_y - 1) {
        for x:0..(grids_x - 1) {
          pos_x := x*GRID_SIZE.x;
          pos_y := y*GRID_SIZE.y;
          
          Simp.immediate_quad(pos_x - GRID_LINE_THICKNESS, pos_y, pos_x, pos_y + GRID_SIZE.y, GRID_COLOR);
          Simp.immediate_quad(pos_x, pos_y - GRID_LINE_THICKNESS, pos_x + GRID_SIZE.x, pos_y, GRID_COLOR);
          
          if grid_hovering_x == x && grid_hovering_y == y {
            Simp.immediate_quad(pos_x, pos_y, pos_x + GRID_SIZE.x, pos_y + GRID_SIZE.y, .{0.5, 0.5, 0.5, 1});
          }
        }
      }
    }
    
    for 0..(num_entities - 1) {
      using entity := *entities[it];
      if !active continue;
      
      half_size := size/2;
      half_window_size: Vector2 = .{xx half_window_width, xx half_window_height};
      bottom_left := pos - half_size + half_window_size;
      top_right := pos + half_size + half_window_size;
      
      if !simulation_enabled {
        color: Vector4 = ---;
        draw_highlight: bool = ---;
        if entity_selected && selected_entity == it {
          color = .{1, 1, 0, 1};
          draw_highlight = true;
        }
        else if entity_hovered && hovered_entity == it {
          color = .{0.7, 0.7, 0.7, 1};
          draw_highlight = true;
        }
        else {
          draw_highlight = false;
        }
        
        if draw_highlight {
          if type == .LEVEL_SELECT {
            Simp.immediate_quad(bottom_left.x - GRID_LINE_THICKNESS*2, bottom_left.y - GRID_LINE_THICKNESS*2,
                                bottom_left.x - GRID_LINE_THICKNESS, top_right.y + GRID_LINE_THICKNESS*2,
                                color);
            Simp.immediate_quad(top_right.x + GRID_LINE_THICKNESS, bottom_left.y - GRID_LINE_THICKNESS*2,
                                top_right.x + GRID_LINE_THICKNESS*2, top_right.y + GRID_LINE_THICKNESS*2,
                                color);
            Simp.immediate_quad(bottom_left.x - GRID_LINE_THICKNESS, bottom_left.y - GRID_LINE_THICKNESS*2,
                                top_right.x + GRID_LINE_THICKNESS, bottom_left.y - GRID_LINE_THICKNESS,
                                color);
            Simp.immediate_quad(bottom_left.x - GRID_LINE_THICKNESS, top_right.y + GRID_LINE_THICKNESS,
                                top_right.x + GRID_LINE_THICKNESS, top_right.y + GRID_LINE_THICKNESS*2,
                                color);
          }
          else {
            half_highlight_size := HIGHLIGHT_SQUARE_SIZE*2;
            new_bottom_left := bottom_left - half_highlight_size;
            new_top_right := top_right + half_highlight_size;
            Simp.immediate_quad(new_bottom_left.x, new_bottom_left.y,
                                new_top_right.x, new_top_right.y,
                                color);
          }
        }
      }
      
      if type == .SIGN {
        text_pos: Vector2 = pos + half_window_size;
        text := text_data.text;
        width := Simp.prepare_text(font, text);
        text_pos.x -= width/2;
        text_pos.y -= FONT_SIZE/4;
        
        text_: Text = .{text, text_pos, text_data.color};
        text_to_render[text_to_render_count] = text_;
        text_to_render_count += 1;
      }
      
      if type == .LEVEL_SELECT {
        if !simulation_enabled {
          Simp.immediate_quad(bottom_left.x - GRID_LINE_THICKNESS, bottom_left.y - GRID_LINE_THICKNESS,
                              bottom_left.x, top_right.y + GRID_LINE_THICKNESS,
                              .{0, 1, 0, 1});
          Simp.immediate_quad(top_right.x, bottom_left.y - GRID_LINE_THICKNESS,
                              top_right.x + GRID_LINE_THICKNESS, top_right.y + GRID_LINE_THICKNESS,
                              .{0, 1, 0, 1});
          Simp.immediate_quad(bottom_left.x, bottom_left.y - GRID_LINE_THICKNESS,
                              top_right.x, bottom_left.y,
                              .{0, 1, 0, 1});
          Simp.immediate_quad(bottom_left.x, top_right.y,
                              top_right.x, top_right.y + GRID_LINE_THICKNESS,
                              .{0, 1, 0, 1});
        }
      }
      else if type == .PLAYER_SPAWN {
        if !simulation_enabled && !pause_mode {
          Simp.immediate_quad(bottom_left.x, bottom_left.y, top_right.x, top_right.y, color);
        }
      }
      else {
        Simp.immediate_quad(bottom_left.x, bottom_left.y, top_right.x, top_right.y, color);
      }
    }
    
    if placing_item {
      half_size := placement_info.size/2;
      pos: Vector2 = .{grid_hovering_x*GRID_SIZE.x + GRID_SIZE.x/2, grid_hovering_y*GRID_SIZE.y + GRID_SIZE.y/2};
      bottom_left := pos - half_size;
      top_right := pos + half_size;
      Simp.immediate_quad(bottom_left.x, bottom_left.y,
                          top_right.x, top_right.y,
                          placement_info.color);
    }
    
    if placed_first_terrain_point {
      second_point: Vector2 = .{grid_hovering_x*GRID_SIZE.x, grid_hovering_y*GRID_SIZE.y};
      first_point := first_terrain_point + .{xx half_window_width, xx half_window_height};
      if xx mouse_x > first_point.x second_point.x += GRID_SIZE.x;
      else first_point.x += GRID_SIZE.x;
      if xx mouse_y > first_point.y second_point.y += GRID_SIZE.y;
      else first_point.y += GRID_SIZE.y;
      
      Simp.immediate_quad(first_point.x, first_point.y,
                          second_point.x, second_point.y,
                          .{0.15, 0.15, 0.15, 0.5});
    }
    
    for 0..(text_to_render_count - 1) {
      text := text_to_render[it];
      Simp.prepare_text(font, text.str);
      Simp.draw_prepared_text(font, xx text.pos.x, xx text.pos.y, text.color);
    }
    text_to_render_count = 0;
    
    draw_popups();
    
    Simp.immediate_flush();
    Simp.swap_buffers(window);
    
    last_keys = keys;
    last_mouse_x = mouse_x;
    last_mouse_y = mouse_y;
    
    reset_temporary_storage();
  }
}

init_gamepad :: () {
  Gamepad.init_gamepad();
  for 0..(MAX_PLAYERS-1) {
    if Gamepad.gamepads_connected - 1 > it break;
    players_using_controller[it] = true;
  }
}

manager_window_pos: Vector2;
open_manager_window := true;

level_window_pos: Vector2 = .{300, 0};
open_level_name_window: bool;
level_name_builder: String_Builder;

gravity: float = 300; // pixels/s^2
simulation_enabled: bool;
simulation_was_enabled: bool;
pause_mode: bool;

Keys :: struct {
  left: u32;
  right: u32;
  
  escape: u32;
  enter: u32;
  space: u32;
  backspace: u32;
  
  mouse_left: u32;
  
  r: u32;
};
keys: Keys;
last_keys: Keys;

mouse_x, mouse_y: s64;
last_mouse_x, last_mouse_y: s64;

window_width, window_height: s32;
half_window_width, half_window_height: s32;

window: Window_Type = ---;

FONT_SIZE: s32 : 20;
HALF_FONT_SIZE: s32 : FONT_SIZE / 2;
font: *Simp.Dynamic_Font = ---;
ui_font: *Simp.Dynamic_Font = ---;

Placement_Info :: struct {
  size: Vector2;
  color: Vector4;
  type: Entity_Type;
  
  platform_data: Platform_Data;
  trap_data: Trap_Data;
  attack_data: Attack_Data;
}
placement_info: Placement_Info;
placing_item: bool;

placing_terrain: bool;
first_terrain_point: Vector2 = ---;
placed_first_terrain_point: bool;

entity_pos_x_builder: String_Builder;

HIGHLIGHT_SQUARE_SIZE: Vector2 : .{2.5, 2.5};
GRID_SIZE: Vector2 : .{20, 20};
GRID_COLOR: Vector4 : .{0.7, 0.7, 0.7, 0.5};
GRID_LINE_THICKNESS :: 2.0;
grids_x: u32;
grids_y: u32;
grid_hovering_x: u32;
grid_hovering_y: u32;

in_game: bool;
placed_objects_for_round: bool;

#import "Basic";
#import "Math";
Simp :: #import "Simp";
#import "Window_Creation";
Input :: #import "Input";
Gamepad :: #import "Gamepad-Evan";
Unicode :: #import "Unicode";
#import "GetRect";

#load "ui.jai";
#load "entity.jai";
#load "player.jai";
#load "items.jai";
#load "levels.jai";
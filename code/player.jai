Player_Data :: struct {
  velocity: Vector2;
  friction_modifier: float = 1;
  
  right_blocked: bool;
  left_blocked: bool;
  top_blocked: bool;
  bottom_blocked: bool;
};

Control_Type :: enum {
  KEYBOARD;
  GAMEPAD_1;
  GAMEPAD_2;
  GAMEPAD_3;
  GAMEPAD_4;
};
control_type_strings: [5] string : .["Keyboard",
                                     "Gamepad 1",
                                     "Gamepad 2",
                                     "Gamepad 3",
                                     "Gamepad 4"];

speed: float = 300; // pixels/s^2
jump_force: float = 75; // pixels/s
friction: float = 4; // pixels/s^2

update_player :: (using player: *Entity, delta_time: float) {
  velocity: Vector2;
  multiplier: float;
  if xx control_type == 0 {
    if keys.left && !player_data.left_blocked {
      multiplier -= 1;
    }
    if keys.right && !player_data.right_blocked {
      multiplier += 1;
    }
  }
  else {
    gamepad := Gamepad.gamepads[xx control_type - 1];
    if ((gamepad.left_stick.x < 0 && !player_data.left_blocked) ||
        (gamepad.left_stick.x > 0 && !player_data.right_blocked))
      multiplier = gamepad.left_stick.x;
  }
  velocity.x += speed*multiplier;
  
  if !player_data.bottom_blocked {
    velocity.y -= gravity;
  }
  
  if keys.space && !last_keys.space && player_data.bottom_blocked {
    player_data.velocity.y += jump_force;
  }
  
  velocity.x += -friction*player_data.friction_modifier*player_data.velocity.x;
  
  pos = (0.5*velocity * (delta_time*delta_time) +
         player_data.velocity*delta_time +
         pos);
  player_data.velocity = velocity*delta_time + player_data.velocity;
}

start_collide_player :: (player: *Entity, entity: *Entity, delta_time: float) {
  half_player_size := player.size/2;
  half_entity_size := entity.size/2;
  
  colliding_horz, last_colliding_horz, colliding_vert, last_colliding_vert := entity_collide(player, entity);
  
  if colliding_horz && last_colliding_vert {
    player.player_data.velocity.x = 0;
    
    if player.pos.x < entity.pos.x {
      player.player_data.right_blocked = true;
      player.pos.x = entity.pos.x - half_entity_size.x - half_player_size.x;
    }
    else {
      player.player_data.left_blocked = true;
      player.pos.x = entity.pos.x + half_entity_size.x + half_player_size.x;
    }
  }
  
  if colliding_vert && last_colliding_horz {
    player.player_data.velocity.y = 0;
    
    if player.pos.y < entity.pos.y {
      player.player_data.top_blocked = true;
      player.pos.y = entity.pos.y - half_entity_size.y - half_player_size.y;
    }
    else {
      player.player_data.bottom_blocked = true;
      player.pos.y = entity.pos.y + half_entity_size.y + half_player_size.y;
    }
  }
  
  if entity.type == .PLATFORM {
    player.player_data.friction_modifier = entity.platform_data.modifier;
  }
  
  if entity.type == .TRAP {
    player.active = false;
  }
}

stop_collide_player :: (player: *Entity, entity: *Entity) {
  colliding_horz, last_colliding_horz, colliding_vert, last_colliding_vert := entity_collide(player, entity);
  
  if !colliding_horz {
    if player.pos.x < entity.pos.x player.player_data.right_blocked = false;
    else player.player_data.left_blocked = false;
  }
  
  if !colliding_vert {
    if player.pos.y < entity.pos.y player.player_data.top_blocked = false;
    else player.player_data.bottom_blocked = false;
  }
  
  if entity.type == .PLATFORM {
    player.player_data.friction_modifier = 1;
  }
}

reset_players :: () {
  player_index: s32;
  for 0..(num_entities - 1) {
    using entity := *entities[it];
    if type != .PLAYER continue;
    
    spawn := player_spawns[player_index];
    if !spawn break;
    
    active = true;
    pos = spawn.pos;
    color = spawn.color;
    player_data.velocity = .{0, 0};
    player_data.right_blocked = false;
    player_data.left_blocked = false;
    player_data.top_blocked = false;
    player_data.bottom_blocked = false;
    
    player_index += 1;
  }
}

spawn_players :: () {
  if num_players > 0 return;
  for 0..(num_player_spawns - 1) {
    spawn := player_spawns[it];
    using player := create_entity(spawn.pos, spawn.size, spawn.color, .PLAYER);
    player_id = spawn.player_id;
    control_type = spawn.control_type;
    player_data.velocity = .{0, 0};
    player_data.right_blocked = false;
    player_data.left_blocked = false;
    player_data.top_blocked = false;
    player_data.bottom_blocked = false;
  }
}

delete_players :: () {
  for 0..(num_entities - 1) {
    using entity := *entities[it];
    if type == .PLAYER {
      delete_entity(entity);
    }
  }
  num_players = 0;
}
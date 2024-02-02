Entity :: struct {
  active: bool;
  pos: Vector2;
  last_pos: Vector2;
  size: Vector2;
  color: Vector4;
  
  type: Entity_Type;
  
  player_data: Player_Data;
  player_id: s64; // NOTE: 0-3
  control_type: Control_Type;
  
  platform_data: Platform_Data;
  trap_data: Trap_Data;
  attack_data: Attack_Data;
  
  level: Level;
  
  text_data: Text_Data;
  
  collidable: bool;
  
  entities_colliding_with: [MAX_ENTITIES]s64;
  num_entities_colliding_with: s64;
  
  index: s64;
};

Entity_Type :: enum {
  NONE;
  PLAYER;
  PLAYER_SPAWN;
  PLATFORM;
  TRAP;
  ATTACK;
  LEVEL_SELECT;
  SIGN;
};

create_entity :: (pos: Vector2 = .{0, 0},
                  size: Vector2 = .{1, 1},
                  color: Vector4 = .{1, 1, 1, 1},
                  type: Entity_Type = .NONE) -> *Entity {
  if num_entities == MAX_ENTITIES {
    print("At max entity capacity!\n");
    return null;
  }
  
  entity: *Entity = *entities[num_entities];
  entity.active = true;
  entity.pos = pos;
  entity.size = size;
  entity.color = color;
  entity.type = type;
  entity.index = num_entities;
  entity.collidable = true;
  entity.num_entities_colliding_with = 0;
  
  entity.player_data = .{};
  entity.platform_data = .{};
  entity.trap_data = .{};
  entity.attack_data = .{};
  entity.level = .LEVEL_SELECT;
  entity.text_data = .{};
  
  if type == .PLAYER_SPAWN {
    if num_player_spawns >= MAX_PLAYERS {
      print("At max PLAYER_SPAWN capacity!\n");
      return null;
    }
    
    entity.player_id = num_player_spawns;
    player_spawns[num_player_spawns] = entity;
    num_player_spawns += 1;
  }
  
  if type == .PLAYER num_players += 1;
  num_entities += 1;
  return entity;
}

delete_entity :: (using entity: *Entity) {
  if num_entities == 1 || index == num_entities - 1 {
    num_entities -= 1;
    return;
  }
  
  last := *entities[num_entities - 1];
  last.index = index;
  entities[index] = <<last;
  num_entities -= 1;
}

entity_collide :: (first: *Entity, second: *Entity) -> bool, bool, bool, bool {
  half_first_size := first.size/2;
  half_second_size := second.size/2;
  
  horz_dist := abs(second.pos.x - first.pos.x);
  last_horz_dist := abs(second.last_pos.x - first.last_pos.x);
  colliding_horz := (horz_dist < half_second_size.x + half_first_size.x &&
                     horz_dist > half_second_size.x - half_first_size.x);
  last_colliding_horz := last_horz_dist < half_second_size.x + half_first_size.x;
  
  vert_dist := abs(second.pos.y - first.pos.y);
  last_vert_dist := abs(second.last_pos.y - first.last_pos.y);
  colliding_vert := (vert_dist < half_second_size.y + half_first_size.y &&
                     vert_dist > half_second_size.y - half_first_size.y);
  last_colliding_vert := last_vert_dist < half_second_size.y + half_first_size.y;
  
  return colliding_horz, last_colliding_horz, colliding_vert, last_colliding_vert;
}

Text_Data :: struct {
  color: Vector4;
  text: string;
}

MAX_ENTITIES :: 128;
entities: [MAX_ENTITIES]Entity = ---;
num_entities: s64;

MAX_PLAYERS :: 4;
num_inputs: s64 = 1;
player_spawns: [MAX_PLAYERS]*Entity;
players_using_controller: [MAX_PLAYERS]bool;
num_player_spawns: s64;
num_players: s64;

PLAYER_SPAWN_1_COLOR: Vector4 : .{1, 0, 0, 1};
PLAYER_SPAWN_2_COLOR: Vector4 : .{0, 1, 0, 1};
PLAYER_SPAWN_3_COLOR: Vector4 : .{0, 0, 1, 1};
PLAYER_SPAWN_4_COLOR: Vector4 : .{1, 1, 0, 1};

hovered_entity: s64;
selected_entity: s64;
entity_hovered: bool;
entity_selected: bool;
Platform_Data :: struct {
  type: Platform_Type;
  modifier: float;
}

Platform_Type :: enum {
  BASIC;
  SLOWER;
  SPEEDER;
}

Trap_Data :: struct {
  type: Trap_Type;
  velocity: Vector2;
  time_till_destruction: float;
}

Trap_Type :: enum {
  STATIC;
  ZIPPER;
  LAUNCHER;
}

TRAP_COLOR: Vector4 : .{0, 0, 1, 1};

update_trap :: (using trap: *Entity, delta_time: float) {
  if trap_data.type == {
    case .STATIC; return;
    
    case .ZIPPER;
    pos.x += trap_data.velocity.x*delta_time;
    
    case .LAUNCHER;
    velocity: Vector2 = .{0, -gravity};
    pos = (0.5*velocity * (delta_time*delta_time) +
           trap_data.velocity*delta_time +
           pos);
    trap_data.velocity = velocity*delta_time + trap_data.velocity;
  }
  
  trap_data.time_till_destruction -= delta_time;
  if trap_data.time_till_destruction <= 0 {
    delete_entity(trap);
  }
}

Attack_Data :: struct {
  type: Attack_Type;
  trap_data: Trap_Data;
  cooldown: float;
  current_cooldown: float;
}

Attack_Type :: enum {
  ZIPPER;
  LAUNCHER;
}

update_attack :: (using attack: *Entity, delta_time: float) {
  attack_data.current_cooldown -= delta_time;
  if attack_data.current_cooldown <= 0 {
    trap := create_entity(pos, size, TRAP_COLOR, .TRAP);
    trap.trap_data = attack_data.trap_data;
    
    attack_data.current_cooldown = attack_data.cooldown;
  }
}
Level :: enum {
  LEVEL_SELECT;
  LEVEL_1;
  
  LEVEL_COUNT;
}

level_names: [Level.LEVEL_COUNT] string : .["Level Select",
                                            "Level 1"];

switch_levels :: (level: Level) {
  num_entities = 0;
  num_player_spawns = 0;
  delete_players();
  
  if level == .LEVEL_SELECT
    in_game = false;
  else
    in_game = true;
  
  if level == {
    case .LEVEL_SELECT; level_select();
    case .LEVEL_1; level_1();
  }
  
  if simulation_enabled spawn_players();
}

level_select :: () {
  entity_0 := create_entity(.{370, -5}, .{60, 80}, .{1, 1, 1, 1}, .NONE);
  entity_0.collidable = true;
  entity_1 := create_entity(.{-370, -5}, .{60, 80}, .{1, 1, 1, 1}, .NONE);
  entity_1.collidable = true;
  entity_2 := create_entity(.{100, -34}, .{80, 20}, .{1, 1, 1, 1}, .LEVEL_SELECT);
  entity_2.collidable = true;
  entity_2.level = .LEVEL_1;
  entity_3 := create_entity(.{100, -15}, .{80, 20}, .{1, 1, 1, 1}, .SIGN);
  entity_3.collidable = false;
  entity_3.text_data.text = "Level 1";
  entity_3.text_data.color = .{0, 0, 0, 1};
  entity_4 := create_entity(.{-10, -34}, .{20, 20}, .{1, 0, 0, 1}, .PLAYER_SPAWN);
  entity_4.collidable = false;
  entity_5 := create_entity(.{0, -74}, .{800, 60}, .{1, 1, 1, 1}, .NONE);
  entity_5.collidable = true;
}

level_1 :: () {
  entity_0 := create_entity(.{0, -105}, .{800, 120}, .{1, 1, 1, 1}, .NONE);
  entity_0.collidable = true;
  entity_3 := create_entity(.{370, 16}, .{60, 120}, .{1, 1, 1, 1}, .NONE);
  entity_3.collidable = true;
  entity_4 := create_entity(.{-10, -14}, .{20, 20}, .{1, 0, 0, 1}, .PLAYER_SPAWN);
  entity_4.collidable = false;
}
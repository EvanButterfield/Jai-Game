draw_quad :: (pos: Vector2, size: Vector2, color: Vector4) {
  half_width := size.x / 2;
  half_height := size.y / 2;
  
  Simp.set_shader_for_color();
  Simp.immediate_quad(pos.x - half_width + half_window_width,
                      pos.y - half_height + half_window_height,
                      pos.x + half_width + half_window_width,
                      pos.y + half_height + half_window_height,
                      color);
}

Text :: struct {
  str: string;
  pos: Vector2;
  color: Vector4;
}
text_to_render: [128]Text = ---;
text_to_render_count: s32;
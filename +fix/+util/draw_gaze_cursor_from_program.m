function [tf, debug_window] = draw_gaze_cursor_from_program(program)

debug_window = program.Value.debug_window;
window = program.Value.window;

if ( ~isempty(debug_window) && program.Value.interface.is_debug )  
  gaze_cursor = program.Value.stimuli.gaze_cursor;
  sampler = program.Value.sampler;
  
  fix.util.draw_gaze_cursor( sampler, gaze_cursor, window, debug_window );  
  tf = true;
else
  tf = false;
  debug_window = [];
end

end
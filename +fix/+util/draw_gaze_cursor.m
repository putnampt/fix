function draw_gaze_cursor(sampler, gaze_cursor, window, debug_window)

pixel_coords = ptb.WindowDependent( [sampler.X, sampler.Y] );
norm_coords = as_normalized( pixel_coords, window );

gaze_cursor.Position = norm_coords;
draw( gaze_cursor, debug_window );

end
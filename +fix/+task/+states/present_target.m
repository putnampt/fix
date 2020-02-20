function state = present_target(program, conf)

state = ptb.State();
state.Name = 'present_target';
state.Duration = conf.TIMINGS.time_in.present_target;
state.UserData = struct();

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

% At the start of the state, mark that fixation to the spot was not yet
% acquired; reset the fixation target, such that it has a cumuluative
% looking time of 0s; and draw the fix associated with the target.
%
% Additionally, if we're in debug mode, draw the target bounds.

state.UserData.acquired_fixation = false;

target_obj = program.Value.targets.img1;
stimulus = program.Value.stimuli.img1;
window = program.Value.window;
debug_window = program.Value.debug_window;

[target_duration, target_random_range] = get_target_duration_info( program );
target_obj.Duration = get_target_duration( target_duration, target_random_range );
reset( target_obj );
draw( stimulus, window );

flip( window );

if ( program.Value.is_debug )
  draw( stimulus, debug_window );
  draw( target_obj.Bounds, debug_window );
  flip( debug_window );
end

end

function loop(state, program)

target_obj = program.Value.targets.img1;

if ( target_obj.IsDurationMet )
  % Mark that we successfully acquired fixation.
  state.UserData.acquired_fixation = true;
  % Proceed to the exit() function.
  escape( state );
end

debug_window = program.Value.debug_window;
window = program.Value.window;

if ( ~isempty(debug_window) && program.Value.interface.is_debug )  
  gaze_cursor = program.Value.stimuli.gaze_cursor;
  sampler = program.Value.sampler;
  stimulus = program.Value.stimuli.img1;
  target_obj = program.Value.targets.img1;
  
  draw( stimulus, debug_window );
  draw( target_obj.Bounds, debug_window );
  
  fix.util.draw_gaze_cursor( sampler, gaze_cursor, window, debug_window );  
  
  flip( debug_window );
end

end

function exit(state, program)

states = program.Value.states;

if ( state.UserData.acquired_fixation )
  next( state, states('fix_success') );
else
  next( state, states('fix_error') );
end

end

function [duration, range] = get_target_duration_info(program)

duration = program.Value.stimuli_setup.img1.target_duration;
range = program.Value.stimuli_setup.img1.target_random_range;

end

function dur = get_target_duration(target_duration, target_random_range)

magnitude = target_random_range * (rand() * 2 - 1);
dur = target_duration + magnitude ;

end

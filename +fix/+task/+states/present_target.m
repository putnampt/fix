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

reset( target_obj );
draw( stimulus, window );

if ( program.Value.is_debug )
  draw( target_obj.Bounds, window );
end

flip( window );

end

function loop(state, program)

target_obj = program.Value.targets.img1;

if ( target_obj.IsDurationMet )
  % Mark that we successfully acquired fixation.
  state.UserData.acquired_fixation = true;
  % Proceed to the exit() function.
  escape( state );
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
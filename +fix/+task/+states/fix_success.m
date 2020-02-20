function state = fix_success(program, conf)

state = ptb.State();
state.Name = 'fix_success';
% Remain in this state for at most `image_success` seconds. In this case,
% this is equivalent to specifying how long the stimulus will be shown.
state.Duration = conf.TIMINGS.time_in.image_success;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

window = program.Value.window;
% Draw the stimulus associated with successfully fixating.
success_img = program.Value.stimuli.success_img;

draw( success_img, window );
flip( window );

trigger( program.Value.ni_reward_manager, program.Value.rewards.main );

end

function loop(state, program)

[should_flip, debug_window] = fix.util.draw_gaze_cursor_from_program( program );
if ( should_flip )
  success_img = program.Value.stimuli.success_img;
  draw( success_img, debug_window );
  
  flip( debug_window );
end

end

function exit(state, program)

states = program.Value.states;
next( state, states('iti') );

end
function state = image_error(program, conf)

state = ptb.State();
state.Name = 'image_error';
% Remain in this state for at most `image_error` seconds.
state.Duration = conf.TIMINGS.time_in.image_error;

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)

window = program.Value.window;
% Draw the stimulus associated with failing to fixate.
error_img = program.Value.stimuli.error_img;

draw( error_img, window );
flip( window );

end

function loop(state, program)

end

function exit(state, program)

states = program.Value.states;
next( state, states('new_trial') );

end
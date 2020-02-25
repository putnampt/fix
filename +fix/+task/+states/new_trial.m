function state = new_trial(program, conf)

state = ptb.State();
state.Name = 'new_trial';

state.Entry = @(state) entry(state, program);
state.Loop = @(state) loop(state, program);
state.Exit = @(state) exit(state, program);

end

function entry(state, program)
% Nothing to do right now.

encode_manager = program.Value.ni_digital_encode_manager;

bits = zeros( 1, 16 );
bits([1, 2]) = 1;
bits(:) = 1;

trigger( encode_manager, bits );

end

function loop(state, program)
% Nothing to do right now.
end

function exit(state, program)

states = program.Value.states;
% When `new_trial` is finished, go to the `present_target` state
next( state, states('present_target') );

end
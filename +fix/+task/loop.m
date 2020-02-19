function loop(task, program)

%   LOOP -- Task loop function.
%
%     fix.task.loop( task, program ); is called each frame, and is
%     generally responsible for updating objects that keep track of elapsed
%     time, or which acquire samples of some signal in real time. 
%     
%     `task` is a handle to the `ptb.Task` object managing the sequence of
%     states. `program` is a handle to a `ptb.Reference` object containing
%     global data accessible across states.
%
%     See also fix.task.setup

update( program.Value.frame_timer );
% Acquire new samples from XYSources, and update the cumuluative looking
% time spent in bounds of each target.
update( program.Value.updater );

handle_ni_daq_update( program );

end

function handle_ni_daq_update(program)

if ( ~isempty(program.Value.ni_reward_manager) )
  update( program.Value.ni_reward_manager );
end

if ( ~isempty(program.Value.ni_scan_output) )
  update( program.Value.ni_scan_output );
end

if ( ~isempty(program.Value.ni_scan_input) )
  update( program.Value.ni_scan_input );
end

end

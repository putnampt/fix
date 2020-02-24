function shutdown(program)

% Define any cleanup routines in this function, which is called even in the
% case of error during the task.

path = save_path();

save_data( program, path );


fprintf( '\n Shutting down ...\n' );

end

function path = save_path()

rep_path = repdir;
path = fullfile( rep_path, 'fix/+fix/+data/' );
which path

end

function save_data(program, path)

if( program.Value.interface.save_data )
  try
    program_data = program.Value;
    data_filename = [datestr(datetime, 'yyyy-mm-dd_HH-MM-SS') '-fix-training-data'];
    save([path data_filename], 'program_data');
  catch err
    warning( err.message )
  end
end

end
function start(varargin)

program = fix.task.setup( varargin{:} );
err = [];

try
  fix.task.run( program );
catch err
end

delete( program );

if ( ~isempty(err) )
  rethrow( err );
end

end
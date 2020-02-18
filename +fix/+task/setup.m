function program = setup(conf)

if ( nargin < 1 )
  conf = fix.config.load();
else
  fix.util.assertions.assert__is_config( conf );
end

conf = fix.config.reconcile( conf );
program = make_program( conf );

try
  make_all( program, conf );
  
catch err
  delete( program );
  rethrow( err );
end

end

function make_all(program, conf)

make_task( program, conf );
make_states( program, conf );

window = make_window( program, conf );
updater = make_updater( program );

[stimuli, stim_setup] = make_stimuli( program, window, conf );

sampler = make_sources( program, updater, window, conf );
make_targets( program, window, updater, sampler, stimuli, stim_setup );

end

function program = make_program( conf )

interface = get_interface( conf );

program = ptb.Reference();
program.Value.config = conf;
program.Value.is_debug = interface.is_debug;
program.Value.frame_timer = ptb.FrameTimer();

program.Destruct = @fix.task.shutdown;

end

function make_task(program, conf)

interface = get_interface( conf );
time_in = get_time_in( conf );

task = ptb.Task();

task.Duration = time_in.task;
task.Loop = @(t) fix.task.loop(t, program);

task.exit_on_key_down( interface.stop_key );

program.Value.task = task;

end

function xy_sampler = make_sources(program, updater, window, conf)

source_inputs = {};

if ( window.is_window_handle_valid() )
  source_inputs{end+1} = window;
end

xy_source = updater.create_registered( @ptb.sources.Mouse, source_inputs{:} );
xy_sampler = updater.create_registered( @ptb.samplers.Pass, xy_source );

end

function make_targets(program, window, updater, sampler, stimuli, stim_setup)

stim_names = fieldnames( stim_setup );
named_targets = struct();
all_targets = {};

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  stim_descr = stim_setup.(stim_name);
  
  if ( ~isfield(stim_descr, 'has_target') || ~stim_descr.has_target )
    continue;
  end
  
  stim = stimuli.(stim_name);
  stim_class = class( stim );

  bounds = [];

  switch ( stim_class )
    case 'ptb.stimuli.Rect'
      bounds = ptb.bounds.Rect();
      bounds.BaseRect = ptb.rects.MatchRectangle( stim );       

    otherwise
      error( 'No default bounds class exists for stimulus of class "%s".', stim_class );
  end
  
  if ( isempty(bounds) )
    continue;
  end
  
  if ( isfield(stim_descr, 'padding') )
    bounds.Padding = as_px( stim_descr.padding, window );
  end

  targ = updater.create_registered( @ptb.XYTarget );
  targ.Sampler = sampler;
  targ.Bounds = bounds;
  targ.Duration = stim_descr.target_duration;
  
  named_targets.(stim_name) = targ;
  all_targets{end+1} = targ;
end

program.Value.targets = named_targets;
program.Value.all_targets = all_targets;

end

function make_states(program, conf)

% Create and store references to each state object.
states = containers.Map();
states('new_trial') = fix.task.states.new_trial( program, conf );
states('present_target') = fix.task.states.present_target( program, conf );
states('fix_success') = fix.task.states.fix_success( program, conf );
states('fix_error') = fix.task.states.fix_error( program, conf );

program.Value.states = states;

end

function updater = make_updater(program)

updater = ptb.ComponentUpdater();
program.Value.updater = updater;

end

function window = make_window(program, conf)

window = ptb.Window();
screen_info = get_screen( conf );
interface = get_interface( conf );

window.Rect = screen_info.rect;
window.Index = screen_info.index;
window.SkipSyncTests = interface.skip_sync_tests;

if ( interface.open_window )
  open( window );
end

program.Value.window = window;

end

function image_objects = make_images(program, window, conf)

image_dir = fullfile( stimuli_path(conf), 'images' );
image_files = shared_utils.io.find( image_dir, {'.jpg', '.png'} );
image_matrices = cellfun( @imread, image_files, 'un', 0 );

if ( window.is_window_handle_valid() )
  image_objects = cellfun( @(x) ptb.Image(window, x), image_matrices, 'un', 0 );
else
  % dummy images.
  image_objects = cellfun( @(x) ptb.Image(), image_matrices, 'un', 0 );
end

program.Value.images = image_objects;

end

function [out_stimuli, stim_setup] = make_stimuli(program, window, conf)

% Make a visual stimulus for each field of `STIMULI.setup`, as defined in
% the config file `conf`. `conf` is created in `fix.config.create`, 
% and defines the default property values for each stimulus.
make_images( program, window, conf );

stimuli = get_stimuli( conf );
stim_setup = stimuli.setup;
stim_names = fieldnames( stim_setup );

out_stimuli = struct();

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  curr_stim_setup = stim_setup.(stim_name);
  
  cls = curr_stim_setup.class;
  pos = curr_stim_setup.position;
  scale = curr_stim_setup.size;
  
  stim = [];
  
  switch ( lower(cls) )
    case 'rect'
      stim = ptb.stimuli.Rect();
    case 'oval'
      stim = ptb.stimuli.Oval();
    otherwise
      warning( 'Unrecognized stimuli class "%s".', cls );
  end
  
  if ( isempty(stim) )
    continue;
  end
  
  stim.Position = pos;
  stim.Scale = scale;
  stim.Window = window;
  
  if ( isfield(curr_stim_setup, 'color') )
    stim.FaceColor = curr_stim_setup.color;
  end
  
  out_stimuli.(stim_name) = stim;
end

program.Value.stimuli = out_stimuli;

end


function p = stimuli_path(conf)
p = conf.PATHS.stimuli;
end

function stim = get_stimuli(conf)
stim = conf.STIMULI;
end

function time_in = get_time_in(conf)
time_in = conf.TIMINGS.time_in;
end

function interface = get_interface(conf)
interface = conf.INTERFACE;
end

function screen = get_screen(conf)
screen = conf.SCREEN;
end
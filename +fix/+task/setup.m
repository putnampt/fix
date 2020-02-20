function program = setup(conf)

if ( nargin < 1 )
  conf = fix.config.load();
else
  fix.util.assertions.assert__is_config( conf );
end

conf =  fix.config.reconcile( conf );
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

[window, debug_window] = make_windows( program, conf );
updater = make_updater( program );

ni_session = make_ni_daq_session( program, conf );
ni_scan_input = make_ni_scan_input( program, conf, ni_session );
ni_scan_output = make_ni_scan_output( program, conf, ni_session );
make_reward_manager( program, conf, ni_scan_output )

[stimuli, stim_setup] = make_stimuli( program, window, conf );

tracker = make_eye_tracker( program, updater, ni_scan_input, conf );
sampler = make_gaze_sampler( program, updater, tracker, conf );

make_targets( program, window, updater, sampler, stimuli, stim_setup );

attach_interface( program, conf );

end

function attach_interface(program, conf)

program.Value.interface = get_interface( conf );

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

function tracker = make_eye_tracker(program, updater, ni_scan_input, conf)

interface = get_interface( conf );
source_type = interface.gaze_source_type;

switch ( source_type )
  case 'mouse'
    tracker = ptb.sources.Mouse();
  case 'digital_eyelink'
    tracker = ptb.sources.Eyelink();
    initialize( tracker );
    start_recording( tracker );
  case 'analog_input'
    tracker = make_analog_input_tracker( ni_scan_input, conf );
  otherwise
    error( 'Unrecognized source type "%s".', source_type );
end

updater.add_component( tracker );
program.Value.tracker = tracker;

end

function tracker = make_analog_input_tracker(ni_scan_input, conf)

tracker = ptb.sources.XYAnalogInput( ni_scan_input );
tracker.CalibrationRect = conf.SCREEN.calibration_rect;
tracker.OutputVoltageRange = [-5, 5];
tracker.CalibrationRectPaddingFract = [0.2, 0.2];
tracker.ChannelMapping = [1, 2];

end

function sampler = make_gaze_sampler(program, updater, tracker, conf)

sampler = ptb.samplers.Pass();
sampler.Source = tracker;

updater.add_component( sampler );

program.Value.sampler = sampler;

end

function make_targets(program, window, updater, sampler, targets, stim_setup)

stim_names = fieldnames( stim_setup );
named_targets = struct();
all_targets = {};

for i = 1:numel(stim_names)
  stim_name = stim_names{i};
  stim_descr = stim_setup.(stim_name);
  
  if ( ~isfield(stim_descr, 'has_target') || ~stim_descr.has_target )
    continue;
  end
  
  stim = targets.(stim_name);
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
    if ( ~isa(stim_descr.padding, 'ptb.WindowDependent') )
      bounds.Padding = stim_descr.padding;
    else
      bounds.Padding = as_px( stim_descr.padding, window );
    end
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
states('iti') = fix.task.states.iti( program, conf );

program.Value.states = states;

end

function updater = make_updater(program)

updater = ptb.ComponentUpdater();
program.Value.updater = updater;

end

function [window, debug_window] = make_windows(program, conf)

window = ptb.Window();
screen_info = get_screen( conf );
interface = get_interface( conf );

window.Rect = screen_info.rect;
window.Index = screen_info.index;
window.SkipSyncTests = interface.skip_sync_tests;

if ( interface.use_debug_window )
  debug_window = ptb.Window();
  debug_window.Rect = screen_info.debug_rect;
  debug_window.Index = screen_info.debug_index;
  debug_window.SkipSyncTests = interface.skip_sync_tests;
else
  debug_window = [];
end

if ( interface.open_window )
  open( window );
end

if ( interface.use_debug_window )
  open( debug_window );
end

program.Value.window = window;
program.Value.debug_window = debug_window;

end

function [out_stimuli, stim_setup] = make_stimuli(program, window, conf)

% Make a visual stimulus for each field of `STIMULI.setup`, as defined in
% the config file `conf`. `conf` is created in `fix.config.create`, 
% and defines the default property values for each stimulus.

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
program.Value.stimuli_setup = stim_setup;

end

function ni_session = make_ni_daq_session(program, conf)

signal = get_signal( conf );

ni_session = daq.createSession( 'ni' );
ni_device_id = pct.util.get_ni_daq_device_id();

m1_channel_x = signal.analog_channel_m1x;
m1_channel_y = signal.analog_channel_m1y;

channels = { m1_channel_x, m1_channel_y };

for i = 1:numel(channels)
  addAnalogInputChannel( ni_session, ni_device_id, channels{i}, 'Voltage' );
end

addAnalogOutputChannel( ni_session, ni_device_id, 0, 'Voltage' );

program.Value.ni_session = ni_session;
program.Value.ni_device_id = ni_device_id;

end

function ni_scan_input = make_ni_scan_input(program, conf, ni_session)

ni_scan_input = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_input = [];
  return
end

ni_scan_input = ptb.signal.SingleScanInput( ni_session );
program.Value.ni_scan_input = ni_scan_input;

end

function ni_scan_output = make_ni_scan_output(program, conf, ni_session)

ni_scan_output = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_output = [];
  return
end

ni_scan_output = ptb.signal.SingleScanOutput( ni_session );
program.Value.ni_scan_output = ni_scan_output;

end

function make_reward_manager(program, conf, ni_scan_output)

rewards = get_rewards( conf );
signal = get_signal( conf );

channel_index = signal.primary_reward_channel_index;
reward_manager = ptb.signal.SingleScanOutputPulseManager( ni_scan_output, channel_index );

program.Value.ni_reward_manager = reward_manager;
program.Value.rewards = rewards;

end

function rewards = get_rewards(conf)
rewards = conf.REWARDS;
end

function signal = get_signal(conf)
signal = conf.SIGNAL;
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
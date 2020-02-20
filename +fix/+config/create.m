
function conf = create(do_save)

%   CREATE -- Create the config file. 
%
%     Define editable properties of the config file here.

if ( nargin < 1 ), do_save = false; end

const = fix.config.constants();

conf = struct();

% ID
conf.(const.config_id) = true;

% PATHS
PATHS = struct();
PATHS.repositories = fileparts( fix.util.get_project_folder() );
PATHS.stimuli = fullfile( fix.util.get_project_folder(), 'stimuli' );

% DEPENDENCIES
DEPENDS = struct();
DEPENDS.repositories = { 'ptb_helpers', 'ptb', 'shared_utils' };

%	INTERFACE
INTERFACE = struct();
INTERFACE.stop_key = ptb.keys.esc();
INTERFACE.use_mouse = true;
INTERFACE.open_window = true;
INTERFACE.skip_sync_tests = false;
INTERFACE.is_debug = true;
INTERFACE.use_debug_window = false;
INTERFACE.gaze_source_type = 'mouse';

%	SCREEN
SCREEN = struct();

SCREEN.full_size = get( 0, 'screensize' );
SCREEN.index = 0;
SCREEN.background_color = [ 0 0 0 ];
SCREEN.rect = [ 0, 0, 400, 400 ];
SCREEN.debug_index = 1;
SCREEN.debug_rect = [0, 0, 400, 400];
SCREEN.calibration_rect = [0, 0, 400, 400];

%	TIMINGS
TIMINGS = struct();

time_in = struct();
time_in.task = inf;
time_in.new_trial = 0;
time_in.present_image = 2;
time_in.image_success = 1;
time_in.image_error = 1;
time_in.iti = 1;

TIMINGS.time_in = time_in;

%	STIMULI
STIMULI = struct();
STIMULI.setup = struct();

STIMULI.setup.img1 = struct( ...
    'class',            'Rect' ...
  , 'position',         ptb.WindowDependent( 0.5, 'normalized' ) ...
  , 'size',             ptb.WindowDependent( 100, 'px' ) ...
  , 'color',            set( ptb.Color(), [0, 255, 255] ) ...
  , 'has_target',       true ...
  , 'padding',          ptb.WindowDependent( 50, 'px' ) ...
  , 'target_duration',  0.3 ...
  , 'target_random_range', 0 ...
);

STIMULI.setup.success_img = struct( ...
    'class',      'Rect' ...
  , 'position',   ptb.WindowDependent( 0.5, 'normalized' ) ...
  , 'size',       ptb.WindowDependent( 100, 'px' ) ...
  , 'has_target', false ...
  , 'color',      set( ptb.Color(), [0, 255, 0] ) ...
);

STIMULI.setup.error_img = struct( ...
    'class',      'Rect' ...
  , 'position',   ptb.WindowDependent( 0.5, 'normalized' ) ...
  , 'size',       ptb.WindowDependent( 100, 'px' ) ...
  , 'has_target', false ...
  , 'color',      set( ptb.Color(), [0, 0, 255] ) ...
);

STIMULI.setup.gaze_cursor = struct( ...
    'class',      'Oval' ...
  , 'position',   ptb.WindowDependent( 0.5, 'normalized' ) ...
  , 'size',       ptb.WindowDependent( 100, 'px' ) ...
  , 'has_target', false ...
  , 'color',      set( ptb.Color(), [255, 255, 255] ) ...
);

% SIGNAL
SIGNAL = struct();
SIGNAL.analog_channel_m1x = 'ai0';
SIGNAL.analog_channel_m1y = 'ai1';
SIGNAL.primary_reward_channel_index = 1;

% REWARDS
REWARDS = struct();
REWARDS.main = 0.3;

% EXPORT
conf.PATHS = PATHS;
conf.DEPENDS = DEPENDS;
conf.TIMINGS = TIMINGS;
conf.STIMULI = STIMULI;
conf.SCREEN = SCREEN;
conf.INTERFACE = INTERFACE;
conf.SIGNAL = SIGNAL;
conf.REWARDS = REWARDS;

if ( do_save )
  fix.config.save( conf );
end

end
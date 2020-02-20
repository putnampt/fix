Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = fix.config.reconcile( fix.config.load() );

% Set the timing for each states
conf.TIMINGS.time_in.present_target = 3;
conf.TIMINGS.time_in.fix_success = 0.5;
conf.TIMINGS.time_in.fix_error = 0.5;
conf.TIMINGS.time_in.iti = 6;

% Set up the parameters of the fixation spot
conf.STIMULI.setup.img1.target_duration = 0.3;
conf.STIMULI.setup.img1.target_random_range = 0.3;
conf.STIMULI.setup.img1.size = 100;
conf.STIMULI.setup.img1.padding = 50;
conf.STIMULI.setup.img1.color  = [225,225,225];

% Set up the color of the success and error spots
conf.STIMULI.setup.success_img.color = [0, 255, 0];
conf.STIMULI.setup.error_img.color = [255,127,80];

% Set the size of the gaze cursor
conf.STIMULI.setup.gaze_cursor.size = 10;

% Set the meta-information for the subject
conf.META.subject = 'Lynch';

% Set the parameters for the eye tracker
% conf.INTERFACE.gaze_source_type = 'analog_input';
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
% conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.reward_output_type = 'ni'; 
% conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.use_debug_window = true;

% Configure the MONKEY SEE screen
conf.SCREEN.index = 4;
conf.SCREEN.rect = [];
conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

% Configure the MONKEY DO screen
conf.SCREEN.debug_index = 2;
conf.SCREEN.debug_rect = [1600, 0, 1600+1280, 1024];

% Set the reward length
conf.REWARDS.main = 0.1;

% Start the task
fix.task.start( conf );
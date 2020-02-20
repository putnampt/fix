Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = fix.config.reconcile( fix.config.load() );

conf.TIMINGS.time_in.present_target = 3;
conf.TIMINGS.time_in.fix_success = 1;
conf.TIMINGS.time_in.fix_error = 1;
conf.TIMINGS.time_in.iti = 1;

conf.STIMULI.setup.img1.target_duration = 0.3;
conf.STIMULI.setup.img1.target_random_range = 0.3;
conf.STIMULI.setup.img1.size = 100;
conf.STIMULI.setup.img1.padding = 50;

conf.STIMULI.setup.success_img.color = [255, 0, 0];

conf.STIMULI.setup.gaze_cursor.size = 10;

conf.META.subject = 'Lynch';

% conf.INTERFACE.gaze_source_type = 'analog_input';
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
% conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.reward_output_type = 'ni'; 
% conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;
conf.INTERFACE.use_debug_window = true;

conf.SCREEN.index = 4;
conf.SCREEN.rect = [];
conf.SCREEN.calibration_rect = [0, 0, 1280, 1024];

conf.SCREEN.debug_index = 2;
conf.SCREEN.debug_rect = [1600, 0, 1600+1280, 1024]
conf.REWARDS.main = 0.1;

fix.task.start( conf );
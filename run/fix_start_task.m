Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = fix.config.reconcile( fix.config.load() );

conf.TIMINGS.time_in.fixation = 1;
conf.TIMINGS.time_in.juice_reward = 1;
conf.TIMINGS.time_in.present_target = 1;
conf.TIMINGS.time_in.fix_success = 1;
conf.TIMINGS.time_in.fix_error = 1;

conf.META.subject = 'Lynch';

% conf.INTERFACE.gaze_source_type = 'analog_input';
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
% conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.reward_output_type = 'ni'; 
% conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;

conf.SCREEN.index = 0;
conf.SCREEN.rect = [1600, 0, 1600+1024, 768];
conf.SCREEN.calibration_rect = conf.SCREEN.rect;

fix.task.start( conf );
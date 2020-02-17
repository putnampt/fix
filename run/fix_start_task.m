Screen( 'Preference', 'VisualDebuglevel', 0 );

conf = fix.config.reconcile( fix.config.load() );

conf.TIMINGS.time_in.fixation = 10;
conf.TIMINGS.time_in.juice_reward = 1;

conf.META.subject = 'Lynch';

% conf.INTERFACE.gaze_source_type = 'analog_input';
conf.INTERFACE.gaze_source_type = 'digital_eyelink';
% conf.INTERFACE.gaze_source_type = 'mouse';
conf.INTERFACE.reward_output_type = 'ni'; 
% conf.INTERFACE.reward_output_type = 'none'; 
conf.INTERFACE.skip_sync_tests = true;

conf.DEBUG_SCREEN.is_present = true;
conf.DEBUG_SCREEN.index = 0;
conf.DEBUG_SCREEN.background_color = [ 0 0 0 ];
conf.DEBUG_SCREEN.rect = [ 1600, 0, 1600 + 1280, 1024 ];

fix.task.start( conf );
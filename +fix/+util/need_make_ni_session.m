function tf = need_make_ni_session(conf)
tf = strcmp( conf.INTERFACE.reward_output_type, 'ni' ) || ...
  is_analog_input_gaze_source( conf );
end
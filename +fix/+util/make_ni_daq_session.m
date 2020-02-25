function ni_session = make_ni_daq_session(program, conf)

ni_session = [];
signal = get_signal( conf );

if ( ~need_make_ni_session(conf) )
  program.Value.ni_session = ni_session;
  program.Value.ni_device_id = '';
  return
end

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


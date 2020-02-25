function ni_scan_input = make_ni_scan_input(program, conf, ni_session)

ni_scan_input = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_input = [];
  return
end

ni_scan_input = ptb.signal.SingleScanInput( ni_session );
program.Value.ni_scan_input = ni_scan_input;

end

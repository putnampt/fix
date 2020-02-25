
function ni_scan_output = make_ni_scan_output(program, conf, ni_session)

ni_scan_output = [];
if ( isempty(ni_session) )
  program.Value.ni_scan_output = [];
  return
end

ni_scan_output = ptb.signal.SingleScanOutput( ni_session );
program.Value.ni_scan_output = ni_scan_output;

end

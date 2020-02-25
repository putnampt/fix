function [success] = encode(program,strobe_int)
%ENCODE Sends interger encode out through NI card to Plexon over digital strobe
%   Detailed explanation goes here
success = true;

ni_session = program.Value.ni_session;

binary = decimalToBinaryVector(strobe_int,8);
stobe = [fliplr(binary), [1]];

outputSingleScan(ni_session,stobe)



end


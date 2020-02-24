function [code_time] = time_sync(program)
%time_sync Sends a 16-bit time pulse to Plexon at the time called, only works between 11:00:00AM and 5:55:36PM
% Returns empty if fails. 

%  Largest number you can send with 16 bits --> 65536
%  Pulse code =  H M M S S
%
% Hour can only be single digit so needs to be modified.
%
% 11AM = 0 ----> Earliest time is 11:00:00
% 12PM = 1
% 13PM = 2
% 14PM = 3
% 15PM = 4
% 16PM = 5
% 17PM = 6 ----> Max Time is 5:55:36

% Call current time
code_time = fix(clock);

% Get the hour and offset it by 11 to convert to single digit
h = code_time(4)-11;

if h > 6
    h = 6;
end

% Get the minute(s)
m = code_time(5);

if h == 6 && m > 55
    m = 55;
end

% Get the second(s)
s = code_time(6);

if h == 6 && m == 55 && s > 36
    s = 36;
end

pulse_str = sprintf('%01d%02d%02d', h,m, s);
pulse_int = num2str(pulse_str);

try 
    encode(program, pulse_int)
catch err
    code_time = [];
end


end


%% DECLARATIONS AND INITIALIZATIONS
% convert a table of behavioral bouts to a matrix of one second bins.
% The source data are organized in a set of 3 columns with start, end, and
% duration of each behavior.  The total number of columns == # of behavior
% x3.
% Requires a table of behavioral bouts (latency), and the duration of the
% test (test_dur) and the duration of source video (vid_dur).

function [sec_bins] = lat2sec(latency, test_dur, vid_dur)

%% translate starts and finishes in the latency matrix to 1sec bins in "sec_bins"
latency_r = round(latency);
sec_bins = zeros (vid_dur,7);

% initiallize source (a,b) and target (k,l) indecies
a = 1; b = 1;
k = 1;l = 1;

% find the end of the rounded latency file
final_ro = size(latency_r, 1);
final_co = size(latency_r, 2);

% enter data from rounded latency into "sec_bins"
% initialize c
c = latency_r(a, b);

while b < final_co;   
    % see if the next number is within the source matrix and non-zero 
    while (a <= final_ro) && (latency_r (a,b) ~= 0) && (latency_r(a,b+1)~=0); 
        c = latency_r(a, b);
        d = latency_r(a, b+1);
        sec_bins(c:d, l) = 1;
        a = a+1; % move down row by row
    end
    a = 1; % reset row numbers for the next behavior
    k = 1;
    b = b+3;
    l = l+1;
end

% remove extra data
sec_bins = sec_bins (1:test_dur,:); %trim data beyond test duration

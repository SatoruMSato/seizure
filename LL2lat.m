
%% DECLARATIONS AND INITIALIZATIONS

% converts behavioral scoring data found in the path data exported from Limelight
% to a table of latency to each bout of beh.
% Requires source data (data), real offset value (osr) from LimeLight, and
% matrix size info (last_r, last_c).

% Author: Satoru M. Sato

function [latency] = LL2lat(data, osr, last_r, last_c)

%% Extract behavioral data

time = data (:,1);
data_d = data (:,2:8);

% add "0s" at top
z = zeros (1,7);
data_d = cat (1, z, data_d);

% run diff
data_d = diff (data_d);

% put it back together
data_d = cat (2, time, data_d);

% initiallize source (x,y) and target (i,j) indecies
x = 1;
y = 2;
i = 1;
j = 1;

beh_on = 0;

while y <= last_c;
    while x <= last_r 
        if data_d (x, y) == 1;
            latency (i, j) = data_d (x, 1);
            beh_on = 1;
        elseif data_d (x, y) == -1;
            latency (i, j+1) = data_d (x, 1);
            i = i+1;
            beh_on = 0;
        else
        end 
        x = x+1; 
    end
    
    if beh_on == 1; 
        latency (i, j+1) = data (last_r, 1);
    else
    end
    y = y+1; 
    j = j+3; 
    x = 1; 
    i = 1;
end

%% adjust latency file time
st = 1;
last_ro = size (latency,1);
last_col = size (latency, 2);

while st < last_col;
    latency (:,st:st+1) = latency(:,st:st+1) - osr;
    st = st + 3;
end

% need to remove bouts before start
i = 1;
j = 1;

while j < last_col;
    if max(latency(:,j))>0 && latency (i,j) <= 0;
        [x,y] = find (latency(:,j)>0,1, 'first');
        B = latency(:,j:j+1);
        B = circshift(B,-x+1);
        latency(:,j:j+1)= B;
    end
    j = j +3;
    i = 1;
end
 
% remove -osr values    
latency(latency <0) = 0; 

% calculate durations
dur = 3;
while dur <= size(latency, 2) + 1;
latency (:,dur) = latency (:,dur-1)-latency (:,dur-2);
dur = dur + 3;
end
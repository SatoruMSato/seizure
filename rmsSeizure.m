%% DECLARATIONS AND INITIALIZATIONS

% Amplitude (RMS)-based seizure detection.
% This will compare RMS to BL, and decide if mean RMS is over a threshold
% Requires source data (x), baseline amplitude (blRMS), window size (wRMSseiz),
% overlap (oRMSseiz), threshold (thRMS), and the number of channels in the
% source data (ch).  "thRMS" should have "ch" columns.  The output (rms_over_bl)
% is a matrix of detected seizure at source data sampling frequency (1Hz assumed),
% while "rms_onset" is a table of starts/ends/durations.

function [rms_over_bl, rms_onset] = rmsSeizure (x, blRMS, wRMSseiz, oRMSseiz, thRMS, ch)

% define window size (sec)
w = wRMSseiz;
% define overlap (sec)
o = oRMSseiz;

% calculate step size (sec)
delta = w - o;

% calculate mean of RMS for bl
ave_bl = mean(blRMS,1); 

% define cutoff
co = ave_bl*thRMS;

% calculate number of window
r_size = size (x, 1);       % number of rows of the original data
num_win = floor((r_size-w)/delta); % num_win is the max number of full windows

% append last rows to x, so that "num_win" == r_size
x(r_size+1:r_size+w,:)=repmat(x(r_size,:),w,1);
num_win = num_win + w; % adjust num_win for appended end

% initialize window index
win_ind = 1;

% calculate the means for each window, enter into the target matrix
for win_ind = 1:num_win
    strt = win_ind * delta - delta +1;
    win = x (strt:(strt + w),:);      % define the data range
    y = mean (win, 1);
    
    sig = y > co;   % see if the values are over bl defined above
    
    if win_ind == 1 % deal w/ first row
        ave_RMS = y; % mean RMS for the window
        over_bl = sig; % over threshold or not
    else
        ave_RMS = cat (1, ave_RMS, y);
        over_bl = cat (1, over_bl, sig);
    end
    
    win_ind = win_ind + 1; % append to window index
end

%% create a matrix containing the start & end of seizure 
% detected by RMS
% add "0s" at top
z1 = zeros (1,ch);
over_bl0 = cat (1, z1, over_bl); 

% run diff
over_bl_d = diff (over_bl0);

% now, go though "over_bl_d" and detect start & finish
% initiallize source(k, l) and target(i,j)
k = 1; l = 2;
i = 1; j = 1;

% create a new matrix the new data is stored in, "onset"
onset = zeros(i,j);

% detect the end of file
last_r_s = size(over_bl_d, 1);
last_c_s = size(over_bl_d, 2)+1;

% create time variable
t1 = 1:1:last_r_s;
t1 = t1';

% make "t1" the first column of over_bl_d
over_bl_dt = cat (2, t1, over_bl_d);
seiz_on = 0;

while l <= last_c_s;
    while k <= last_r_s 
        if over_bl_dt (k, l) == 1;
            onset (i, j) = over_bl_dt (k, 1);
            seiz_on = 1;
        elseif over_bl_dt (k, l) == -1;
            onset (i, j+1) = over_bl_dt (k, 1);
            i = i+1;
            seiz_on = 0;
        else
        end 
        k = k+1; % move to the next row 
    end
    
    if seiz_on == 1; % make sure you have an end time for last bout
        onset (i, j+1) = r_size; % over_bl (last_r_s, 1);
    else
    end
    l = l+1; % move to the next column
    j = j+3; % over to next beh
    k = 1; % reset row
    i = 1;
end

% calculate durations
dur = 3;
while dur <= size(onset, 2) + 1;
onset (:,dur) = onset (:,dur-1)-onset (:,dur-2);
dur = dur + 3;
end

rms_onset = onset;
rms_over_bl = over_bl;
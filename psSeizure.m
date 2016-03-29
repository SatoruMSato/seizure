%% DECLARATIONS AND INITIALIZATIONS

% Power spectrum (PS)-based seizure detection.
% This will compare PS to BL, and decide if mean PS is over a threshold
% Requires source data (x), baseline amplitude (blPS), window size (wPS),
% overlap (oPS), threshold (thPS), and the number of channels in the
% source data (ch).  The output (ps_over_bl)is a matrix of detected seizures
% at source data sampling frequency (1Hz assumed),while "rms_onset" is 
% a table of starts/ends/durations.

function [ps_over_bl, ps_onset] = psSeizure (x, blPS, wPS, oPS, thPS, ch)
%% Power spectrum-based seizure detection
% determines the seizure onset/end based on specific criteria in PS

% calculate step size (bin)
delta = wPS - oPS;

% calculate mean PMS for bl
ave_bl = mean (blPS,1); 

% create cutoff value vector
co=thPS; % 1:ch, 2:freq. range

% calculate number of window
r_size = size (x, 1);       % number of rows of the original data
num_win = floor((r_size-wPS)/delta); % num_win is the max number of full windows

% append last rows to x, so that "num_win"=r_size
x(r_size+1:r_size + wPS,:,:)=repmat(x(r_size,:,:),wPS,1,1);
num_win = num_win + wPS;

% initialize window index
win_ind = 1;

% Go through the matrix, find the sections over cutoff, and create
% new matrix containing onset/end info
for win_ind = 1:num_win
    strt = win_ind * delta - delta +1;
    win = x (strt:(strt + wPS),:,:); % define the data range
    y = mean (win, 1);
    y = permute (y,[3 2 1]); % 1: ch, 2: freq. range, 3: time
    sig = y > co; %
    
    if win_ind == 1
        ave_power = y;      
        over_bl = sig;
    else
        ave_power = cat (3, ave_power, y);
        over_bl = cat (3, over_bl, sig); 
    end
    win_ind = win_ind + 1;       % append to window index
end

ave_power=permute(ave_power,[3 2 1]);
over_bl=permute(over_bl,[3 2 1]); %now 1:time, 2:freq. range, 3:ch
    
%% create a matrix containing the start & end of seizure 
% detected by PSD
% add "0s" at top
z1 = zeros (1,5,ch);
over_bl0 = cat (1, z1, over_bl);

% run diff
over_bl_d = diff (over_bl0);

% now, go though "over_bl_d" and detect start & finish
% initiallize source(k, l, m) and target(i, j, h) indicies
k = 1; l = 2; m = 1;
i = 1; j = 1; h = 1;

% detect the end of file
last_r_s = size(over_bl_d, 1); % time
last_c_s = size(over_bl_d, 2)+1; % freq. ranges, +1 for appended time col
last_h_s = size(over_bl_d, 3); % ch

% create time variable
t1 = 1:1:last_r_s;
t1 = 5*t1'; % need to add 0s at top?
t1 = repmat(t1,1,1,ch);

% make "t1" the first column of over_bl_d
over_bl_dt = cat (2, t1, over_bl_d);
over_bl_on = 0;

s_onset=zeros(1,5,ch);

% start the while loop
while m <= last_h_s; % going through layer (3rd dimention or ch/H-C)
        while l <= last_c_s; % going through columns
            while k <= last_r_s % going through rows
                if over_bl_dt (k, l, m) == 1;
                    s_onset (i, j, h) = over_bl_dt (k, 1, m);
                    over_bl_on = 1;
                elseif over_bl_dt (k, l, m) == -1;
                    s_onset (i, j+1, h) = over_bl_dt (k, 1, m);
                    i = i+1;
                    over_bl_on = 0;
                else
            end 
            k = k+1; % move to the next row 
        end
        if over_bl_on == 1; % make sure you have an end time for last bout
            s_onset (i, j+1, h) = r_size*5; % over_bl (last_r_s, 1);
        else            
        end
        
        dur = 3;
        while dur <= size(s_onset, 2) + 1;
        s_onset (:,dur,h) = s_onset (:,dur-1,h)- s_onset (:,dur-2,h);
        dur = dur + 3;        
        end
        
        dur=3;
        l = l+1; % move to the next column
        j = j+3; % over to next beh
        k = 1; i = 1;
        end
    m=m+1; h=h+1;
    l=2; j=1;
    k=1; i=1;
end

ps_onset = s_onset;
ps_over_bl = over_bl;

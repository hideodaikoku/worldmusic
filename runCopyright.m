beep off;
close all;
Screen('Preference', 'SkipSyncTests', 1);
screenNumbers = Screen('Screens');

fprintf('Found Screen: %d\n',screenNumbers(end));

%% make directory and IDname
% get the input
input_result = input('Participant ID: ', 's');
% get the ID
namestr = input_result;
% experiment name
expstr = 'Copyright';
% pattern list
pattern_list = {'Normal', 'Beat', 'Pitch'};

this_directory = dir('runCopyright.m');
if ispc
   save_dir = char(strcat(this_directory.folder,'\data\',expstr,'\',namestr,'\'));
elseif ismac
   save_dir = char(strcat(this_directory.folder,'/data/',expstr,'/',namestr,'/'));
end

% if save directory does not exist, make it
if not(exist(save_dir))
   mkdir(save_dir)
end

%% settings for exp
% number of channels
nrchannels = 2;
% number of trials per block
Ntrials = 24; % 24
% number of blocks
Nblocks = 2; % 2
% number of patterns
Npatterns = 1; % 3
% string array for stimuli
[songstr, music_dir] = scanFilesFromDir('Copyright_stimuli');
% pairs of stimuli
[nonrelated_stimuli, related_stimuli] = mix_copyright(length(songstr));

%% settings for psych
% keyboard unable
ListenChar(2);
AssertOpenGL;
% keyboard unicode
KbName('UnifyKeyNames');
rng('shuffle');
InitializePsychSound
% font size
fontsize = 50;

%make fixation cross line
FixCr = ones(200,200) * 127;
FixCr(90:110, :) = 255;
FixCr(:, 90:110) = 255;

% initialize color name
white = [255 255 255];
gray = [127 127 127];

%% exp
try
   try
      pahandle = PsychPortAudio('Open', [], [], 0, 44100, nrchannels);
      disp('get pahandle');
   catch
      psychlasterror('reset');
      pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
   end
   
   PsychPortAudio('Volume', pahandle, 0.7);
   
   [window, windowRect] = Screen('OpenWindow', screenNumbers(end), gray);
   fixcross = Screen('MakeTexture', window, FixCr);
   
   if ismac
      allFonts = FontInfo('Fonts');
      foundfont = 0;
      for idx = 1:length(allFonts)
         if strcmpi(allFonts(idx).name, 'Hiragino Sans W3')
            foundfont = 1;
            break;
         end
      end
      
      if ~foundfont
         error('Could not find wanted japanese font on OS/X !');
      end
      Screen('TextFont', window, allFonts(idx).number);
   elseif ispc
      Screen('TextFont', window, 'YuGothic Medium');
   end
   
   Screen('TextSize', window, fontsize);
   
   for pattern = 1:Npatterns
      % shuffle the pairs of stimuli
      nonrelated_stimuli_afterShuffle = nonrelated_stimuli(randperm(length(nonrelated_stimuli)),:);
      nonrelated_stimuli_afterShuffle = nonrelated_stimuli_afterShuffle(randperm(34),:);
      related_stimuli_afterShuffle = related_stimuli(randperm(length(related_stimuli)),:);
      stimuli_order = [nonrelated_stimuli_afterShuffle; related_stimuli_afterShuffle];
      stimuli_order = stimuli_order(randperm(length(stimuli_order)),:);
      
      % get day
      daystr = datestr(clock,'yyyymmdd_HHMM');
      % file name at save
      fileName = [namestr, '_', expstr, '_', daystr, '_'];
      % array of results
      results = {};
      
      for block = 1:Nblocks
         % hide mouse cursor
         HideCursor;
         
         areyouready = double('準備はいいですか?');
         DrawFormattedText(window, areyouready, 'center', 'center', white);
   %       DrawFormattedText(window, 'Are you ready?\n(Press any key)', 'center', 'center', white);
         Screen('Flip', window);

         % wait for mouse click
         [x, y, buttons] = GetMouse(window);

         while ~any(buttons) % wait for press
            [x,y,buttons] = GetMouse(window);
         end
         while any(buttons) % wait for release
            [x,y,buttons] = GetMouse(window);
         end

         WaitSecs(1);

         fprintf('!!!WILL START EXPERIMENT!!!\n');

         for trial = 1:Ntrials
            % get WAV file name
            first_stimuli = songstr(stimuli_order((block-1)*Ntrials+trial,1));
            second_stimuli = songstr(stimuli_order((block-1)*Ntrials+trial,2));
            if ispc
               audioFileName1 = char(strcat(music_dir, '\', first_stimuli));
               audioFileName2 = char(strcat(music_dir, '\', second_stimuli));
            elseif ismac
               audioFileName1 = char(strcat(music_dir, '/', first_stimuli));
               audioFileName2 = char(strcat(music_dir, '/', second_stimuli));
            end

            Screen('DrawTexture', window, fixcross);
            Screen('Flip', window);

            % make a fixation cross in the background window
            Screen('DrawTexture', window, fixcross);
            % flip window (the background becomes the foreground)
            Screen('Flip', window);

            [wavWave1, waveFs] = psychwavread(audioFileName1);
            [wavWave2, waveFs] = psychwavread(audioFileName2);
            wavdata1 = wavWave1';
            wavdata2 = wavWave2';

            fprintf('-----\nPLAYING %s & %s\n', string(first_stimuli), string(second_stimuli));

            PsychPortAudio('FillBuffer', pahandle, wavdata1);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop', pahandle, 1);

            WaitSecs(1);

            PsychPortAudio('FillBuffer', pahandle, wavdata2);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop', pahandle, 1);

            Screen('Flip', window);

            freeze_time = 800/1000;

            % wait freeze_time secs
            WaitSecs(freeze_time);

            ShowCursor;
            t1 = GetSecs;
            % get the VAS scale result
            [resp, rt] = hb_scaleResponseCopyright(window, windowRect, 1);
            rt = rt - t1;
            % append trial num, audio name, VAS result
            results(trial, :) = {trial, first_stimuli, second_stimuli, resp, rt};
         end

         if block ~= Nblocks
            DrawFormattedText(window, double('休憩をとってください'), 'center', 'center');
            %          DrawFormattedText(window, 'Please take a break', 'center', 'center');
            Screen('Flip', window);

            fprintf('-----\n!!!PRESS ENTER KEY TO RESUME TO EXPERIMENT!!!\n-----\n');

            KbWait;
         end
      end
      
      % change cell to table
      results = cell2table(results, 'VariableNames', {'TrialNum', 'First_Songname', 'Second_Songname', 'ScaleRating', 'ReactTime'});
      writetable(results,[save_dir,fileName,pattern_list(pattern),'.csv']);

      fprintf('-----\nSAVED FILE\n');
      
      if pattern ~= Npatterns
         DrawFormattedText(window, double('休憩をとってください'), 'center', 'center');
         %          DrawFormattedText(window, 'Please take a break', 'center', 'center');
         Screen('Flip', window);

         fprintf('-----\n!!!PRESS ENTER KEY TO RESUME TO EXPERIMENT!!!\n-----\n');

         KbWait;
      end
   end
   
   PsychPortAudio('Close', pahandle);
   
   % close psychtoolbox
   Screen('CloseAll');
   ListenChar(0);
   ShowCursor;
   
   if ispc
      winopen(save_dir);
   elseif ismac
      system(['open ', save_dir]);
   end
   
catch
   Screen('CloseAll');
   ListenChar(0);
   ShowCursor;
   psychrethrow(psychlasterror);
end

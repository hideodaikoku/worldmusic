beep off;
close all;
Screen('Preference', 'SkipSyncTests', 0);
screenNumbers = Screen('Screens');
whichScreen = screenNumbers(end);

fprintf('Found Screen: %d\n',whichScreen);

%% make directory and IDname
% get the input
input_result = input('ENTER PARTICIPANT ID: ', 's');
input_result1 = input('WHICH LANGUAGE DO YOU WANT? JAPANESE(J) OR ENGLISH(E)? (ANSWER WITH J OR E): ', 's');
% get the ID
namestr = input_result;
languagestr = input_result1;
% experiment name
expstr = 'Worldmusic';

this_directory = dir('runWorldMusic.m');
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
% string array and directory for stimuli
[songstr, music_dir] = scanFilesFromDir('Worldmusic_stimuli');
% pairs of stimuli
% stimuli_order = mix_worldmusic(length(songstr));
randStimuliNums = randperm(length(songstr))';
% shuffle the pairs of stimuli
% stimuli_order = stimuli_order(randperm(length(stimuli_order)),:);
stimuli_order = songstr(randStimuliNums);
% number of channels
nrchannels = 2;
% number of trials per block
Ntrials = 20; % 20
% number of blocks
Nblocks = 1; % 1

%% settings for psych
% keyboard unable
ListenChar(2);
AssertOpenGL;
% keyboard unicode
KbName('UnifyKeyNames');
rng('shuffle');
InitializePsychSound

[windowWidth,windowHeight] = Screen('WindowSize',whichScreen);
% font size
fontsize = windowWidth*0.05;

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
   
   [window, windowRect] = Screen('OpenWindow', whichScreen, gray);
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
   
   for block = 1:Nblocks
      % array of results
      results = {};
      % hide mouse cursor
      HideCursor;
      % get day
      daystr = datestr(clock,'yyyymmdd_HHMM');
      % file name at save
      fileName = [namestr, '_', expstr, '_', daystr, '_'];
      
      if languagestr == 'J' || languagestr == 'j'
         areyouready = double('準備はいいですか?');
      elseif languagestr == 'E' || languagestr == 'e'
         areyouready = 'Are you ready?';
      end
      DrawFormattedText(window, areyouready, 'center', 'center', white);
%       DrawFormattedText(window, 'Are you ready?\n(Press any key)', 'center', 'center', white);
      Screen('Flip', window);
      
      fprintf('LEFT CLICK TO MOVE ON TO THE EXPERIMENT\n');
      
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
         
         if ispc
            audioFileName1 = char(strcat(music_dir, '\', first_stimuli));
         elseif ismac
            audioFileName1 = char(strcat(music_dir, '/', first_stimuli));
         end
         
         % make a fixation cross in the background window
         Screen('DrawTexture', window, fixcross);
         % flip window (the background becomes the foreground)
         Screen('Flip', window);
         
         [wavWave1, waveFs] = psychwavread(audioFileName1);
         wavdata1 = wavWave1';
         
         fprintf('-----\nPLAYING %s\n', string(first_stimuli));
         
         PsychPortAudio('FillBuffer', pahandle, wavdata1);
         PsychPortAudio('Start', pahandle);
         PsychPortAudio('Stop', pahandle, 1);
         
         WaitSecs(1);
         
         Screen('Flip', window);
         
         freeze_time = 800/1000;
         
         % wait freeze_time secs
         WaitSecs(freeze_time);
         
         ShowCursor;
         t1 = GetSecs;
         % get the VAS scale result
         [resp, rt] = hb_scaleResponseWorldMusic(window, windowRect, 2, languagestr);
         rt = rt - t1;
         % append trial num, audio name, VAS result
         results(trial, :) = {trial, first_stimuli, second_stimuli, resp(1), resp(2), resp(3), rt};   
      end
      
      
      % change cell to table
      block_value = char(strcat('Block',string(block)));
      results = cell2table(results, 'VariableNames', {'TrialNum', 'First_Songname', 'Second_Songname', 'ScaleRating_1', 'ScaleRating_2', 'ScaleRating_3', 'ReactTime'});
      writetable(results,[save_dir,fileName,block_value,'.csv']);
      
      fprintf('-----\nSAVED FILE\n');
      
      if block ~= Nblocks
         BreakYesNo = hb_breakornot(window, windowRect, 1);
         
         disp(BreakYesNo);
         
         if BreakYesNo == 1
            DrawFormattedText(window, double('休憩をとってください'), 'center', 'center');
   %          DrawFormattedText(window, 'Please take a break', 'center', 'center');
            Screen('Flip', window);

            fprintf('-----\n!!!PRESS ENTER KEY TO RESUME TO EXPERIMENT!!!\n-----\n');

            KbWait;
         end
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

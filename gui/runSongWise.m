%% SETTING FOR STIMULI
% shuffle the pairs of stimuli
randStimuliNums = randperm(length(songstr))';
stimuli_order = songstr(randStimuliNums);
% number of channels
nrchannels = 2;
% number of trials per block
Ntrials = 20; %20
% number of blocks
Nblocks = 1;

%% SETTING FOR EXPERIMENT
fileName = [namestr, '_SongWise'];
if ispc
   saveDir = char(strcat(this_directory.folder,'\data\songwise\'));
elseif ismac
   saveDir = char(strcat(this_directory.folder,'/data/songwise/'));
end
% array of results
results = zeros(20,13);

%% START EXPERIMENT
try
   try
      pahandle = PsychPortAudio('Open', [], [], 0, 44100, nrchannels);
      disp('get pahandle');
   catch
      psychlasterror('reset');
      pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
   end
   
   f = msgbox('èÄîıÇÕÇ¢Ç¢Ç≈Ç∑Ç©?','','warn');
   waitfor(f);
   pause(1);
   
   for block = 1:Nblocks
      for trial = 1:Ntrials
         % get WAV file name
         stimuli = stimuli_order(trial);
         % make a fixation cross in the background window
         HideCursor;
         fixationCross;
         
         pause(1);
         
         if ispc
            audioFileName = char(strcat(music_dir, '\', stimuli));
         elseif ismac
            audioFileName = char(strcat(music_dir, '/', stimuli));
         end
         
         [wavWave1, waveFs] = psychwavread(audioFileName);
         wavdata1 = wavWave1';
         
         PsychPortAudio('FillBuffer', pahandle, wavdata1);
         PsychPortAudio('Start', pahandle);
         PsychPortAudio('Stop', pahandle, 1);
         
         pause(1);
         close(1);
         
         ShowCursor;
         
         % save the current workspace to use the variables at gui
         save('temporaryData.mat','randStimuliNums','trial','results','pahandle','wavdata1');
         
         % get the VAS scale result
         g = worldmusic_gui;

         waitfor(g);
         load('temporaryData1.mat','results');
      end
      
      % change mat to table
      results = num2cell(results);
      results = cell2table(results, 'VariableNames', {'texture', 'consonance', 'rhythmic', 'familiarity', 'valence', 'excitement', 'liking', 'ornamentation', 'grooviness', 'tempo', 'pitch', 'timbre', 'sound_quality'});
      writetable(results,[saveDir,fileName,'.csv']);
   end
   
   PsychPortAudio('Close', pahandle);
catch
   ListenChar(0);
   ShowCursor;
   psychrethrow(psychlasterror);
end
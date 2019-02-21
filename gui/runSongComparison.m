%% SETTING FOR STIMULI
% pairs of stimuli
stimuli_order = mix_worldmusic(length(songstr));
randStimuliNums = randperm(length(stimuli_order));
% shuffle the pairs of stimuli
stimuli_order = stimuli_order(randStimuliNums,:);
% number of channels
nrchannels = 2;
% number of trials per block
Ntrials_set = {47,48}; % 47,48
% number of blocks
Nblocks = 4; % 4

%% SETTING FOR EXPERIMENT
fontSize = windowHeight*0.1;

fileName = [namestr, '_SongComparison'];
expDate = datestr(now,'mmdd');

if ispc
    saveDir_similarity = char(strcat(this_directory.folder,'\data\similarity\'));
    saveDir_preference = char(strcat(this_directory.folder,'\data\preference\'));
elseif ismac
    saveDir_similarity = char(strcat(this_directory.folder,'/data/similarity/'));
    saveDir_preference = char(strcat(this_directory.folder,'/data/preference/'));
end

% array of results
results_similarity = zeros(20,20);
results_preference = zeros(20,20);

%% START EXPERIMENT
try
    try
        pahandle = PsychPortAudio('Open', [], [], 0, 44100, nrchannels);
        disp('get pahandle');
    catch
        psychlasterror('reset');
        pahandle = PsychPortAudio('Open', [], [], 0, [], nrchannels);
    end
    
    fig = figure(1);
    fig.MenuBar = 'none';
    fig.Units = 'normalized';
    maximize(fig);
    axis off;
    text(0.5,0.7,'ÉyÉAï]âø','FontSize',fontSize,'HorizontalAlignment','Center','VerticalAlignment','Middle');
    text(0.5,0.4,'* âπåπÇÕ1ìxÇµÇ©ó¨ÇÍÇ‹ÇπÇÒ','FontSize',fontSize*0.7,'HorizontalAlignment','Center','VerticalAlignment','Middle');

    pause(5);
    
    f = msgbox('èÄîıÇÕÇ¢Ç¢Ç≈Ç∑Ç©?','','warn');
    waitfor(f);
    close(fig);
    
    pause(1);
    
    for block = 1:Nblocks
        Ntrials = cell2mat(Ntrials_set(rem(block,2)+1));
        for trial = 1:Ntrials
            
            % hide mouse cursor
            HideCursor;
            
            pause(1);
            
            % get WAV file name
            firstOrder_Num = stimuli_order((block-1)*Ntrials+trial,1);
            secondOrder_Num = stimuli_order((block-1)*Ntrials+trial,2);
            first_stimuli = songstr(firstOrder_Num);
            second_stimuli = songstr(secondOrder_Num);
            
            if ispc
                audioFileName1 = char(strcat(music_dir, '\', first_stimuli));
                audioFileName2 = char(strcat(music_dir, '\', second_stimuli));
            elseif ismac
                audioFileName1 = char(strcat(music_dir, '/', first_stimuli));
                audioFileName2 = char(strcat(music_dir, '/', second_stimuli));
            end
            
            [wavWave1, waveFs] = psychwavread(audioFileName1);
            [wavWave2, waveFs] = psychwavread(audioFileName2);
            wavdata1 = wavWave1';
            wavdata2 = wavWave2';
            
            fig = figure(1);
            fig.Color = [0.7 0.7 0.7];
            fig.MenuBar = 'none';
            fig.Units = 'normalized';
            maximize(fig);
            axis off;
            text(0.475,0.5,'Song 1','fontsize',fontSize,'HorizontalAlignment','center','VerticalAlignment','middle');
            
            pause(1);
            
            PsychPortAudio('FillBuffer', pahandle, wavdata1);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop', pahandle, 1);
            WaitSecs(1);
            
            clf;
            axis off;
            text(0.475,0.5,'Song 2','fontsize',fontSize,'HorizontalAlignment','center','VerticalAlignment','middle');
            
            pause(1);
            
            PsychPortAudio('FillBuffer', pahandle, wavdata2);
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop', pahandle, 1);
            
            pause(1);
            close(1);
            
            ShowCursor;
            
            % save the current workspace to use the variables at gui
            save('temporaryData.mat','firstOrder_Num','secondOrder_Num','results_similarity','results_preference');
            
            % get the VAS scale result
            g = songcomparison_gui;
            
            waitfor(g);
            load('temporaryData1.mat','results_similarity','results_preference');
        end
        
        if block ~= Nblocks
            restTime;
        end
    end
    % change mat to table
    rownames = arrayfun(@num2str,1:20,'uni',0);
    
    results_similarity = num2cell(results_similarity);
    results_similarity = cell2table(results_similarity, 'VariableNames', {'Song1','Song2','Song3','Song4','Song5','Song6','Song7','Song8','Song9','Song10','Song11','Song12','Song13','Song14','Song15','Song16','Song17','Song18','Song19','Song20'});
    results_similarity.Properties.RowNames = rownames;
    
    results_preference = num2cell(results_preference);
    results_preference = cell2table(results_preference, 'VariableNames', {'Song1','Song2','Song3','Song4','Song5','Song6','Song7','Song8','Song9','Song10','Song11','Song12','Song13','Song14','Song15','Song16','Song17','Song18','Song19','Song20'});
    results_preference.Properties.RowNames = rownames;
    
    writetable(results_similarity,[saveDir_similarity,fileName,'_',expDate,'.csv'],'WriteRowNames',true);
    writetable(results_preference,[saveDir_preference,fileName,'_',expDate,'.csv'],'WriteRowNames',true);
    
    PsychPortAudio('Close', pahandle);
catch
    ListenChar(0);
    ShowCursor;
    psychrethrow(psychlasterror);
end
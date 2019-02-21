beep off;
close all;
clear all;
%% make directory and IDname
% get the input
input_result = input('ENTER PARTICIPANT ID: ', 's');
% get the ID
namestr = input_result;

this_directory = dir('headWorldMusic.m');
saveDir_name = {'songwise','similarity','preference'};

for i = 1:length(saveDir_name)
    if ispc
        save_dir = char(strcat(this_directory.folder,'\data\',char(saveDir_name(i)),'\'));
    elseif ismac
        save_dir = char(strcat(this_directory.folder,'/data/',char(saveDir_name(i)),'/'));
    end
    % if save directory does not exist, make it
    if not(exist(save_dir))
        mkdir(save_dir)
    end
end

%% SETTING FOR PSYCHTOOLBOX
% keyboard unable
ListenChar(2);
AssertOpenGL;
% keyboard unicode
KbName('UnifyKeyNames');
InitializePsychSound

[windowWidth,windowHeight] = Screen('WindowSize',0);

%% FETCH SONG NAMES
% string array and directory for stimuli
if ispc
    [songstr, music_dir] = scanFilesFromDir('..\Worldmusic_stimuli');
elseif ismac
    [songstr, music_dir] = scanFilesFromDir('../Worldmusic_stimuli');
end

%% RUN EXPERIMENT IN ORDER
runSongWise;

restTime;

runSongComparison;

delete temporaryData.mat temporaryData1.mat

fig = figure(1);
fig.MenuBar = 'none';
fig.Units = 'normalized';
maximize(fig);
axis off;

f = msgbox('‚ ‚è‚ª‚Æ‚¤‚²‚´‚¢‚Ü‚µ‚½!');
waitfor(f);

ListenChar(0);
% if ispc
%    winopen(this_directory);
% elseif ismac
%    system(['open ', this_directory.folder]);
% end

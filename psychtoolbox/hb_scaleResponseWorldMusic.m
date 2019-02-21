function [resp, rt] = hb_scaleResponseWorldMusic(win,winRect,nLikertRange,language)


% Usage Example;
%   [win, winRect] = Screen('OpenWindow', 0, [127 127 127], [0 0 500 500]);
%   [resp, rt] = hb_assessment(win,winRect,4);
%
% nLikertRange == 1 : Visual Analogue Scale (0~100%, continuous response)
% nLikertRange >= 2 : Likert Scale with n possible discrete responses
%
%% Algorithm Flow
% # 1. Basic setting (Screen initialize, and position of the stimuli)
%      * If window pointer is previously defined, skip this procedure
% # 2. Select assessment method (1: VAS, 2~ : Discrete Likert)
% # 3. Draw scale and tracking mouse position
% # 4. Calculate and return response
%
% Revision / Error Report >>> hiobeen@yonsei.ac.kr
% version 1.0.1, 2015-08-17

%% #1. Basic Setting & Ye-Oei Cheo-rhi & Editor Rei
if nargin < 2
   Screen('Preference', 'SkipSyncTests', 2); GStreamer; AssertOpenGL; % Monitor option
   Screen('Preference', 'DefaultFontSize', 25);
   PsychDefaultSetup(2); KbName('UnifyKeyNames'); % Keyboard & Response option
   screenColor = [127 127 127];
   screenRect = [0 0 880 880];
   [win, winRect] = Screen('OpenWindow', 0, screenColor, screenRect);
else screenRect = winRect;
end; if nargin < 3
   nLikertRange = 1;
end; if nargin < 4
   % Custom Stimuli Properties
   customStim_mat = rand() * 255 * repmat(sin(linspace(-1,1,50).^.25), [150,5]);
end
% customStim_texture = Screen('MakeTexture', win, customStim_mat);
% customStim_size = size(customStim_mat);

scale_position = - floor(winRect(4) * .33); % Move vertically

% Scale Parameters
hori_bar_mat = 0 * ones([floor(winRect(4)*(.1/10)) floor(winRect(3)*(1/2))]);
hori_bar_texture = Screen('MakeTexture', win, hori_bar_mat);
hori_bar_size = size(hori_bar_mat);
vert_bar_mat = 0 * ones([floor(winRect(4)*(.25/10)) floor(winRect(3)*(1/300))]);
vert_bar_texture = Screen('MakeTexture', win, vert_bar_mat);
vert_bar_size = size(vert_bar_mat);

% Scale Markers Specification
ovalSize = 40;
ovalWidth = 4;
ovalColor = [0 0 255];

% Create mouse instance
import java.awt.Robot; mouse = Robot;

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
   Screen('TextFont', win, allFonts(idx).number);
elseif ispc
   Screen('TextFont', win, 'Yu Gothic UI');
end
Screen('TextSize', win, winRect(2)*0.02);

%% #2. Assessment method
cp = [floor(winRect(3)*.5) floor(winRect(4)*.5)]; %Center point
first_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1)) + scale_position + 100,...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) + scale_position + 100];
second_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1)),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1))];
third_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1) - scale_position - 100),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) - scale_position - 100];
fourth_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1) - scale_position - 100),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) - scale_position - 100];
fifth_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1) - scale_position - 100),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) - scale_position - 100];
sixth_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1) - scale_position - 100),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) - scale_position - 100];
seventh_hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1) - scale_position - 100),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1)) - scale_position - 100];

% if nLikertRange == 1
%    nScaleColumns = 2;
% else
%    nScaleColumns = nLikertRange;
% end
nScaleColumns = nLikertRange;

% Possible mouse positions and limit its movement
possibleMoveSpace = [     ...
   round(first_hori_bar_pos(1)+screenRect(1)),   ...
   round(screenRect(2) - .5 * (first_hori_bar_pos(2)+third_hori_bar_pos(4))),   ...
   round(first_hori_bar_pos(3)+screenRect(1)),   ...
   winRect(4)   ...
   ];

initialMousePos = round(rand() * (possibleMoveSpace(3) - possibleMoveSpace(1)));
mouse.mouseMove(initialMousePos,(possibleMoveSpace(2)));


%% #3. Let's Get Response!
BtnClk_goNext = 0;
ShowCursor();

first_xPos = cp(1);
second_xPos = cp(1);
third_xPos = cp(1);
fourth_xPos = cp(1);
fifth_xPos = cp(1);
sixth_xPos = cp(1);
seventh_xPos = cp(1);

% resp_for_show = {'全く似ていない', '非常に似ていない', '少し似ていない', '比較できる', '少し似ている', '非常に似ている', '全く同じ'};
resp_for_show = {'1st recording', '2nd recording'};

while ~BtnClk_goNext
   %% #3-1. Likert Bar Drawing
   % Hori bar draw
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], first_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], second_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], third_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], fourth_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], fifth_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], sixth_hori_bar_pos,[],[],[],[255 255 255]);
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], seventh_hori_bar_pos,[],[],[],[255 255 255]);
   % Vert bars draw
   xRange = linspace(first_hori_bar_pos(1),first_hori_bar_pos(3),nScaleColumns);
   for xPos = xRange
      first_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([first_hori_bar_pos(2) first_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([first_hori_bar_pos(2) first_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      second_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([second_hori_bar_pos(2) second_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([second_hori_bar_pos(2) second_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      third_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([third_hori_bar_pos(2) third_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([third_hori_bar_pos(2) third_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      fourth_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([fourth_hori_bar_pos(2) fourth_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([fourth_hori_bar_pos(2) fourth_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      fifth_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([fifth_hori_bar_pos(2) fifth_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([fifth_hori_bar_pos(2) fifth_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      sixth_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([sixth_hori_bar_pos(2) sixth_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([sixth_hori_bar_pos(2) sixth_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      seventh_vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([seventh_hori_bar_pos(2) seventh_hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([seventh_hori_bar_pos(2) seventh_hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], first_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], second_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], third_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], fourth_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], fifth_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], sixth_vert_bar_pos,[],[],[],[255 255 255]);
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], seventh_vert_bar_pos,[],[],[],[255 255 255]);
   end
   
   %% #3-2. Draw Text
   if language == 'J' || language == 'j'
      DrawFormattedText(win, double('リズム'), 'center', first_vert_bar_pos(2)-80);
      DrawFormattedText(win, double('全く似ていない'), possibleMoveSpace(1)-150, first_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('同じ'), possibleMoveSpace(3)-50, first_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('音程'), 'center', second_vert_bar_pos(2)-80);
      DrawFormattedText(win, double('全く似ていない'), possibleMoveSpace(1)-150, second_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('同じ'), possibleMoveSpace(3)-50, second_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('音色'), 'center', third_vert_bar_pos(2)-80);
      DrawFormattedText(win, double('全く似ていない'), possibleMoveSpace(1)-150, third_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('同じ'), possibleMoveSpace(3)-50, third_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('今の音に対する印象を教えてください'), 'center', winRect(2)+80);
   elseif language == 'E' || language == 'e'
      DrawFormattedText(win, double('How similar are they?'), 'center', first_vert_bar_pos(2)-100);
      DrawFormattedText(win, double('Completely Different'), possibleMoveSpace(1)-200, first_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('Same'), possibleMoveSpace(3)-50, first_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('Which one is more complex?'), 'center', second_vert_bar_pos(2)-100);
      DrawFormattedText(win, double('1st recording'), possibleMoveSpace(1)-200, second_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('2nd recording'), possibleMoveSpace(3)-50, second_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('Which one do you prefer?'), 'center', third_vert_bar_pos(2)-100);
      DrawFormattedText(win, double('1st recording'), possibleMoveSpace(1)-200, third_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('2nd recording'), possibleMoveSpace(3)-50, third_vert_bar_pos(2)-30);
      DrawFormattedText(win, double('Based on the recordings you just heard, answer the following'), 'center', winRect(2)+80);
   end
   
   %% #3-3. Make Next Button
   Screen('FillRect', win, [179 213 165], [cp(1)-200, winRect(4)-200, cp(1)+200, winRect(4)-100]);
   DrawFormattedText(win, double('NEXT'), 'center', winRect(4)-135, [255 255 255]);
   
   
   %% #4. Get Response
   [cursorX, cursorY, clicks] = GetMouse(win);
   click = clicks(1);
   
   first_currentPoint = ( first_xPos - cp(1) ) / (possibleMoveSpace(3)-possibleMoveSpace(1)) * 2;
   
   first_yPos =  .5 * (first_vert_bar_pos(2)+first_vert_bar_pos(4)) + screenRect(2);
   second_yPos =  .5 * (second_vert_bar_pos(2)+second_vert_bar_pos(4)) + screenRect(2);
   third_yPos =  .5 * (third_vert_bar_pos(2)+third_vert_bar_pos(4)) + screenRect(2);
   fourth_yPos =  .5 * (fourth_vert_bar_pos(2)+fourth_vert_bar_pos(4)) + screenRect(2);
   fifth_yPos =  .5 * (fifth_vert_bar_pos(2)+fifth_vert_bar_pos(4)) + screenRect(2);
   sixth_yPos =  .5 * (sixth_vert_bar_pos(2)+sixth_vert_bar_pos(4)) + screenRect(2);
   seventh_yPos =  .5 * (seventh_vert_bar_pos(2)+seventh_vert_bar_pos(4)) + screenRect(2);
   
   if any(click)
      if cursorY >= first_vert_bar_pos(2)-20 && cursorY <= first_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            first_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            first_xPos = possibleMoveSpace(1);
         else
            first_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= second_vert_bar_pos(2)-20 && cursorY <= second_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            second_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            second_xPos = possibleMoveSpace(1);
         else
            second_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= third_vert_bar_pos(2)-20 && cursorY <= third_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            third_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            third_xPos = possibleMoveSpace(1);
         else
            third_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= fourth_vert_bar_pos(2)-20 && cursorY <= fourth_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            fourth_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            fourth_xPos = possibleMoveSpace(1);
         else
            fourth_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= fifth_vert_bar_pos(2)-20 && cursorY <= fifth_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            fifth_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            fifth_xPos = possibleMoveSpace(1);
         else
            fifth_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= sixth_vert_bar_pos(2)-20 && cursorY <= sixth_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            sixth_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            sixth_xPos = possibleMoveSpace(1);
         else
            sixth_xPos = cursorX - screenRect(1);
         end
      elseif cursorY >= seventh_vert_bar_pos(2)-20 && cursorY <= seventh_vert_bar_pos(4)+20
         if cursorX > possibleMoveSpace(3)
            seventh_xPos = possibleMoveSpace(3);
         elseif cursorX < possibleMoveSpace(1)
            seventh_xPos = possibleMoveSpace(1);
         else
            seventh_xPos = cursorX - screenRect(1);
         end
      end
   elseif ~any(click)
      while cursorX >= cp(1)-200 && cursorY >= winRect(4)-200 && cursorX <= cp(1)+200 && cursorY <= winRect(4)-100
         [x,y,buttons] = GetMouse(win);
         button = buttons(1);
         
         while ~any(button)
            [x,y,buttons] = GetMouse(win);
            button = buttons(1);
            if x < cp(1)-200 || y < winRect(4)-200 || x > cp(1)+200 || y > winRect(4)-100
               break;
            end
         end
         
         while any(button)
            buttonPush = 1;
            [x,y,buttons] = GetMouse(win);
            button = buttons(1);
         end
         
         if buttonPush && x >= cp(1)-200 && y >= winRect(4)-200 && x <= cp(1)+200 && y <= winRect(4)-100
            BtnClk_goNext = 1;
            break;
         end
         
         cursorX = x;
         cursorY = y;
      end
      
      buttonPush = 0;
   end
   
   respRange = linspace(possibleMoveSpace(1), possibleMoveSpace(3), nLikertRange);
   %***********
   % first bar
   %***********
%    LetsFindNearestOne = abs(respRange - first_xPos);
%    [~,nearestIdx] = (min(LetsFindNearestOne));
%    
%    for xPos = xRange(nearestIdx)
%       Screen('FrameOval', win, ovalColor,...
%          [ xPos-(ovalSize*.5), first_yPos - ovalSize*.5,...
%          xPos+(ovalSize*.5), first_yPos + ovalSize*.5 ], ovalWidth);
%       first_resp_disp = char(resp_for_show(nearestIdx));
%    end
   
   Screen('FrameOval', win, ovalColor,...
         [ first_xPos-(ovalSize*.5), first_yPos - ovalSize*.5,...
         first_xPos+(ovalSize*.5), first_yPos + ovalSize*.5 ], ovalWidth);
   
   %***********
   % second bar
   %***********
   LetsFindNearestOne = abs(respRange - second_xPos);
   [~,nearestIdx] = (min(LetsFindNearestOne));
   
   for xPos = xRange(nearestIdx)
      Screen('FrameOval', win, ovalColor,...
         [ xPos-ovalSize*.5, second_yPos - ovalSize*.5,...
         xPos+ovalSize*.5, second_yPos + ovalSize*.5 ], ovalWidth);
      second_resp_disp = char(resp_for_show(nearestIdx));
   end
   
   %***********
   % third bar
   %***********
   LetsFindNearestOne = abs(respRange - third_xPos);
   [~,nearestIdx] = (min(LetsFindNearestOne));
   
   for xPos = xRange(nearestIdx)
      Screen('FrameOval', win, ovalColor,...
         [ xPos-ovalSize*.5, third_yPos - ovalSize*.5,...
         xPos+ovalSize*.5, third_yPos + ovalSize*.5 ], ovalWidth);
      third_resp_disp = char(resp_for_show(nearestIdx));
   end
   
   DrawFormattedText(win, double(first_currentPoint), 'center', first_vert_bar_pos(2)-30);
%    DrawFormattedText(win, double(second_resp_disp), 'center', second_vert_bar_pos(2)-30);
%    DrawFormattedText(win, double(third_resp_disp), 'center', third_vert_bar_pos(2)-30);
   
   resp = {first_currentPoint, second_resp_disp, third_resp_disp};
   
   %% Flip it all
   Screen('Flip', win);
   
end

% HideCursor;
t2 = GetSecs;
rt = t2;
ShowCursor;

return

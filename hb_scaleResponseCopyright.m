function [resp, rt] = hb_scaleResponseCopyright(win,winRect,nLikertRange,customStim_mat)

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

%% #1. Basic Setting & Ye-Oei Cheo-rhi
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
customStim_texture = Screen('MakeTexture', win, customStim_mat);
customStim_size = size(customStim_mat);

scale_position = - floor(winRect(4) * .33); % Move vertically
text_position = floor(winRect(4) * .2); % Above the Scale

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
   Screen('TextFont', win, 'YuGothic Medium');
end
Screen('TextSize', win, 40);

%% #2. Assessment method
cp = [floor(winRect(3)*.5) floor(winRect(4)*.5)]; %Center point
hori_bar_pos = [floor(cp(1) - .5*hori_bar_size(2)),...
   floor(cp(2) - .5*hori_bar_size(1)),...
   floor(cp(1) + .5*hori_bar_size(2)),...
   floor(cp(2) + .5*hori_bar_size(1))];

if nLikertRange == 1
   nScaleColumns = 2;
else
   nScaleColumns = nLikertRange;
end

% Possible mouse positions and limit its movement
possibleMoveSpace = [     ...
   round(hori_bar_pos(1)+screenRect(1)),   ...
   winRect(2), ...
   round(hori_bar_pos(3)+screenRect(1)),   ...
   winRect(4)   ...
   ];

%    round(screenRect(2) - .5 * (hori_bar_pos(2)+hori_bar_pos(4))),   ...
initialMousePos = round(rand() * (possibleMoveSpace(3) - possibleMoveSpace(1)));
mouse.mouseMove(initialMousePos,(possibleMoveSpace(2)));


%% #3. Let's Get Response!
BtnClk_goNext = 0;
ShowCursor;
t1 = GetSecs;

scale_xPos = cp(1);

while ~BtnClk_goNext
   %% #3-1. Likert Bar Drawing
   % Hori bar draw
   Screen('DrawTexture', win, hori_bar_texture,...
      [0 0 hori_bar_size(2) hori_bar_size(1)], hori_bar_pos, [], [], [], [255 255 255]);
   % Vert bars draw
   xRange = linspace(hori_bar_pos(1),hori_bar_pos(3),nScaleColumns);
   for xPos = xRange
      vert_bar_pos = [ xPos - vert_bar_size(2),...
         mean([hori_bar_pos(2) hori_bar_pos(4)]) - (.5*vert_bar_size(1)),...
         xPos + vert_bar_size(2),...
         mean([hori_bar_pos(2) hori_bar_pos(4)]) + (.5*vert_bar_size(1)),...
         ];
      
      Screen('DrawTexture', win, vert_bar_texture,...
         [0 0 vert_bar_size(2) vert_bar_size(1)], vert_bar_pos, [], [], [], [255 255 255]);
   end
   
   
   %% #3-2. Draw Text
   DrawFormattedText(win, '0', possibleMoveSpace(1), vert_bar_pos(2)-30);
   DrawFormattedText(win, '100', possibleMoveSpace(3)-15, vert_bar_pos(2)-30);
   DrawFormattedText(win, double('一致度'), 'center', vert_bar_pos(2)-30);
   
   %% #3-3. Make Next Button
   Screen('FillRect', win, [179 213 165], [cp(1)-200, winRect(4)-200, cp(1)+200, winRect(4)-100]);
   DrawFormattedText(win, double('次へ'), 'center', winRect(4)-135, [255 255 255]);
   
   %% #4. Get Response
   [cursorX, cursorY, clicks] = GetMouse(win);
   click = clicks(1);
   %     if cursorX < possibleMoveSpace(1); mouse.mouseMove(possibleMoveSpace(1), cursorY); cursorX = possibleMoveSpace(1);
   %     elseif cursorX > possibleMoveSpace(3); mouse.mouseMove(possibleMoveSpace(3), cursorY); cursorX = possibleMoveSpace(3);
   %     elseif cursorY < possibleMoveSpace(2); mouse.mouseMove(cursorX, possibleMoveSpace(2)); cursorY = possibleMoveSpace(2);
   %     elseif cursorY > possibleMoveSpace(4); mouse.mouseMove(cursorX, possibleMoveSpace(4)); cursorY = possibleMoveSpace(4);
   %     end
   
   yPos =  .5 * (vert_bar_pos(2)+vert_bar_pos(4)) + screenRect(2);
   if nLikertRange == 1 %VAS
      currentPoint = ( scale_xPos - possibleMoveSpace(1) ) / (possibleMoveSpace(3)-possibleMoveSpace(1));
      
      if any(click)
         if cursorY >= vert_bar_pos(2)-20 && cursorY <= vert_bar_pos(4)+20
            if cursorX > possibleMoveSpace(3)
               scale_xPos = possibleMoveSpace(3);
            elseif cursorX < possibleMoveSpace(1)
               scale_xPos = possibleMoveSpace(1);
            else
               scale_xPos = cursorX - screenRect(1);
            end
         end
      end
      
      cvt2percent = round(currentPoint * 100);
      resp_for_show = (strcat([ num2str(cvt2percent) ' %' ]));
      
      Screen('FrameOval', win, ovalColor,...
         [ scale_xPos-(ovalSize*.5), yPos - ovalSize*.5,...
         scale_xPos+(ovalSize*.5), yPos + ovalSize*.5 ], ovalWidth);
      
      DrawFormattedText(win, resp_for_show, 'center', cp(2)-text_position);
      resp = cvt2percent;
   else
      respRange = linspace(possibleMoveSpace(1), possibleMoveSpace(3), nLikertRange);
      LetsFindNearestOne = abs(respRange - cursorX);
      [~,nearestIdx] = (min(LetsFindNearestOne));
      
      for xPos = xRange(nearestIdx)
         Screen('FrameOval', win, ovalColor,...
            [ xPos-ovalSize*.5, yPos - ovalSize*.5,...
            xPos+ovalSize*.5, yPos + ovalSize*.5 ], ovalWidth);
      end
      
      resp_for_show = {'全く似ていない', '非常に似ていない', '少し似ていない', '比較できる', '少し似ている', '非常に似ている', '全く同じ'};
      
      DrawFormattedText(win, double(char(resp_for_show(nearestIdx))), 'center', cp(2)-text_position);
      resp = char(resp_for_show(nearestIdx));
   end
      
   if ~any(click)
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
   
   %% Flip it all
   Screen('Flip', win);
   
end
t2 = GetSecs;
rt = t2-t1;
ShowCursor;

return

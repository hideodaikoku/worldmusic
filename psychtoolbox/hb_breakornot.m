function continue_or_break = hb_breakornot(win,winRect,nLikertRange,customStim_mat)


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
customStim_texture = Screen('MakeTexture', win, customStim_mat);
customStim_size = size(customStim_mat);

scale_position = - floor(winRect(4) * .33); % Move vertically

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
Screen('TextSize', win, 50);
   
%% #2. Assessment method
cp = [floor(winRect(3)*.5) floor(winRect(4)*.5)]; %Center point

% Possible mouse positions and limit its movement
% possibleMoveSpace = [     ...
%    round(first_hori_bar_pos(1)+screenRect(1)),   ...
%    round(screenRect(2) - .5 * (first_hori_bar_pos(2)+third_hori_bar_pos(4))),   ...
%    round(first_hori_bar_pos(3)+screenRect(1)),   ...
%    winRect(4)   ...
%    ];
% 
% initialMousePos = round(rand() * (possibleMoveSpace(3) - possibleMoveSpace(1)));
% mouse.mouseMove(initialMousePos,(possibleMoveSpace(2)));


%% #3. Let's Get Response!
BtnClk_break = 0;
ShowCursor();

while ~BtnClk_break
   %% #3-1. Draw Text
   DrawFormattedText(win, double('休憩にしますか?'), 'center', winRect(2)+80);   
   
   %% #3-2. Make Next Button
   Screen('FillRect', win, [179 213 165], [cp(1)-500, cp(2)-50, cp(1)-300, cp(2)+50]);
   DrawFormattedText(win, double('いいえ'), cp(1)-400, cp(2)+25, [255 255 255]);
   Screen('FillRect', win, [179 213 165], [cp(1)+250, cp(2)-50, cp(1)+450, cp(2)+50]);
   DrawFormattedText(win, double('はい'), cp(1)+350, cp(2)+25, [255 255 255]); 
   
   %% #4. Get Response
   [cursorX, cursorY, clicks] = GetMouse(win);
   click = clicks(1);
   
   if nLikertRange == 1 %Button Response
      if ~any(click)
         while cursorX >= cp(1)-500 && cursorY >= cp(2)-50 && cursorX <= cp(1)-300 && cursorY <= cp(2)+50
            [x,y,buttons] = GetMouse(win);
            button = buttons(1);

            while ~any(button)
               [x,y,buttons] = GetMouse(win);
               button = buttons(1);
               if x < cp(1)-500 || y < cp(2)-50 || x > cp(1)-300 || y > cp(2)+50
                  break;
               end
            end

            while any(button)
               buttonPush = 1;
               [x,y,buttons] = GetMouse(win);
               button = buttons(1);
            end
            
            if buttonPush && x >= cp(1)-500 && y >= cp(2)-50 && x <= cp(1)-300 && y <= cp(2)+50
               BtnClk_break = 1;
               continue_or_break = 0;
               break;
            end

            cursorX = x;
            cursorY = y;
         end
         
         while cursorX >= cp(1)+250 && cursorY >= cp(2)-50 && cursorX <= cp(1)+450 && cursorY <= cp(2)+50
            [x,y,buttons] = GetMouse(win);
            button = buttons(1);
            
            while ~any(button)
               [x,y,buttons] = GetMouse(win);
               button = buttons(1);
               if x < cp(1)+250 || y < cp(2)-50 || x > cp(1)+450 || y > cp(2)+50
                  break;
               end
            end
            
            while any(button)
               buttonPush = 1;
               [x,y,buttons] = GetMouse(win);
               button = buttons(1);
            end
            
            if buttonPush && x >= cp(1)+250 && y >= cp(2)-50 && x <= cp(1)+450 && y <= cp(2)+50
               BtnClk_break = 1;
               continue_or_break = 1;
               break;
            end
            
            cursorX = x;
            cursorY = y;
         end
         
         buttonPush = 0;
      end
      
   end
   %% Flip it all
   Screen('Flip', win);
   
end

ShowCursor;

return

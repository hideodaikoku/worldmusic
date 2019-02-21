%*******
% create fixation cross
%*******

fig = figure(1);
fig.Color = [0.7 0.7 0.7];
fig.MenuBar = 'none';
fig.Units = 'normalized';
maximize(fig);
axis off;
text(0.475,0.5,'+','fontsize',windowHeight*0.5,'HorizontalAlignment','center','VerticalAlignment','middle');
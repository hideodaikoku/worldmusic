function timerFile(obj, event, fontSize)
tnow = toc;
tnow = round(tnow);
tnow_minute = floor(tnow/60);
tnow_second = floor(rem(tnow,60));
leftTime = duration(0,5,0,'Format','mm:ss') - duration(0,tnow_minute,tnow_second);
clf;
axis off;

text(0.5,0.9,'�x�e���Ƃ��Ă�������','FontSize',fontSize,'HorizontalAlignment','Center','VerticalAlignment','Middle');
text(0.5,0.7,'�c�莞��','FontSize',fontSize*0.4,'HorizontalAlignment','Center','VerticalAlignment','Middle');
text(0.5,0.5,[char(leftTime)],'FontSize',fontSize,'HorizontalAlignment','Center','VerticalAlignment','Middle');
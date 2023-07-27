function printfig(fig,fullname,fileformat)
h_fig = fig;
h_fig.Color = 'w';
h_fig.PaperPositionMode = 'auto';
h_fig.PaperUnits = 'centimeters';
paper_pos = h_fig.PaperPosition;
h_fig.PaperSize = [paper_pos(3) paper_pos(4)];
%Render the background transparent
%set(gca, 'color', 'none');
%h_fig.Color = 'none'; 
%Set axes colors to black(for post processing)
set(gca,'GridColor',[0 0 0])
set(gca,'MinorGridColor',[0 0 0])
set(gca,'XColor',[0 0 0])
set(gca,'YColor',[0 0 0])
set(gca,'ZColor',[0 0 0])
print(h_fig,'-painters',fullname,fileformat);
end
%Test 
close all; 
hist(randn(100,1));
h = get(gca,'Children'); 
y = h.Vertices(:,1);
z = h.Vertices(:,2);
x = 3*ones(size(y));
close all
hist(randn(100,1)+2);
h = get(gca,'Children');
y2 = h.Vertices(:,1);
z2 = h.Vertices(:,2);
x2 = 6*ones(size(y2));
close all;
% y2_bold = y2;
% z2_bold = z2;
% x2_bold = 6.05*ones(size(y2_bold));

patch(x,y,z, 'r'); hold on; patch(x2,y2,z2, 'b'); 
% patch(x2_bold, y2_bold, z2_bold,'b');
view(3)
% now rotate as desired
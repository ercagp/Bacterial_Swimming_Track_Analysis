function dotlesslist = removedots_folderlisting(Main_Path)

list = dir(Main_Path); 
%get rid of '.' '..' 
list(contains({list.name},'.')) =[];

dotlesslist = list; 
end

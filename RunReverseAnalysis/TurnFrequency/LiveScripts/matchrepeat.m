 function R = matchrepeat(X,Y)
          if iscell(X)
              X = cell2mat(X); 
          end
          UX = unique(X,'stable');
          R = cell(length(UX),2);
          for i = 1:length(UX)
              Mask = X == UX(i);
              R{i,1} = unique(X(Mask));
              YSubset = Y(Mask);
              R{i,2} = []; 
              for j = 1:size(YSubset,1)
                  R{i,2} = [R{i,2}; YSubset{j}];
             end                 
          end
          
          %Sort and spit the R cell out 
          [~,I] = sort([R{:,1}]); 
          R = R(I,:); 
 end
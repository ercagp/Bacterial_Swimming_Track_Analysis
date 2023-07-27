%Function for calculating MSD of a cell trajectory
%as a function of lag time tau(or number of steps if you will),
%by Ercag
%February 2019 
function allMSD = MSD(x,tau_i,fps)
  j_max = length(tau_i);  %tau_i is the vector for lag time! 
  for j = 1:j_max
    
    %tau_i is (unscaled) the lag time vector 
    %Scale it by frame rate(1/s)
    tau = tau_i(j)./fps;
    
    x_max = length(x);
    
    if tau_i(j) >= x_max 
        delta_x = [];
    else
        for i = 1:x_max-tau_i(j)
        delta_x(i) = (x(i+tau_i(j)) - x(i)).^2;
        end
    end
    
    %Total time of the video 
    t_total = x_max/fps; 
    
    %MSD of the cell at lag time tau 
    %(i.e. time average of the displacement vector for the chosen tau)  
    allMSD(j)  = sum(delta_x)/t_total-tau; 
  end
end
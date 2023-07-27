%Function for calculating MSD of a cell trajectory
%as a function of lag time tau(or number of steps if you will),
%by Ercag
%February 2019 
function allSD = SquareDisp(x,tau_i) %tau_i is the single lag-time point
  %j_max = length(tau_i);  
  %for j = 1:j_max
    
    %tau_i is (unscaled) the lag time vector 
        
    x_max = length(x);
    
    if tau_i >= x_max 
        delta_x = [];
    else
        for i = 1:x_max-tau_i
        delta_x(i) = (x(i+tau_i) - x(i)).^2;
        end
    end
    
    %Square displacement of the cell at lag time tau 
    %(i.e. time average of the displacement vector for the chosen tau)  
    allSD  = delta_x; %sum(delta_x)/t_total-tau; 
  %end
end
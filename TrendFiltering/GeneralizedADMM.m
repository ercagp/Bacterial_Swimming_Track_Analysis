function beta=GeneralizedADMM(y,lambda, k)



%% initial guesses
beta=y;
alpha=diff(y,k);
u=zeros(size(alpha));


%% output behavior
plotmode='ploton';



%% iterate
niter=10^4;
kiter=1;
while kiter<=niter
    
    %compute updated values 
    [beta, alpha, u] = UpdateBetaAlphaU(k, lambda, beta,alpha, u);
    
    
    

    % plot outcome?
    switch plotmode
        case 'ploton'
            plot(y, 'k-o');
            hold on
            plot(beta, 'r*-');
            hold off
            title([ 'k_{iter}= ' num2str(kiter)']);
            drawnow;
    end
    
    
    % increase iteration counter
    kiter=kiter+1;
end





end

function [beta_new, alpha_new, u_new] = UpdateBetaAlphaU(k, lambda, beta,alpha, u)


rho=lambda;
n=length(beta);

% update beta
D=DifferenceMatrix(n,k);
v=(y+rho*D')*(alpha+u);
I=eye(n-k);
A=I+rho*(D'*D);
beta_new=A\v;

% update alpha
alpha_new=FusedLasso( k,lambda/rho, alpha, beta, u);

% update u
u_new=u+alpha-diff(beta,k);



end


function D=DifferenceMatrix(n,k)
% creates difference matrix of size (n-k-1) x (n-k)


d=diag(ones(n-k-1,1),1)  ;
d(end,:)=[];
D=-eye(n-k-1,n-k)+d ;

end


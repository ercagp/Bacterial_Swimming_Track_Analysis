function beta=ADMM(y,lambda, k)



%% initial guesses
beta=y;
alpha=diff(y,k+1,1);
u=zeros(size(alpha));


%% output behavior
plotmode='ploton';



%% iterate
niter=10^5;
kiter=0;
while kiter<=niter
    
    %disp(['Working on iteration ' num2str(kiter) '.'])
    
    %    if kiter==1
    %       return
    %     end
    
    
    [beta_old, alpha_old, u_old]=deal(beta, alpha, u);
    
    %compute updated values
    [beta, alpha, u] = UpdateBetaAlphaU(y, k, lambda, beta,alpha, u);
    
    % plot outcome?
    switch plotmode
        case 'ploton'
            
            if rem(kiter,1)==0
                figure(1)
                newcolor1=[ 1 0 0];
                oldcolor1=PalerRGBColour(newcolor1,0.8);
                plot(diff(y,1,1), 'k-o');
                hold on
                plot(diff(beta,1,1), '*-', 'Color', newcolor1);
                plot(diff(beta_old,1,1), '*-', 'Color',oldcolor1);
                hold off
                title([ 'k_{iter}= ' num2str(kiter)]);
                ylabel('\beta')
                legend('data', 'filt. curr. iter.', 'filt. prev iter.')
                drawnow
                
                figure(2)
                newcolor2=[ 0 0 0];
                oldcolor2=0.5*ones(1,3);
                subplot(3,1,1)
                plot(alpha, '-o', 'Color',newcolor2);
                hold on;
                plot(alpha_old, '-o','Color', oldcolor2 );
                hold off
                title(['alpha, k_{iter}= ' num2str(kiter)])
                subplot(3,1,2)
                plot(beta-y, 'o-', 'Color',newcolor2);
                hold on;
                plot(beta_old-y, '-o','Color', oldcolor2 );
                hold off;
                title('beta - y')
                subplot(3,1,3)
                plot(u, '-o', 'Color',newcolor2);
                hold on;
                plot(u_old, '-o','Color', oldcolor2 );
                hold off;
                title( 'u ');
                drawnow
                
            end
    end
    
    
    
    % increase iteration counter
    kiter=kiter+1;
end





end

function [beta_new, alpha_new, u_new] = UpdateBetaAlphaU(y, k, lambda, beta,alpha, u)



rho=lambda;
n=length(beta);

[beta_old, alpha_old, u_old]=deal(beta, alpha, u);

%decrease sizes to fit difference matrix
beta=beta(2:end-1);
u=u(1:end-1);
y=y(2:end-1);
alpha=alpha(1:end-1);



% update beta
D=DifferenceMatrix(n,k+1);
v=y+rho*D'*(alpha+u);
I=eye(n-k-1);
A=I+rho*(D'*D);
beta_new=A\v;

% update alpha by soft thresholding
alpha_new=wthresh(   D*beta-u, 's', lambda/rho);

% update u
u_new=u+alpha-D*beta;

%increase sizes again?
[beta_new,alpha_new, u_new]=deal([beta_old(1); beta_new; beta_old(end)],...
    [alpha_old(1); alpha_new], [ u_new; u_old(end)]);



end


function D=DifferenceMatrix(n,k)
% creates difference matrix of size (n-k-1) x (n-k)


d=diag(ones(n-k-1,1),1)  ;
d(end,:)=[];
D=-eye(n-k-1,n-k)+d ;

end


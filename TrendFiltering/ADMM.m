function [beta, varargout]=ADMM(y,lambda, k, varargin)



%% input checking
if length(y)<=k
    beta=y;
    return
end

%% algorithm stop conditions.
max_iter=10^5;
AlphaChangeThreshold=10^-4;
FChangeThreshold=10^-4;

%% optional inputs?

%default initial guesses
beta=y;
alpha=diff(y,k+1,1);
u=zeros(size(alpha));
IterationCase='single';

% override if other input is given
if ~isempty(varargin)
    
    if ischar(varargin{1})
        
        IterationCase=varargin{1};
        
    elseif isstruct(varargin{1})
        
        InitialValues=varargin{1};
        beta=InitialValues.beta;
        alpha=InitialValues.alpha;
        u=InitialValues.u;
    end
end


switch IterationCase
    case 'iterate'
        lambda_range=logspace(log10(lambda), log10(lambda*10), 10);
    case 'single'
        lambda_range=lambda;
end


%% compute difference matrix for this problem (most efficient to do this only once!)
D= DifferenceMatrix(length(beta),k+1);
Dp=D'*D;


%% output behavior
%plotmode='ploton';
plotmode='plotoff';


%% iterate
F=MinimizationFunction(beta, y, lambda,k,D);
lambdacurrent=lambda_range(end);
lambda_index=length(lambda_range);
while lambda_index>=1
    lambdacurrent=lambda_range(lambda_index);
    
    
    kiter=0;
    FRelativeChange=2*FChangeThreshold; %make sure that the loop is initialized
%    AlphaRelativeChange=2*AlphaChangeThreshold; %make sure that the loop is initialized
    while kiter<=max_iter && (FRelativeChange>FChangeThreshold || kiter<=2)
%    while kiter<=max_iter && (AlphaRelativeChange>AlphaChangeThreshold || kiter==2)
        
        %disp(['Working on iteration ' num2str(kiter) ' at \lambda=' num2str(lambdacurrent) '.'])
        
        %    if kiter==1
        %       return
        %     end
        
        
        
        [beta_old, alpha_old, u_old, F_old]=deal(beta, alpha, u, F);
        
        %compute updated values
        [beta, alpha, u, F] = UpdateBetaAlphaU(y, k, lambdacurrent, beta,alpha, u,D,Dp);
        
        
        % monitor changes in parameters
        %AlphaRelativeChange=sqrt(mean((alpha-alpha_old).^2, 'omitnan')/mean(alpha.^2, 'omitnan'));
        FRelativeChange=abs(F-F_old)./F_old;
        
        
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
                    ylabel('diff(\beta)')
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
    
    if kiter>max_iter
        disp([ 'Stopped because maximum number of iterations was reached (' num2str(max_iter) ') at \lambda= ' num2str(lambdacurrent)]);
    else
        disp([ 'Convergence in \alpha after ' num2str(kiter) ' iterations at \lambda= ' num2str(lambdacurrent) ]);
    end
    
    lambda_index=lambda_index-1;
    
end

%% outputs?

FinalValues.beta=beta;
FinalValues.alpha=alpha;
FinalValues.u=u;

varargout{1}=FinalValues;





end

function [beta_new, alpha_new, u_new,F_new] = UpdateBetaAlphaU(y, k, lambda, beta,alpha, u,D,Dp)



rho=lambda;
n=length(beta);

%[beta_old, alpha_old, u_old]=deal(beta, alpha, u);

%decrease sizes to fit difference matrix
% beta=beta(2:end-1);
% u=u(1:end-1);
% y=y(2:end-1);
% alpha=alpha(1:end-1);


% update beta
%D=DifferenceMatrix(n,k+1);
v=y+rho*D'*(alpha+u);
I=eye(size(D,2));
A=I+rho*(Dp);
beta_new=A\v;


Dbeta=D*beta;
% update alpha by soft thresholding
alpha_new=wthresh(   Dbeta-u, 's', lambda/rho);

% update u
u_new=u+alpha-D*beta;

%increase sizes again?
%[beta_new,alpha_new, u_new]=deal([beta_old(1); beta_new; beta_old(end)],...
%    [alpha_old(1); alpha_new], [ u_new; u_old(end)]);


F_new=mean((beta-y).^2)+lambda*mean( norm(Dbeta,1));


end


function D=DifferenceMatrix(n,k)
% creates difference matrix of size order of size n x (n-k) and order k


d=diag(ones(n-1,1),1)  ;
d(end,:)=[];
D1=-eye(n-1,n)+d;

D=D1;
if k>1
    i=1;
    while i<k
        [mm,nn]=size(D);
        D1cut=D1(1:mm-1, 1:mm);
        D=D1cut*D;
        i=i+1;
    end
end

end


function F=MinimizationFunction(beta, y, lambda,k,D)
%D=DifferenceMatrix(length(beta),k+1);
F=mean((beta-y).^2)+lambda*mean( (norm(D*beta,1)));
        

end
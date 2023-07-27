function X_filtered=BruteForceNoVelocityChangePositionFiltering(X,lambda)


options=optimset('fminsearch');
options.MaxFunEvals=1000*numel(X);
options.MaxIter=1000*numel(X);



% minimize residuals and sum of absolute changes in speed
%X_filtered=fminsearch(@(p)   ( sum(sum((p-X).^2,2))+lambda*sum(abs(diff(sqrt(sum(diff(p,1).^2,2)))))  )   , X,options );

% minimize residuals and sum of absolute changes in velocity
X_filtered=fminsearch(@(p)   ( sum(sum((p-X).^2,2))+lambda*sum(sum(abs(diff(p,2,1)),2)))   , X,options );

% minimize residuals and number of time points with changes in speed
%threshold=0;
%p=fminsearch(@(p)   ( sum(sum((p-X).^2,2))+lambda* sum(  abs(diff(sum(diff(p,1).^2,2))) >threshold ) )   , X,options );




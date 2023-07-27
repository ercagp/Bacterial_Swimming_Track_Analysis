function M=admN(X,varargin)
%% M= stdmN(X) computes the median-based deviation of X, ignoring NaNs.


% decide along which dimension to compute the mean.
if nargin==1
    if isvector(X)
        if size(X,1)==1;
            d=2;
        else
            d=1;
        end
    else
        d=1;
    end
    
else
    d=varargin{1};
end


% compute absolute deviation from median along chosen dimension. 
if isvector(X)
    
    if (d==1 && size(X,2)==1) || (d==2 && size(X,1)==1) 
        Y=X(~isnan(X));
       
        M=median(abs(Y-median(Y)));
    else
        M=X;
    end
    
    
else 
    
    %[Y,n]=shiftdim(X,d-1) % shift chosen dimension to front.
    sizX=size(X);
    perm=1:1:length(sizX);
    perm(1)=d;
    perm(d)=1;
    Y=permute(X,perm);
    
    N=numel(Y)/size(Y,1);
    Z=reshape(Y, size(Y,1), N);
    S=size(Y);
    
    mZ=NaN(size(1,N));
    for i=1:size(Z,2)
        z=Z(:,i);
        w=z(~isnan(z));
        mZ(i)=median(abs(w-median(w)));
    end
    
    mY=reshape(mZ, [1, S(2:end)]);
    
    
    %M=shiftdim(mY,-n);
    M=ipermute(mY,perm);
    
    
        
    
    
    
    
    
end



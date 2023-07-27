function M=meanN(X,varargin)
%% M= meanN(X) is the equivalent of mean(X) but ignores NaNs.




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



% compute mean along chosen dimension.
if isvector(X)
    
    if (d==1 && size(X,2)==1) || (d==2 && size(X,1)==1)
        
        M=mean(X(~isnan(X)));
        
    else
        if ~isempty(X) %copy behaviour of mean in handling empty arrays.
            M=X;
        else
            M=NaN(size(X));
        end
        
    end
    
    
else
    if ~isempty(X)
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
            mZ(i)=mean(z(~isnan(z)));
        end
        
        mY=reshape(mZ, [1, S(2:end)]);
        
        
        %M=shiftdim(mY,-n);
        M=ipermute(mY,perm);
        
        
        
    else %if input matrix is empty
        %output should be expected size, but NaN is mean is taken along
        %0-sized dimension, and empty otherwise.
        sizX=size(X);
        sizM=size(X);
        sizM(d)=1;
        if sizX(d)==0
            M=NaN(sizM);
        else
            M=double.empty(sizM);
        end
        
        
        
        
    end
end

    
    

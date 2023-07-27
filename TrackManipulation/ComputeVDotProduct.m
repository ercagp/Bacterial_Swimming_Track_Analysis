function  Snew  = ComputeVDotProduct( S, maxlag )
% Snew  = ComputeVDotProduct( S, maxlag ) computes the velocity dot product
% for time lags up to maxlag for the speeds in S.Speeds. 


Snew=S;


for i=1:length(S.Speeds)
    
    v=S.Speeds{i}(:,6:8);
    mV2=nanmean(sum(v.^2,2));
    mV1=nanmean(sum(v,2));
    
    for j=0:maxlag
        
        v1=v(1:(end-j),:);
        v2=v((1+j):end,:);
        
        Snew.VDotProduct{i}{:,j+1}=sum(v1.*v2,2);

    end
    
    Snew.VDotProductNorm2{i}=cellfun(@(x) (x/mV2), Snew.VDotProduct{i}, 'UniformOutPut', 0);
    Snew.VDotProductNorm1{i}=cellfun(@(x) (x/mV1.^2), Snew.VDotProduct{i}, 'UniformOutPut', 0);
end

Snew.VDotProduct=Snew.VDotProduct';
Snew.VDotProductNorm1=Snew.VDotProductNorm1';
Snew.VDotProductNorm2=Snew.VDotProductNorm2';

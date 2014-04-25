function [p] = bigperf_rsq(X,y,opt)
% bigperf_rsq(X,y,opt);
% Computes the R squared error for the predictions.
%
% INPUTS:
% -X: input data bigarray
% -y: labels bigarray
% -OPT: structure of options with the following fields (and subfields):
%   fields that need to be set through previous gurls tasks:
%       -pred (set by the pred_* routines)
%   fields that need to be set through the bigdefopt function:
%       -nb_pred
% 
% OUTPUT: struct with the following fields:
% -rmse: array of rmse for each class/output
% -forho: ""
% -forplot: ""


if isfield(opt, 'perf')
    p = opt.perf;
end

opt.pred.Transpose(true);

% Compute ybar
ybar = 0;
for i1 = 1:y.BlockSize : y.NumItems
    i2 = min(i1 + y.BlockSize -1 , y.NumItems);
    y_block = y(i1 : i2, : );
    ybar = ybar + sum(y_block);
end
ybar = ybar / y.NumItems;

SStot = 0;
SSres = 0;
for i1 = 1:y.BlockSize : y.NumItems
    i2 = min(i1 + y.BlockSize -1 , y.NumItems);
    y_block = y(i1 : i2, : );
    ypred_block = opt.pred(i1 : i2, : );

    SStot = SStot + sum((y_block - ybar) .^ 2);
    SSres = SSres + sum((y_block - ypred_block) .^ 2);
end

p.rsq		= 1 - (SSres ./ SStot);
p.forho 	= -p.rsq;
p.forplot 	= p.rsq;
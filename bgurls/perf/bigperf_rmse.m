function [p] = bigperf_macroavg(X,y,opt)
% bigperf_rmse(X,y,opt);
% Computes the root mean squared error for the predictions.
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

nb_pred = opt.nb_pred;
transpose = opt.pred.Transpose(true);
T = y.Sizes();
T = T{1};

mse = 0;

for i1 = 1:y.BlockSize : y.NumItems
    i2 = min(i1 + y.BlockSize -1 , y.NumItems);
    y_block = y(i1 : i2, : );
    ypred_block = opt.pred(i1 : i2, : );

    diff = ypred_block - y_block;
    mse = mse + sum(diff.^2,1);
end

p.rmse		= sqrt(mse);
p.forho 	= -p.rmse;
p.forplot 	= p.rmse;

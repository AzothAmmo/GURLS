function [p] = perf_rsq(X, y, opt)

% perf_rsq(X, y, opy)		
% Computes the R squared error for the predictions.
%
% INPUTS:
% -X: input data matrix
% -y: labels matrix
% -OPT: structure of options with the following fields (and subfields):
%   fields that need to be set through previous gurls tasks:
%       -pred (set by the pred_* routines)
% 
% OUTPUT: struct with the following fields:
% -rmse: array of rmse for each class/output
% -forplot: ""
% -forho: array of -rmse for each class/output


if isstruct(opt.pred)
	opt.pred = opt.pred.means;
end	
if isfield (opt,'perf')
	p = opt.perf; % lets not overwrite existing performance measures.
		      % unless they have the same name
end
T 		= size(y,2);
n 		= size(y,1);
ybar = mean(y);
SStot = sum((y - ybar) .^ 2);
SSres = sum((y - opt.pred) .^ 2);
p.rsq		= 1 - (SSres ./ SStot);
p.forho 	= -p.rsq;
p.forplot 	= p.rsq;

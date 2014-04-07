function [vout] = bigparamsel_hoprimal(X,y,opt)

%	bigparamsel_fixsiglam(X,y,opt)
%	Fixes the lambda.
%
%	INPUT:
%		- X : not used
%		- Y : not used
%		- OPT : not used
%
%	OUTPUT: structure with the following fields:
%		- lambdas 	: values of the regulariazation parameter maximizing the
%			    	  validation performance (one for each class).	
%		- forho		: matrix with validation performance for each class and for each value of the paramter.
%		- guesses	: contains the values tried for the lambda parameter.

vout.lambdas = 10^-8;

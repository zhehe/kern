function k = simKernDiagCompute(kern, t)

% SIMKERNDIAGCOMPUTE Compute diagonal of SIM kernel.
% FORMAT
% DESC computes the diagonal of the kernel matrix for the single input motif kernel given a design matrix of inputs.
% ARG kern : the kernel structure for which the matrix is computed.
% ARG t : input data matrix in the form of a design matrix.
% RETURN k : a vector containing the diagonal of the kernel matrix
% computed at the given points.
%
% SEEALSO : simKernParamInit, kernDiagCompute, kernCreate, simKernCompute
%
% COPYRIGHT : Neil D. Lawrence, 2006
%
% MODIFICATIONS : Antti Honkela, 2008

% KERN

if size(t, 2) > 1 
  error('Input can only have one column');
end

sigma = sqrt(2/kern.inverseWidth);
t = t - kern.delay;
halfSigmaD = 0.5*sigma*kern.decay;

lnPart1 = lnDiffErfs(halfSigmaD + t/sigma, halfSigmaD);
lnPart2 = lnDiffErfs(halfSigmaD, halfSigmaD - t/sigma);

h = exp(halfSigmaD*halfSigmaD + lnPart1)...
    - exp(halfSigmaD*halfSigmaD-(2*kern.decay*t) + lnPart2);

k = 2*h;
k = 0.5*k*sqrt(pi)*sigma;
k = kern.variance*k/(2*kern.decay);

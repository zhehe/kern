function [h, dh_ddelta, dh_dD_j, dh_dD_k, dh_dl] = disimComputeHPrime(t1, t2, delta, D_j, D_k, l)

% DISIMCOMPUTEHPRIME Helper function for comptuing part of the DISIM kernel.
% FORMAT
% DESC computes a portion of the DISIM kernel.
% ARG t1 : first time input (number of time points x 1).
% ARG t2 : second time input (number of time points x 1).
% ARG decay0 : Decay rate for the driving system.
% ARG decay1 : Decay rate for first system.
% ARG decay2 : Decay rate for second system.
% ARG l : length scale of latent process.
% RETURN h : result of this subcomponent of the kernel for the given values.
%
% DESC computes a portion of the SIM kernel and gradients with
% respect to various parameters.
% ARG t1 : first time input (number of time points x 1).
% ARG t2 : second time input (number of time points x 1).
% ARG decay0 : Decay rate for the driving system.
% ARG decay1 : Decay rate for first system.
% ARG decay2 : Decay rate for second system.
% ARG l : length scale of latent process.
% RETURN h : result of this subcomponent of the kernel for the given values.
% RETURN grad_D_decay0 : gradient of H with respect to DECAY0.
% RETURN grad_D_decay1 : gradient of H with respect to DECAY1.
% RETURN grad_D_decay2 : gradient of H with respect to DECAY2.
% RETURN grad_L : gradient of H with respect to length scale of
% latent process.
%
% COPYRIGHT : Neil D. Lawrence, 2006
%
% COPYRIGHT : Antti Honkela, 2007
%
% SEEALSO : disimKernParamInit, simComputeH

% KERN

if size(t1, 2) > 1 | size(t2, 2) > 1
  error('Input can only have one column');
end
dim1 = size(t1, 1);
dim2 = size(t2, 1);
t1 = t1;
t2 = t2;
t1Mat = repmat(t1, [1 dim2]);
t2Mat = repmat(t2', [dim1 1]);
diffT = (t1Mat - t2Mat);
invLDiffT = 1/l*diffT;
halfLD_k = 0.5*l*D_k;
h = zeros(size(t1Mat));

lnPart1 = lnDiffErfs(halfLD_k - t2Mat/l, ...
				halfLD_k);
lnPart2 = lnDiffErfs(halfLD_k + t1Mat/l, ...
				halfLD_k + invLDiffT);

lnCommon = halfLD_k.^2 - D_j*t1Mat - D_k*t2Mat ...
    - log(delta^2 - D_k^2) - log(D_j + D_k);

%lnFact1a = log(D_k + delta - (D_j + D_k)*exp((D_j-delta)*t1Mat));
lnFact1a1 = log(D_k + delta);
lnFact1a2 = log(D_j + D_k) + (D_j-delta)*t1Mat;
lnFact1b = log(delta - D_j);

lnFact2a = (D_j + D_k) * t1Mat;

h = exp(lnCommon + lnFact1a1 - lnFact1b + lnPart1) ...
    - exp(lnCommon + lnFact1a2 - lnFact1b + lnPart1) ...
    + exp(lnCommon + lnFact2a + lnPart2);

h = real(h);

l2 = l*l;

if nargout > 1
  dh_ddelta = -2*delta/(delta^2-D_k^2) * h ...
      - exp(lnCommon + lnPart1 ...
	    + log(D_k + D_j) ...
	    - 2 * lnFact1b) ...
      - exp(lnCommon + lnPart1 + lnFact1a2 - lnFact1b) ...
      .* (-t1Mat - 1/(delta - D_j));
  dh_ddelta = real(dh_ddelta);
  if nargout > 2
    dh_dD_j = (-t1Mat - 1 / (D_j + D_k)) .* h ...
	      + exp(lnCommon + lnFact1a1 - lnFact1b + lnPart1) ...
	      .* (1./(delta - D_j)) ...
	      - exp(lnCommon + lnFact1a2 - lnFact1b + lnPart1) ...
	      .* (1./(D_j + D_k) + t1Mat + 1./(delta - D_j)) ...
	      + t1Mat .* exp(lnCommon + lnPart2 + lnFact2a);
    dh_dD_j = real(dh_dD_j);
    if nargout > 3
      m1 = min((halfLD_k - t2Mat/l).^2, halfLD_k.^2);
      m2 = min((halfLD_k + t1Mat/l).^2, (halfLD_k + invLDiffT).^2);
      dlnPart1 = l/sqrt(pi) * (exp(-(halfLD_k - t2Mat/l).^2 + m1) ...
			       - exp(-halfLD_k.^2 + m1));
      dlnPart2 = l/sqrt(pi) * (exp(-(halfLD_k + t1Mat/l).^2 + m2) ...
			       - exp(-(halfLD_k + invLDiffT).^2 + m2));
      dh_dD_k = (l*halfLD_k + 2*D_k / (delta^2 - D_k^2)...
		 + (-t2Mat - 1 ./ (D_j + D_k))) .* h ...
		+ exp(lnCommon + lnFact1a1 - lnFact1b - m1) .* dlnPart1 ...
		- exp(lnCommon + lnFact1a2 - lnFact1b - m1) .* dlnPart1 ...
		+ exp(lnCommon + lnFact2a             - m2) .* dlnPart2 ...
		+ exp(lnCommon + lnFact1a1 - lnFact1b + lnPart1) ...
		.* (1 ./ (D_k + delta)) ...
		- exp(lnCommon + lnFact1a2 - lnFact1b + lnPart1) ...
		.* (1 ./ (D_j + D_k)) ...
		+ exp(lnCommon + lnPart2 ...
		      + log(t1Mat) + lnFact2a);
      dh_dD_k = real(dh_dD_k);
      if nargout > 4
	dh_dl = exp(lnCommon + lnFact1a1 - lnFact1b - m1) ...
		.* ((D_k/sqrt(pi) + 2*t2Mat/(l2*sqrt(pi))) ...
		    .* exp(-(halfLD_k - t2Mat/l).^2 + m1) ...
		    - (D_k/sqrt(pi) * exp(-halfLD_k.^2 + m1))) ...
		-exp(lnCommon + lnFact1a2 - lnFact1b - m1) ...
		.* ((D_k/sqrt(pi) + 2*t2Mat/(l2*sqrt(pi))) ...
		    .* exp(-(halfLD_k - t2Mat/l).^2 + m1) ...
		    - (D_k/sqrt(pi) * exp(-halfLD_k.^2 + m1))) ...
		+exp(lnCommon + lnFact2a - m2) ...
		.* ((D_k/sqrt(pi) - 2*t1Mat/(l2*sqrt(pi))) ...
		    .* exp(-(halfLD_k + t1Mat/l).^2 + m2) ...
		    - ((D_k/sqrt(pi) - 2*invLDiffT/(l*sqrt(pi))) ...
		       .* exp(-(halfLD_k + invLDiffT).^2 + m2)))...
		+ D_k.*halfLD_k.*h;
	dh_dl = real(dh_dl);
      end
    end
  end
end
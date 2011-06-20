function kern = rbfperiodic2KernParamInit(kern)

% RBFPERIODICKERNPARAMINIT RBFPERIODIC kernel parameter initialisation.
%
%	Description:
%	This kernel is a periodic kernel constructed by mapping a one
%	dimensional input into a two dimensional space,
%	
%	u_1(x) = cos(x), u_2(x) = sin(x)
%	
%	A radial basis function kernel is then applied in the resulting
%	two dimensional space. The resulting form of the covariance is
%	then
%	
%	k(x_i, x_j) = sigma2 * exp(-2*gamma *sin^2((x_i - x_j)/2)').
%	
%	The kernel, thereby, generates periodic functions in the space of
%	(u_1, u_2).
%	
%	See Rasmussen & Williams (2006) page 92 and and MacKay's 1998
%	introduction to Gaussian processes for further details.
%	
%	
%
%	KERN = RBFPERIODICKERNPARAMINIT(KERN) initialises the RBF derived
%	periodic kernel structure with some default parameters.
%	 Returns:
%	  KERN - the kernel structure with the default parameters placed in.
%	 Arguments:
%	  KERN - the kernel structure which requires initialisation.
%	
%
%	See also
%	RBFKERNPARAMINIT, KERNCREATE, KERNPARAMINIT


%	Copyright (c) 2007 Neil D. Lawrence
%	MODIFICATIONS : Andreas C. Damianou,  Michalis K. Titsias, 2011


if kern.inputDimension > 1
  error('PERIODIC kernel only valid for one-D input.')
end

kern.inverseWidth = 1;
kern.variance = 1;
kern.nParams = 3;

kern.period = 2*pi;

kern.factor = 2*pi/kern.period;

% Constrains parameters positive for optimisation.
kern.transforms.index = [1 2 3];
kern.transforms.type = optimiDefaultConstraint('positive');
kern.isStationary = true;

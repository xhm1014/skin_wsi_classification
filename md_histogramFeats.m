%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function computes the tpical histogram features

% Input:
%         img: the color image
%
%         bw: the foreground region
%         c:  the image channel


% Output:
%   stats: the features

% (c) Edited by Hongming Xu,
% Deptment of Eletrical and Computer Engineering,
% University of Alberta, Canada.  Feb, 2016
% If you have any problem feel free to contact me.
% Please address questions or comments to: mxu@ualberta.ca

% Terms of use: You are free to copy,
% distribute, display, and use this work, under the following
% conditions. (1) You must give the original authors credit. (2) You may
% not use or redistribute this work for commercial purposes. (3) You may
% not alter, transform, or build upon this work. (4) For any reuse or
% distribution, you must make clear to others the license terms of this
% work. (5) Any of these conditions can be waived if you get permission
% from the authors.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function stats=md_histogramFeats(imgTiles,bwTiles)

%% whole dermis histogram features
nn=length(imgTiles);
JJ=[];
for i=1:nn
    I=imgTiles{i};
    bw=bwTiles{i};
    J=I(logical(bw));
    JJ=[JJ;J];
end
[counts,binLocations]=imhist(JJ);
%--------------------------------------------------------------------------
% Now calculate its histogram statistics
%--------------------------------------------------------------------------
Prob           =counts./sum(counts);
% 2.1 Mean
Mean           =sum(Prob.*binLocations);
% 2.2 Variance
Variance       =sum(Prob.*(binLocations-Mean).^2);
% 2.3 Skewness
Skewness       = calculateSkewness(binLocations,Prob,Mean,Variance);
% 2.4 Kurtosis
Kurtosis       = calculateKurtosis(binLocations,Prob,Mean,Variance);
% 2.5 Energy
Energy         =sum(Prob.*Prob);
% 2.6 Entropy
%Entropy             = -sum(Prob.*log(Prob));          % original
%calculation
Entropy = -sum(Prob.*log(max(Prob,min(Prob(Prob~=0)))));

stats.Hf_mean=Mean;
stats.Hf_variance=Variance;
stats.Hf_skewness=Skewness;
stats.Hf_kurtosis=Kurtosis;
stats.Hf_energy=Energy;
stats.Hf_entropy=Entropy;

end

%--------------------------------------------------------------------------
% Utility functions
%--------------------------------------------------------------------------
function Skewness = calculateSkewness(Gray_vector,Prob,Mean,Variance)
% Calculate Skewness
term1    = Prob.*(Gray_vector-Mean).^3;
term2    = sqrt(Variance);
Skewness = term2^(-3)*sum(term1);
end

function Kurtosis = calculateKurtosis(Gray_vector,Prob,Mean,Variance)
% Calculate Kurtosis
term1    = Prob.*(Gray_vector-Mean).^4;
term2    = sqrt(Variance);
Kurtosis = term2^(-4)*sum(term1);
end
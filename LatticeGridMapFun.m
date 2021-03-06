function [LatGridMap, BW] = LatticeGridMapFun(pcData, varargin)
if nargin == 0
    DataFolder = 'D:\Data\Campus2018\Record-2018-04-18-23-36-33(SmallCircle)\BinaryData'; 
    nFrm = 1000; 
    filename = fullfile(DataFolder, sprintf('Binary%06d.txt', nFrm)); 
    pcData = HDLS3AnalyserFun(filename);
    pcData = pcData(1:3, :); 
    Coverage = [-100.0 100.0; -100.0 100.0];
    Res = 0.3;
end
OpenParFor();
switch (nargin-1)
    case 0
        Coverage = [-50.0 50.0; -50.0 50.0];
        Res = 0.2;
    case 1
        Coverage = [-50.0 50.0; -50.0 50.0];
        Res = varargin{1};
    case 2
        Coverage = varargin{1};
        Res = varargin{2};
    otherwise
end

[ImgInfo, XI, YI ] = CvtPtsToLatticeFun( pcData(1:2, :), Coverage, Res );
H_Wide = ImgInfo(1); W_Wide = ImgInfo(2);
EffIdx = find( XI > 0 & YI > 0 );
XI = XI(EffIdx);
YI = YI(EffIdx);
BW = zeros( H_Wide, W_Wide);
s_elem = struct('Points', [], 'RawIdx', [], 'Gap', -Inf, 'MPts', -Inf(3, 1), 'ptLow', [] ); 
LatGridMap( 1:1:W_Wide, 1:1:H_Wide) = s_elem;
ind = sub2ind( size(BW), YI, XI );
[C, ~, ~] = unique(ind);
[r c] = ind2sub(size(BW), C );
GMIdx = [r; c ]; 
Dim = size(pcData, 1 );
% use parallel computing to accerlate the process.
TotalPixel = [];
parfor i = 1 : 1 : length(C)   % C = ind(ia) or
    tmp = s_elem;
    Idx = find( ind == C(i) );
    x = GMIdx(1, i); 
    y = GMIdx(2, :);
    RealIdx = EffIdx(Idx);
    Pts = pcData(:, RealIdx);
    tmp.Points = Pts;
    tmp.MPts   = mean(Pts, 2); 
    tmp.RawIdx = RealIdx;        
    [~, minId] = min(Pts(3, :)); 
    tmp.ptLow = Pts(:, minId); 
    if Dim >= 3 && size(Pts, 2) >= 2 
        tmp.Gap = max(Pts(3, :)) - min(Pts(3, :));

    else
        tmp.Gap = -Inf;
    end
    TotalPixel = [TotalPixel tmp];
end
for i = 1 : 1 : length(TotalPixel)
    x = GMIdx(1, i);
    y = GMIdx(2, i);
    LatGridMap(y, x) = TotalPixel(i); 
    if TotalPixel(i).Gap >= 0.1
        BW(x, y) = 1.0;
    end
end
Gap = cat(1, LatGridMap(:).Gap ); 
Ind = find(Gap >= 0.2); 
ObsIdx = cat(2, LatGridMap(Ind).RawIdx); 
GrdIdx = find( ~ismember( 1:1:length(pcData), ObsIdx) ); 
obsData = pcData(1:3, ObsIdx); 
grdData = pcData(1:3, GrdIdx); 
if nargin == 0
    figure;
    hold on;
    grid on;
    pcshow(obsData', 'r', 'markersize', 20);
    pcshow(grdData', 'g', 'markersize', 20);
end
end


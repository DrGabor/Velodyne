function PolarGM = PolarGridMapFun( pcData, varargin )
if nargin == 0
    DataFolder = 'D:\Data\Campus2018\Record-2018-04-18-23-36-33(SmallCircle)\BinaryData';
    nFrm = 1000;
    filename = fullfile(DataFolder, sprintf('Binary%06d.txt', nFrm));
    pcData = HDLS3AnalyserFun(filename);
    pcData = pcData(1:3, :);
    RadArray = [ 0.0 : 0.3 : 30.0 20.5 : 0.5 : 80.0 ];
    AngRes   = deg2rad(2.0);
end
switch (nargin-1)
    case 0
        RadArray = [ 0.0 : 0.2 : 20.0 20.5 : 0.5 : 50.0 ];
        AngRes   = deg2rad(1.0);
    case 1
        AngRes = varargin{1};
        RadArray = [ 0.0 : 0.2 : 20.0 20.5 : 0.5 : 50.0 ];
    case 2
        RadArray = varargin{1};
        AngRes   = varargin{2};
    otherwise
end
if AngRes >= deg2rad(10.0)
    tmpStr = sprintf('The AngRes you define is %.2f degree, too big, is it the confusion of degree and radians? ', rad2deg(AngRes) );  
    warning(tmpStr); 
end
PolarGM = [];
[SegID BinID]  = CvtPtsToPolarFun( pcData, RadArray, AngRes );
%% construct polar grid map.
EffIdx = find( SegID > 0 & BinID > 0 );
SegID = SegID(EffIdx);
BinID = BinID(EffIdx);

SegNum = floor( 2 * pi / AngRes );
Idx = sub2ind( [SegNum length(RadArray)], SegID, BinID );
[C ia ic] = unique(Idx);
[r c] = ind2sub( [SegNum length(RadArray)], C );
GMIdx = [r; c];
TotalPixel = [];
s_elem = struct('Points', [], 'RawIdx', [], 'Gap', -Inf, 'MPts', [], 'ptLow', [] );
for i = 1 : 1 : length(C)
    x = GMIdx(1, i);
    y = GMIdx(2, :);
    tmp = s_elem;
    RealIdx = find( Idx == C(i) );
    RealIdx = EffIdx(RealIdx);
    tmp.RawIdx = RealIdx;
    Pts = pcData(:, RealIdx);
    if any(Pts(1, :) >= 40.0)
        bTest = 1; 
    end
    tmp.Points = Pts;
    tmp.MPts = mean(Pts, 2);
    [~, minId] = min(Pts(3, :));
    tmp.ptLow = Pts(:, minId);
    if size(tmp.Points, 2) >= 2
        tmp.Gap = max(Pts(3, :)) - min(Pts(3, :));
    end
    TotalPixel = [TotalPixel tmp];
end
PolarGM = repmat( s_elem, SegNum, length(RadArray) );
for i = 1 : 1 : length(C)
    x = GMIdx(1, i);
    y = GMIdx(2, i);
    PolarGM(x, y) = TotalPixel(i);
end
Gap = cat(1, PolarGM(:).Gap );
Ind = find( Gap >= 0.2 );
ObsIdx = cat(2, PolarGM(Ind).RawIdx); 
GrdIdx = find( ~ismember( 1:1:length(pcData), ObsIdx) ); 
obsData = pcData(1:3, ObsIdx); 
grdData = pcData(1:3, GrdIdx); 
%% Visualization part.
if nargin == 0
    figure;
    hold on;
    grid on;
    pcshow(obsData', 'r', 'markersize', 20);
    pcshow(grdData', 'g', 'markersize', 20);
end
end


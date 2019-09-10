function [RecData] = RecHDLQuatFun(pcData, t0, t1, PoseArray, IS_SHOW)
if nargin == 0
    clc; 
    DataRoot = 'D:\Data\Record-2016-10-24-10-54-01(HighWayL)';  'F:\Data\Record-2016-12-01-17-11-04(Est3RingL)';
    BinaryFolder = fullfile(DataRoot, 'BinaryData');
    nFrm = 400; 
    DataDir = fullfile(BinaryFolder, sprintf('Binary%d.txt', nFrm) );
    if ~exist(DataDir)
        DataDir = fullfile(BinaryFolder, sprintf('Binary%06d.txt', nFrm) );
    end
    pcData = HDLAnalyserNew(DataDir);
    poseInfo0 = zeros(1, 18); 
    poseInfo1 = ones(1, 18); 
    IS_SHOW = 1; 
end
if length(t0) > 1 
    t0 = GetTimeFun(t0); 
end
if length(t1) > 1 
    t1 = GetTimeFun(t1); 
end
UDPNum = 586; 
scanPeriod = 0.10;
RecData = [];  
scanPeriod = ( t1 - t0 ) / 1000.0;
if scanPeriod < 0
    error('Wrong scan!');
end
Time = GetPoseFun(PoseArray, 'time'); 
Time = GetTimeFun(Time); 
LocPose = GetPoseFun(PoseArray, 'local'); 
R0 = []; 
T0 = []; 
for i = 1 : 1 : UDPNum
    idx =find(pcData(end, :) == i);
    if isempty(idx)
        continue; 
    end
    tmpData = pcData(:, idx); 
    s = (i-1) / (UDPNum-1); 
	t = (1-s)*t0 +s*t1; 
    [NNIdx, DD] = knnsearch(Time, t); 
	if Time(NNIdx) <= t
		id0 = NNIdx; 
		id1 = NNIdx+1;
	else
		id0 = NNIdx-1; 
		id1 = NNIdx; 
	end
	pose0 = LocPose(id0, :); 
	pose1 = LocPose(id1, :); 
	tmpPose = InterpPoseFun(pose0, pose1, s); 
	[R1, T1] = Pose2RTFun(tmpPose);
	if isempty(R0)
	    R0 = R1; 
		T0 = T1; 
	end
	R = R0'*R1; 
	T = R0'*(T1 - T0); 
    data = Loc2Glo(tmpData(1:3, :), R', T); 
    
%     Diff = data - tmpData(1:3, :);
%     maxDist = max(sqrt(sum(Diff.^2))); 
%     str = sprintf('i = %03d, maxDist = %.2f', i, maxDist); 
%     disp(str); 
      
	NewData = [data; tmpData(4:end, :)]; 
    RecData = [RecData NewData]; 
end
IS_SHOW = 0; 
if IS_SHOW 
    figure; 
    hold on; 
    grid on; 
    view(3); 
    showPointCloud(pcData(1:3, :)', 'b'); 
    showPointCloud(RecData', 'k'); 
    legend('Original', 'Refined');
    [NNIdx, DD] = knnsearch(pcData(1:3, :)', RecData'); 
    figure; 
    hold on; 
    grid on;  
    hist(DD, 20); 
    xlabel('corrected meters'); 
    % plot(DD, 'b.'); 
end
end

function poseNew = InterpPoseFun(pose0, pose1, s)
	[R0, T0] = Pose2RTFun(pose0); 
	[R1, T1] = Pose2RTFun(pose1); 
    T = (1-s)*T0 + s*T1;
    USE_SLERP = 1; 
    if USE_SLERP
        epsilon = 1e-6; 
        R = R0 * slerp(eye(3), R0'*R1, s, epsilon); % slerp(R0, R1, s, epsilon);
        Ang = rotm2eul(R);
    else
        Ang0 = rotm2eul(R0);
        Ang1 = rotm2eul(R1);
        Ang = (1-s)*Ang0 + s*Ang1;
    end
    
    Ang = rad2deg(Ang);   % make sure the results are in degrees.
	poseNew = [T' Ang]; 
end
function [R T] = Pose2RTFun(pose)
    T = pose(1:3)'; 
    Ang = pose(4:6) .* [1 -1 1]; 
    R = eul2rotm(deg2rad(Ang)); 
end

% function pose = RT2PoseFun(R, T)
%     pose = zeros(1, 18); 
%     pose(1:3) = T'; 
%     Ang = atan2d(R(2, 1), R(1, 1)); 
%     pose(4) = Ang; 
% end


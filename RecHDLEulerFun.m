function [RecData] = RecHDLFun(pcData, poseInfo0, poseInfo1, IS_SHOW)
if nargin == 0
    clc; 
    DataRoot = 'F:\Data\HighWay\Record-2016-10-24-10-54-01(HighWayL)';  'F:\Data\Record-2016-12-01-17-11-04(Est3RingL)';
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
UDPNum = 586; 
scanPeriod = 0.10;
pose0 = GetPoseFun(poseInfo0, 'local');
pose1 = GetPoseFun(poseInfo1, 'local');
[R0, T0] = Pose2RTFun(pose0);
[R1, T1] = Pose2RTFun(pose1);
dR = R0'*R1;
dT = R0'*(T1-T0);    
pose0 = RT2PoseFun(dR, dT); 
RecData = [];  
t0 = GetPoseFun(poseInfo0, 'time'); 
t1 = GetPoseFun(poseInfo1, 'time'); 
scanPeriod = GetTimeFun( t1 - t0 ) / 1000.0;
if scanPeriod < 0
    error('Wrong scan!');
end
for i = 1 : 1 : UDPNum
    idx =find(pcData(end, :) == i);
    if isempty(idx)
        continue; 
    end
    tmpData = pcData(:, idx); 
    s = (i-1) / (UDPNum-1); 

    tmpPose = s*pose0;
    [R, T] = Pose2RTFun(tmpPose);
    NewData = Loc2Glo(tmpData(1:3, :), R', T); 
    RecData = [RecData NewData]; 
end
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

function [R T] = Pose2RTFun(pose)
    T = pose(1:3)'; 
    Ang = pose(4); 
    R = eul2rotm([deg2rad(Ang) 0 0]); 
end

function pose = RT2PoseFun(R, T)
    pose = zeros(1, 18); 
    pose(1:3) = T'; 
    Ang = atan2d(R(2, 1), R(1, 1)); 
    pose(4) = Ang; 
end


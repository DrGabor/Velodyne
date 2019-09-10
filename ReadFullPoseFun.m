function PoseData = ReadFullPoseFun(DataRoot)
if nargin == 0
    DataRoot = 'D:\Data\iVPC\Record-2017-10-23-12-58-54(EightShape)'; 
    'D:\Data\Garage\Record-2017-10-14-15-00-05Evaluation'; 
    'D:\Data\Garage\Record-2017-10-14-14-52-17Map'; 
    'D:\Data\Garage\Record-2017-10-22-20-00-05(PoseIsValid)';  
    'D:\Data\Campus2018\Record-2018-04-19-00-09-41(BigCircle)'; 
    'D:\Data\Sudoku\Record-2017-11-15-15-53-28(SudokuRandomRoute)';
    'J:\Record-2017-10-31-10-30-51(3RingFull)';
    'F:\Data\Record-2016-08-23-12-40-46(GAC AntiCW, Pose 50Hz)\';
end
PoseData = [];
SimplePoseDir = fullfile(DataRoot, 'SimplePose.txt');
if ~exist(SimplePoseDir)
    CvtPoseFun(DataRoot);
end
A = load(SimplePoseDir);
PoseData = [A(:, 1:6) A(:, 8) A(:, 9:15) A(:, end-3:end)];
if nargin == 0
    time = GetPoseFun(PoseData, 'time');
    Gap = time(2:end, :) - time(1:end-1, :);
    time = GetTimeFun(Gap);
    figure;
    plot(time, 'b.');
    title('Pose Capture');
    LocalPose = GetPoseFun(PoseData, 'local');
    figure;
    subplot(3, 1, 1);
    plot(LocalPose(:, 4), 'b.--' );
    title('local head');
    subplot(3, 1, 2);
    plot(LocalPose(:, 5), 'b.--' );
    title('local pitch');
    subplot(3, 1, 3);
    plot(LocalPose(:, 6), 'b.--' );
    title('local roll');
    
    figure;
    hold on;
    axis equal;
    grid on;
    plot3(LocalPose(:, 1), LocalPose(:, 2), LocalPose(:, 3), 'k.' );
    plot3(LocalPose(1, 1), LocalPose(1, 2), LocalPose(1, 3), 'rh' );
    plot3(LocalPose(end, 1), LocalPose(end, 2), LocalPose(end, 3), 'bh' );
    title('Local trajectory');
    
    GlobalPose = GetPoseFun(PoseData, 'global');
    Diff = GlobalPose(2:end, 1:2)' - GlobalPose(1:end-1, 1:2)';
    Dist = sum(sqrt(sum(Diff.^2))); 
    figure;
    subplot(3, 1, 1);
    plot(GlobalPose(:, 4), 'b.--' );
    title('global head');
    subplot(3, 1, 2);
    plot(GlobalPose(:, 5), 'b.--' );
    title('global pitch');
    subplot(3, 1, 3);
    plot(GlobalPose(:, 6), 'b.--' );
    title('global roll');
    
    figure;
    hold on;
    axis equal;
    grid on;
    plot3(GlobalPose(:, 1), GlobalPose(:, 2), GlobalPose(:, 3), 'k.' );
    plot3(GlobalPose(1, 1), GlobalPose(1, 2), GlobalPose(1, 3), 'rh' );
    plot3(GlobalPose(end, 1), GlobalPose(end, 2), GlobalPose(end, 3), 'bh' );
    str = sprintf('Global trajectory, distance = %.1fm', Dist); 
    title(str);
    bTest = 1;
end


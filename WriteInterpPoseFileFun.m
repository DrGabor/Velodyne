function WriteInterpPoseFileFun(DataRoot)
if nargin == 0
DataRoot = 'C:\Users\lucaswang\Desktop\IVFC2019\HDL_S3\Calibration_File\Record-2019-08-21-18-53-59UnderGround'; 
end
PoseData = ReadFullPoseFun(DataRoot);
DataDir = fullfile(DataRoot, 'TimeStamp.txt'); 
[STime, ETime] = ReadTimeStampFun(DataDir);
Pose_S = IterpPoseFun(PoseData, STime);
Pose_E = IterpPoseFun(PoseData, ETime);

LPose = GetPoseFun(Pose_S, 'local'); 
GPose = GetPoseFun(Pose_S, 'global'); 
Time = GetPoseFun(Pose_S, 'time'); 

% // ±£¥Ê∏Ò Ω£∫1 vh 2 vv 3 vx 4 vy 5 gh 6 gv 7 gx 8 gy 9 theta 10 flag 11 hour 12 minute 13second  14milisecond
% 	ofInsertedPose << "----------" << nFrm << "----------" << std::endl
DataDir = fullfile(DataRoot, 'InsertedPose.txt'); 
fid = fopen(DataDir, 'w'); 

for id = 1 : 1 : length(Pose_S)
    str = sprintf('----------%04d----------\n', id-1); 
    fprintf(fid, str); 
    pose_l = LPose(id, :); 
    pose_g = GPose(id, :); 
    time = Time(id, :); 
    str = sprintf('%.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %.4f %d %04d %04d %04d %04d\n', ...
        pose_l(4), pose_l(7), pose_l(1), pose_l(2), pose_g(4), pose_g(end), pose_g(1), pose_g(2), 0.0, 0, ...
        time(1), time(2), time(3), time(4) ); 
    for i = 1 : 1 : 3
        fprintf(fid, str);
    end
end

fclose(fid); 
end

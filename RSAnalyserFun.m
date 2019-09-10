%% RS 32 LiDAR, written by Zhen Ye. 
function pcData = RSAnalyserFun( DataDir, IS_SHOW )
if nargin == 0
    clc; close all;
    nFrm = 5000;
    DataRoot =  'E:\BaiduNetdiskDownload\1left\BinaryData';
    str = sprintf('Binary%d.txt', nFrm);
    DataDir = fullfile(DataRoot, str);
    IS_SHOW = 1;
end
if nargin == 1
    IS_SHOW = 0; 
end
%left params
Calibration_Angle_horiz32= [ 8.2, 8.459, 7.9282, -7.9558, 8.4482, -7.7385, 7.6578, -7.713, -7.893, -2.5998, 2.6374, 7.9247, -7.6531, -2.2888, 3.0179, 8.19, -7.7172, -7.9248, -7.2878, -7.5635, -7.4848,-2.2064, 3.026, 8.2407, -7.6985, -2.4092, 2.8534, 8.0558, -7.9215, -2.5471, 2.7183, 7.9422 ];
Calibration_Angle32 = [ -10.316, -6.4594, 2.2972, 3.3687, 4.667, 7, 10.333, 15, 0.333, 0, -0.2972, -0.667, 1.667, 1.333, 0.9642, 0.667, -24.971, -14.638, -7.9451, -5.407, -3.667, -4, -4.333, -4.667, -2.333, -2.667, -3, -3.333, -1,- 1.333, -1.667, -2 ];
%% Read binary data from .txt.
fid = fopen(DataDir, 'rb' );
BinaryData = fread(fid, 'uint8=>uint16');
UDPNum = length(BinaryData) / 1248;
A = reshape( BinaryData, 1248, UDPNum);
A = A(:, 1:1:150); 
fclose(fid);
%% Extract x y z r line
pcData = zeros(64128,5);
EffIdx = []; 
for udpi =1:1:size(A, 2)
    a = A(43:end-6,udpi);
    for nAng=0:12-1
        azimuth=256*a(nAng*100+3)+a(nAng*100+4);
        for nline=0:31
            ind=udpi * 12 * 32 + nAng * 32 + nline;
            dsr=nline;
            distance=256*a(nAng*100+nline*3+5)+a(nAng*100+nline*3+6);
            a(nAng*100+nline*3+5);
            intensity=a(nAng*100+nline*3+7);
            distance2=double(distance)*0.005;
            if distance2 > 100 || distance2 < 2.5
                continue; 
            end
            arg_horiz = pi*double(azimuth + Calibration_Angle_horiz32(dsr+1) * 100) / 18000 ;
            arg_vert = Calibration_Angle32(dsr+1) / 180 * pi;
            x = distance2 * cos(arg_vert) * cos(arg_horiz);
            
            y = -distance2 * cos(arg_vert) * sin(arg_horiz);
            z = distance2 * sin(arg_vert);
            r=intensity;
            line=nline;
            pcData(ind,1)=x;
            pcData(ind,2)=y;
            pcData(ind,3)=z;
            pcData(ind,4)=r;
            pcData(ind,5)=line;
            EffIdx(end+1) = ind; 
        end
    end
end
pcData = pcData(EffIdx, :);
%%%%%%% this is to delete the near vehicle points. 
Ang = atan2d(pcData(:, 2), pcData(:, 1)); 
NffIdx = find( Ang >= 90.0 & Ang <= 180.0); 
pcData(NffIdx, :) = []; 
if IS_SHOW
    figure;
    pcshow(pcData(:, 1:3));
    str = sprintf('PointsNum = %d', length(pcData)); 
    xlabel('X/m'); 
    ylabel('Y/m'); 
    title(str); 
end

%  pcshow(pc(:,1:3),pc(:,4))








function [ STime, ETime ] = ReadTimeStampFun( DataDir )
if nargin == 0
    clc; close all; 
    DataRoot = 'C:\Users\lucaswang\Desktop\IVFC2019\HDL_S3\Calibration_File\Record-2019-08-21-18-53-59UnderGround'; 
    'E:\XJTU\Sudoku\Record-2017-11-15-15-53-28(SudokuRandomRoute)'; 
    'C:\Users\lucaswang\Desktop\IVFC2019\HDL_S3\Record-2019-08-21-17-43-10'; 
    DataDir = fullfile(DataRoot, 'TimeStamp.txt'); 
end
fid = fopen(DataDir, 'r' );
STime = [];
ETime = [];
while 1
    for i = 1 : 1 : 3
        tLine = fgetl(fid);
        if tLine == -1
            break;
        end
        if i == 2 | i == 3
            [wh wm ws wms] = strread(tLine, '%d:%d:%d:%d');
            if i == 2
                STime(end+1, :) = [wh wm ws wms];
            end
            if i == 3
                ETime(end+1, :) = [wh wm ws wms];
            end
        end
    end
    if tLine == -1
        break;
    end
end
fclose(fid);
if nargin == 0
%     Gap = ETime - STime;
%     tmp = ( ( Gap(:, 1)*60 + Gap(:, 2) ) * 60 + Gap(:, 3) ) * 1000 + Gap(:, 4);
%     figure;
%     plot(tmp, 'b.--' );
%     title('Capture time');
    Gap = STime(2:end, :) - STime(1:end-1, :);
    tmp = ( ( Gap(:, 1)*60 + Gap(:, 2) ) * 60 + Gap(:, 3) ) * 1000 + Gap(:, 4);
    TTime = GetTimeFun( STime(end, :) - STime(1, :) );
    frequence = size(STime, 1) / (TTime / 1000); 
    figure;
    hold on; 
    grid on; 
    plot(tmp, 'b.--' );
    title( sprintf( 'Gap between frames, Frequence = %.2fHz', frequence) );
    xlabel('Frame No.'); 
    ylabel('Time/ms'); 
end
end


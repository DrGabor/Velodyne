function SplitBigBinaryFun( DataRoot )
if nargin == 0
    DataRoot = 'C:\Users\lucaswang\Desktop\IVFC2019\HDL_S3\Calibration_File\Record-2019-08-21-18-53-59UnderGround';
    % error('SplitBigBinary is wrong!');
end
DataDir = fullfile(DataRoot, 'RawBinaryData.txt');
fid = fopen(DataDir, 'rb');
if fid == -1
    error( strcat( DataRoot, 'RawBinaryData.txt not exists!') );
end
Count = 0;

SaveFolder = fullfile(DataRoot, 'BinaryData' );
if exist(SaveFolder)
    disp( strcat(SaveFolder, ' this folder is already existing, check if it is already splited, or delete this folder and run programs again') );
end
mkdir(SaveFolder);
tic
while 1
    BinaryData = fread(fid, 586 * 1206, 'uint8=>uint16' ); % 365
    if isempty(BinaryData)
        break;
    end
    str = sprintf('Binary%06d.txt', Count);
    SaveDir = fullfile(SaveFolder, str );
    tmpfid = fopen(SaveDir, 'wb');
    fwrite( tmpfid, BinaryData );
    fclose(tmpfid);
    Count = Count + 1;
    str = sprintf('split binary data, %06d', Count - 1);
    disp(str);
end
fclose(fid);
%%%%%%%%% delete the last binary file because it may contain less bytes. 
delete(SaveDir); 
bTest = 1; 
toc
end
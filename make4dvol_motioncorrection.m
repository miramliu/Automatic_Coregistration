%this is code to correct for motion in patient scans for processing DSC .
%done in comparison to spect. 
%will take in all ep2d_perf dicoms, convert to a 4d nifti file which can be registered  
%very inefficient brute force, sorry.

%input(targetpath to dcm, totalslices, totaltimes, scan type (ep2dperf, LLPre, LLPost) )
%Mira Liu march 2022

function fourDarray = make4dvol_motioncorrection(varargin)

targetpath = varargin{1};
totalslices = varargin{2};%25;
totaltimes = varargin{3};%60;

%if it's perfusion scan that we want to get the 4d volume for
if strcmp(varargin{4},'ep2dperf') == 1 
    fulltargetpath = [targetpath '/ep2d_perf'];
    dscdir = dir([fulltargetpath '/*.dcm']); %get all dcm files (in folder P00N)
    
    tic
    fprintf('Now analyzing %s ...\n',fulltargetpath)
    dscdirsorted = {dscdir.name};
    dscdirsorted = natsortfiles(dscdirsorted); %sort in order

    totalimages = totalslices*totaltimes;
    if totalimages ~= size(dscdirsorted,2)
        error('check number of slices and time points. Image number does not match.')
    end
    [nx,ny] = size(dicomread(string(fullfile(fulltargetpath,dscdirsorted(1))))); %get image dimensions
    fprintf('Going through slices and time points...\n')
    
    %get all the friggen slices(i.e. going throughh 1500 images)
    %slices = transpose(1:totalslices);
    slice = 0; %start off at slice = 1, corrected June 27th 2022
    
    %now get all the time points (i.e 1-60 as each slice has all of the timme points lined up in order from DSc sort . ipynb)
    times = zeros(totaltimes,1);
    for i = 1:totaltimes
        imagepath = string(fullfile(fulltargetpath,dscdirsorted(i))); %path to ith image
        info = dicominfo(imagepath);
        timenum = str2double(info.(dicomlookup('0008', '0033'))); %get time
        times(i) = timenum; %add it
    end
    
    fprintf('Creating 4d array now\n')
    %create an array in order (of 4d volumes, 3d volumes over time)
    fourDarray = zeros(nx,ny,totalslices,totaltimes); %created empty 4d array
    for i = 1:size(dscdirsorted,2) %for all of the dsc files
        imagepath = string(fullfile(fulltargetpath,dscdirsorted(i))); %path to ith image
        info = dicominfo(imagepath);
        image = dicomread(imagepath);
        %disp(dscdirsorted(i))
        %disp(double(info.(dicomlookup('0020','0013'))))
        slicenum = dscdirsorted(i);
        slicenum = slicenum{1};
        fprintf('For image:  %s\n',slicenum)
        slicenum = slicenum(1:end-4); % get rid of.dcm
        slicenum = str2num(slicenum); %make number
        if mod(slicenum-1,totaltimes)+1 == 1 %still gotta check and fix this... blech
            slice = slice+1; %every time it reaches a multiple of 60, it's a new slice.
        %else, it's in the same slice
        end
        slicenumidx = slice;
        %timenum = str2double(info.(dicomlookup('0008', '0033')));
        timenumidx = dscdirsorted(i);
        timenumidx = timenumidx{1};
        timenumidx = timenumidx(1:end-4);
        timenumidx = str2num(timenumidx);
        timenumidx = mod(timenumidx-1,totaltimes)+1; %find which of the time points (in order) this is
        
        fprintf('slice idx %.0f \n',slicenumidx);
        fprintf('time idx %.0f \n\n',timenumidx);
        fourDarray(:,:,slicenumidx,timenumidx) = image; %make that image for the corresponding slice and time 
        
    end
    %save("Users/neuroimaging/Desktop/fourDarray.m",fourDarray)
    %print(slicenumidx)
    toc
    fprintf('done\n')


% if it's T1Pre and T1Post we want to coregister
elseif strcmp(varargin{4}, 'LLPre') == 1 || strcmp(varargin{4}, 'LLPost') == 1
    if strcmp(varargin{4}, 'LLPre') == 1
        fulltargetpath = [targetpath 'LL_EPI_PRE'];
        dscdir = dir([fulltargetpath '/*.dcm']); %get all dcm files (in folder P00N)

        
    elseif strcmp(varargin{4}, 'LLPost') == 1
        fulltargetpath = [targetpath 'LL_EPI_POST']; %sometimes IR or LL
        dscdir = dir([fulltargetpath '/*.dcm']); %get all dcm files (in folder P00N)

    end
    tic
    dscdirsorted = {dscdir.name};
    try
        dscdirsorted = natsortfiles(dscdirsorted); %sort in order
    catch
        error('check LL EPI folder name, does it have IR?')
    end

    totalimages = totalslices*totaltimes;
    if totalimages ~= size(dscdirsorted,2)
        error('check number of slices and time points\nImage number does not match\n')
    end
    [nx,ny] = size(dicomread(string(fullfile(fulltargetpath,dscdirsorted(1))))); %get image dimensions
    fprintf('Going through acquired images...\n')
    times = transpose(1:totaltimes); %this is total numer of images taken over time (for t1 calc, so dicom header saves it as 'image number')
    
    fprintf('creating 4d array now....\n')
    %create an array in order (of 4d volumes, 3d volumes over time)
    fourDarray = zeros(nx,ny,totalslices,totaltimes); %created empty 4d array
    for i = 1:size(dscdirsorted,2) %for all of the dsc files
        imagepath = string(fullfile(fulltargetpath,dscdirsorted(i))); %path to ith image
        info = dicominfo(imagepath);
        image = dicomread(imagepath);
        %slicenum = double(info.(dicomlookup('0020','0013')));
        %timenum = str2double(info.(dicomlookup('0008', '0033')));
        imagenum = (info.(dicomlookup('0020','0013'))); %this gives 'image number'
        slicenumidx = 1; %only one slice
        timenumidx = find(times == imagenum); %find which of the time points (in order) this is
        fourDarray(:,:,slicenumidx,timenumidx) = image; %make that image for the corresponding slice and time 
    end
    toc
    fprintf('Done\n')

else
    error('\nis this for ep2dperf, LLPre, or LLPost?\n')
end













%count how many slices and time points there are
%the following would do it autommatically but it's being really dumb so instead it's hardcoded
%{
slices = [];
times = [];
[nx,ny] = size(dicomread(string(fullfile(targetpath,dscdirsorted(1))))); %get image dimensions
for i = 1:size(dscdirsorted,2) %for all of the dsc files
    imagepath = string(fullfile(targetpath,dscdirsorted(i))); %path to ith image
    info = dicominfo(imagepath);
    slicenum = info.(dicomlookup('0020','0013'));
    timenum = info.(dicomlookup('0008', '0033'));
    if ~ismember(slicenum, slices) %if slice number hasn't been seen yet
        slices = [slices, slicenum]; %add it
    end
    if ~ismember(timenum,times) %if time hasn't been seen yet
        times = [times, timenum]; %add it
    end
end
totalslices = max(slices); %number of slices is the largest slice number... 
totaltimes = size(dscdirsorted,2)/totalslices; %time points per slice... 
%}







end
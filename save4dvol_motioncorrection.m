% this is code to get niftifiles that have been coregistered, 
% import than and export them again as the correct dicom files for qCBF processing
% Mira Liu march 2022

function save4dvol_motioncorrection(varargin)

dscpath = varargin{1}; %path to original folder dsc images, so x/xxx/x/P001
niftipath = varargin{2}; %path to coregistered nifti images
ptname = varargin{3}; %pt name (like pt2 etc)
totalslices = varargin{4}; %how many slices
totaltimes = varargin{5}; %how mmany time points

%create new directory for coregistered dicoms to be put and move originals to 'old' folder
olddscpath = [dscpath 'ep2d_perf_notCoreg']; %create new folder
if ~ exist(olddscpath, 'dir')
    tic
    mkdir (olddscpath) %create new folder
    movefile([dscpath 'ep2d_perf/' '*.dcm'], olddscpath) %move all original dicoms to old dscpath
end
fprintf('Created new folder, now rewriting\n')
toc


%go through the coregistered niftis and make them into dicoms WITH THE SAME HEADERS
if numel(dir([dscpath '/ep2d_perf/'])) <=2
    tic
    times = transpose(1:totaltimes); %so 1:60
    %get 3D volume for each timepoinot
    for i = 1:totaltimes
        num = num2str(times(i), '%.0f');
        prefix = ['r' num];
        niftiname = [prefix ptname '_dsc4d.nii'];
        nii_t = niftiread(fullfile(niftipath,niftiname)); %read in the 3D volume of the nifti at a given time point
        nii_3d = squeeze(nii_t(:,:,:,i)); %get the time of interest, this is now 3D
        %now separate it into slices
        for j = 2:totalslices
            nii_2d = uint16(squeeze(nii_3d(:,:,j))); %now specific slice at specific time, this is now 2D
            %figure,imshow(nii_2d,[]),colormap(gca,'jet'),colorbar %looks reasonalbe, wtf is happening with dicomwrite??
            %now save it as correct number dicom, get dicom header info from original dicom, and export into new folder
            k = num2str(totaltimes*(j - 1) + i,'%.0f'); %so for example, the 62nd image is 60*(slice 2 - 1) + 2
            metadata = dicominfo([olddscpath '/' k '.dcm']); %load data for the kth dcm image
            dicomwrite(nii_2d,[dscpath 'ep2d_perf/' k '.dcm'],metadata) %write data for the kth dcm image in original folder
        end
        for j = 1 %first slice is registered to itself, so just copy old to new!
            k = num2str(totaltimes*(j - 1) + i,'%.0f');
            copyfile([olddscpath '/' k '.dcm'], [dscpath 'ep2d_perf/' k '.dcm'])
        end
    end
    
    toc
end


fprintf('Done\n')
%}






end


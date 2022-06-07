%% Calling function for automatic coregistration of DSC perfusion images.
% Mira Liu March 2022 
% Function decomposition used to coregister DSC Perfusion scans (ep2d_perf) 
% Requirements: written on Matlab2021b, requires installation of SPM12_1776
% Function Description: 
% Input: 
    % path to folder of SORTED DICOMS. 
        % (these are 3 folders in a folder P00N, these 3 folders are LL-PRE, LL-POST, and ep2dperf)
        % The scans within these folders must already be sorted. See DSCPerfusionSorter.ipynb
    % path to niftis, this should be a folder devoted to the converted nifti files 
    % pt name for identification, input as a string, i.e. 'pt1'
    % total slices (number of slices in the 3D volumes)
    % total times (number of time points, or 4th dimension of 4d volume)
    % scantype (is it the 'LLPre', 'LLPost', or 'ep2dperf' to be registered?)
% Output: 
    % coregistered sorted dicoms with the proper headers in the original folder noted along the 'dcmpath' ready for post-processing.

%% for ep2dperf
% first convert the dicom images into a 4d volume (3D volumes over time) and write it as a nifti in the nifti folder.
% then coregister those sequential 3D volumes to the FIRST 3D volume (using SPM)
% then move the un-coregistered files to another folder, save those coregistered files as dicoms in the original folder numbered correctly with the proper headers from the original dicoms. 

%% for LLPre and LLPost
% as these are 2D images, cannot use SPM on them. 
% can, however estimate coregisteration by hand with rotation and zooming on coresgistration_setup.m app.
% then can input those values and again output the coregistered sorted dicoms with proper headers into the original folder noted. 


function DSCPerfusion_MotionCorrection(varargin)

dcmpath = varargin{1}; %'/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_DSC_sorted/P001/
niftipath = varargin{2};%'/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_niftis/
ptname = varargin{3}; %'pt2'
totalslices = varargin{4}; % 25
totaltimes = varargin{5}; % 60
scantype = varargin{6}; % 'ep2dperf'

if strcmp(scantype,'ep2dperf')== 1

    %first check to make sure this hasn't been done yet
    niiperfpath = [niftipath '/DSCPerf/'];
    if ~ exist([niiperfpath ptname '_dsc4d.nii'], 'file')
        %make 4d array from original dicoms
        fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'ep2dperf');
        %save this 4d array in a new folder for nii
        if ~ exist(niiperfpath,'dir')
            mkdir(niiperfpath)
        end
        niftiwrite(fourDarray,[niiperfpath ptname '_dsc4d.nii']); %save this as the 4D volume in the perf folder (named pt2_dsc4d)
    end

    %check to make sure coregistration hasn't occured yet
    if ~exist([niiperfpath 'r' num2str(totaltimes,'%.0f') ptname '_dsc4d.nii'], 'file') %if last time point hasn't been coregistered
        %coregister from that saved 4d nifti to the first time point
        coregvol_job([niiperfpath ptname '_dsc4d.nii'],totaltimes)
    end
    
    %save coregistered files
    if ~ exist([dcmpath 'ep2d_perf_notCoreg/'],'dir') || ~ exist([dcmpath 'ep2d_perf/' num2str(totalslices*totaltimes,'%.0f') '.dcm'], 'file') %if the last dcm file doesn't exist
        save4dvol_motioncorrection(dcmpath,niiperfpath,ptname,totalslices,totaltimes)
    end


elseif strcmp(scantype,'LLPre')== 1
    if ~ exist ([niftipath '/LLPre/' ptname '_LLPre4d.nii'], 'file')
        fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'LLPre');
        if ~ exist([niftipath '/LLPre/'],'dir')
            mkdir([niftipath '/LLPre/'])
        end
        niftiwrite(fourDarray,[niftipath '/LLPre/' ptname '_LLPre4d.nii'])
    end
    fprintf('If both LLPre and Post have been converted to 4D nii files...\nUse T1_DSCcoregistration to get zoom and rotation degree of the 4D nii by hand\n')

elseif strcmp(scantype, 'LLPost')==1
    if ~ exist([niftipath '/LLPost/' ptname '_LLPost4d.nii'],'file')
        fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'LLPost');
        if ~ exist([niftipath '/LLPost/'],'dir')
            mkdir([niftipath '/LLPost/'])
        end
        niftiwrite(fourDarray,[niftipath '/LLPost/' ptname '_LLPost4d.nii'])
    end
    fprintf('If both LLPre and Post have been converted to 4D nii files...\nUse T1_DSCcoregistration to get zoom and rotation degree of the 4D nii by hand\n')



end


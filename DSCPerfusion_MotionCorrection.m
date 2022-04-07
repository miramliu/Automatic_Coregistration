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
    %make 4d array from original dicoms
    fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'ep2dperf');
    niftiwrite(fourDarray,[niftipath 'DSCPerf/' ptname '_dsc4d.nii'])
    
    %coregister from that 4d nifti to the first time point
    coregvol_job([niftipath ptname '_dsc4d.nii'],totaltimes)
    
    %save coregistered files
    save4dvol_motioncorrection(dcmpath,niftipath,ptname,totalslices,totaltimes)
elseif strcmp(scantype,'LLPre')== 1
    fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'LLPre');
    niftiwrite(fourDarray,[niftipath 'LLPre/' ptname '_LLPre4d.nii'])
    fprintf('Now use T1_DSCcoregistration to get zoom and rotation degree of the 4D nii by hand\n')

elseif strcmp(scantype, 'LLPost')==1
    fourDarray = make4dvol_motioncorrection(dcmpath,totalslices,totaltimes,'LLPost');
    niftiwrite(fourDarray,[niftipath 'LLPost/' ptname '_LLPost4d.nii'])
    fprintf('Now use T1_DSCcoregistration to get zoom and rotation degree of the 4D nii by hand\n')




end


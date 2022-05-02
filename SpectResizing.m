%% This is code written for coregistration of DSC to SPECT in ICAD study
% STEPS: 
%1.	COREGISTER_SETUP(dscpath,spectpath)
    %a.	THIS ALLOWS YOU TO BY EYE ZOOM IN AND CROP, CHOOSE THE SUBSECT OF SPECT SLICES THAT MATCH THE RANGE OF DSC SLICES
    %b. input path to post-processed DS P001.mat and path to raw spect dcm.
    %e.g. dcmpath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_DSC_sorted/Result_MSwcf2/P001GE_M.mat';
    %spectpath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_SPECT_sorted/00001_7d86dd681e6f9e68.dcm';
    % >> coregistration_setup(dscpath,spectpath)
    %record zoom, min slice range and max slice range for use in spectresizing.m

%2.	SPECTRESIZING.M (that's this code right here)
    %a.	THIS ALLOWS YOU TO CROP, CHOOSE SLICES, ROTATE THE SPECT (and dsc) TO MATCH EACH OTHER AND THEN EXPORT THEM AS NIFTI FILES
    %b. make sure to change the inputs shown below

%3.	SPM
    %a.	NOW COREGISTER THESE IMAGES, OUTPUTS rptN_spect.nii
    %b. click co register: estimate & reslice. 
    %c. choose reference image as the DSC nifti file this matlab script creates.
    %d. choose source image as the SPECT nifti file this matlab script creates. 

%4.	COREGISTER_SETUP(dscsavepath,spectsavepath)
    %a.	THIS ALLOWS YOU TO COMPARE NOW THE DSC AND THE COREGISTERED SPECT FILE AND CHECK TO MAKE SURE IT WORKED 
    %b. new spect should be the same as saved path, but with r in front (e.g. pt2_spect.nii -> rpt2_spect.nii)
    %e.g. dscsavepath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_niftis/DSCPerf/pt2_dsc.nii';
    % spectnewpath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_niftis/SPECT/rpt2_spect.nii'
    % >> coregistration_setup(dscsavepath,spectnewpath,1)

% Mira Liu May 02 2022

%% inputs:
spectpath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt4/pt4_SPECT_sorted/00001_807d1589e351e59d.dcm';
spectsavepath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt4/pt4_niftis/SPECT/';
dscpath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt4/pt4_DSC_sorted/Result_MSwcf2/P001GE_M.mat';
dscsavepath = '/Users/neuroimaging/Desktop/DATA/ASVD/Pt4/pt4_niftis/DSCPerf/';


%% SPECT cropping and resizing
spect = dicomread(spectpath);
[spectx,specty,spectz] = size(spect);
%this is the number of pixel rows (i.e. number of 'up' and 'down' or 'left' and 'right' in which to move the spect image BEFORE zooming. follows cartesian grid i.e. negative is left and down. for example, 2 pixel rows down, and 3 pixel rows to the left is [-3,-2] 
leftright = 2; 
updown = -1;
Zoom = 55; %what is zoom 3een on coregister_setup
rmpixels = round(Zoom/2);
minslicerange = 58; %what is lowest slice with sPECT signal of interest
maxslicerange = 90; %what is highest slice with SPECT signal of interest

if leftright < 0 %if it's negative, move to the left 'leftright' number of pixels
    newim = spect(:,-leftright:end,:);
    zeropad = zeros(spectz,-leftright,spectz);
    spectshift = [newim zeropad];
elseif leftright > 0
    newim = spect(:,1:end-leftright,:); %if it's positive, move to the right 'leftright' number of pixels
    zeropad = zeros(spectx,leftright,spectz);
    spectshift = [zeropad newim];
else
    spectshift = spect;
end

if updown < 0 %move it down
    newim = spectshift(1:end-(-updown), :,:);
    zeropad = zeros(-updown, specty, spectz);
    spectshift = [zeropad;newim];
elseif updown > 0 %move it up!
    newim = spectshift(updown:end,:,:);
    zeropad = zeros(updown:end,:,:);
    spectshift = [newim;zeropad];
else
    spectshift = spect;
end




spect_cropped = spectshift(rmpixels:end-rmpixels,rmpixels:end-rmpixels,minslicerange:maxslicerange);
pt_spect = imresize3(spect_cropped,[128 128 maxslicerange-minslicerange+1]); 
pt_spect = flip(imrotate(pt_spect,270),3); %flip upsidedown! commmennt out if SPECT is correct side up
if ~ exist(spectsavepath,'dir')
    mkdir(spectsavepath)
end
niftiwrite(pt_spect,[spectsavepath, 'pt4_spect.nii']);

%pt2: zoom = 55, from 8 - 41
%pt3: zoom = 55, from 29 - 68
%pt4: zoom 55, from 58 - 90, %changed to 50 - 93 bc spm was being really weird... lets spm reslice better perhaps? NOPE still off. 
%pt7: zoom = 55, from 35 - 66, updown =  -13



%% DSC cropping and resizing
load(dscpath,'images')
pt_perf = imrotate(images{15},270);
if ~ exist(dscsavepath, 'dir')
    mkdir(dscsavepath)
end
niftiwrite(pt_perf,[dscsavepath 'pt4_dsc.nii']);


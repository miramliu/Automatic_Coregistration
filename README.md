# Automatic_Coregistration
Automatic coregistration for DSC perfusion scans. \
Requires previous installation of SPM12_v1776, https://www.fil.ion.ucl.ac.uk/spm/software/ \
Mira Liu 4/7/2022. 


This code involves automatic co-registration for T1-bookend method DSC perfusion scans. \
This includes coregistration of standard DSC perfusion, 'ep2dperf', as well as coregistration of T1Post to T1Pre for proper quantification. \
It also assumes that the three types of MR scans have been previously sorted after download from the scanner (see DSCPerfusionSorter.ipynb) 

# for ep2dperf dicoms
Use calling function "DSCPerfusion_MotionCorrection"

### This function does the following:
First convert the dicom images into a 4d volume (series of 3D volumes over time) and write it as a nifti in the nifti folder.\
Then coregister those sequential 3D volumes to the FIRST 3D volume (using SPM)\
Then move the un-coregistered files to another folder, save those coregistered files as dicoms in the original folder numbered correctly with the proper headers from the original dicoms. 


Function decomposition used to coregister DSC Perfusion scans (ep2d_perf)\ 
Requirements: written on Matlab2021b, requires installation of SPM12_1776\
Function Description: 
## Input: 
    path to folder of SORTED DICOMS. 
        (these are 3 folders in a folder P00N, these 3 folders are LL-PRE, LL-POST, and ep2dperf)
        The scans within these folders must already be sorted. See DSCPerfusionSorter.ipynb
    path to niftis, this should be a folder devoted to the converted nifti files 
    pt name for identification, input as a string, i.e. 'pt1'
    total slices (number of slices in the 3D volumes)
    total times (number of time points, or 4th dimension of 4d volume)
    scantype (is it the 'LLPre', 'LLPost', or 'ep2dperf' to be registered?)
## Output: 
    coregistered sorted dicoms with the proper headers in the original folder noted along the 'dcmpath' ready for post-processing.


### Example run:
    Assuming saved folder of dicoms in /Debugging/pt2_DSC_sorted/P001/
    dcmpath = '/Debugging/pt2_DSC_sorted/P001/';
    niftipath = /Debugging/pt2_nii';
    ptname = 'pt2';
    totalslices = 25;
    totaltimes = 60;
    scantype = 'ep2dperf';
    >> DSCPerfusion_MotionCorrection(dcmpath,niftipath,ptname,totalslices,totaltimes,scantype);




# for LLPre and LLPost dicoms
Use calling function DSCPerfusion_Motion Correction() to convert the pre and post dicoms to nii files. \
Use the function T1_DSCcoregistration() to estimate the zoom and rotation degree of T1Post compared to T1Pre\
Use the function Save_handcoregistered() to save coregistered dicoms with proper headers



## DSCPerfusion_Motion Correction()
### Input: 
    path to folder of SORTED DICOMS (either LL-Pre or LL-Post). 
        (these are 3 folders in a folder P00N, these 3 folders are LL-PRE, LL-POST, and ep2dperf)
        The scans within these folders must already be sorted. See DSCPerfusionSorter.ipynb
    path to niftis, this should be a folder devoted to the converted nifti files 
    pt name for identification, input as a string, i.e. 'pt1'
    total slices (number of slices in the 3D volumes)
    total times (number of time points, or 4th dimension of 4d volume)
    scantype (is it the 'LLPre', 'LLPost', or 'ep2dperf' to be registered?)
### Output: 
    coregistered sorted dicoms with the proper headers in the original folder noted along the 'dcmpath' ready for post-processing.

#### Example run:
    Assuming saved folder of dicoms in /Debugging/pt2_DSC_sorted/P001/
    dcmpath = '/Debugging/pt2_DSC_sorted/P001/';
    niftipath = /Debugging/pt2_nii/';
    ptname = 'pt2';
    totalslices = 1;
    totaltimes = 256;
    scantype = 'LLPre';
    >> DSCPerfusion_MotionCorrection(dcmpath,niftipath,ptname,totalslices,totaltimes,scantype);

## T1_DSCcoregistration()
### Input: 
    path to T1Pre nii file
    path to T1Post nii file

### Output: 
    GUI to adjust the T1Post and see overlay compared to T1Pre to estimate zoom and rotation needed (see slider values)

### Exammple run: 
    pre_path = '/Debugging/pt2_nii/LLPre/pt2_LLPre4d.nii';
    post_path = '/Debuggin/pt2_nii/LLPost/pt2_LLPost4d.nii';
    >> T1_DSCcoregistration(pre_path,post_path)


## Save_handcoregistered()
### Input: 
    path to folders of SORTED DICOMS
    total number of images
    zoom amount (see slider Z: on T1_DSCcoregistration GUI)
    rotation amount (see slider rotation: on T1_DSCcoregistration GUI)

### output 
    coregistered sorted dicoms with the proper headers in the original folder noted along the 'dcmpath' ready for post-processing.

### Example run:
    dcmpath = '/Debugging/pt2_DSC_sorted/P001/';
    totalimages = 256;
    Z = 25;
    rotation = -15;
    >> save_handcoregistered(dcmpath,totalimages,Z,rotation)

%-----------------------------------------------------------------------
% Job saved on 05-Apr-2022 12:03:12 by cfg_util (rev $Rev: 7345 $)
% spm SPM - SPM12 (7771)
% cfg_basicio BasicIO - Unknown

%written to automatically align a 4d volume (for DSC) 
%input: path to the new nii file, and the number of time points
%output: saves separate files for each TIME POINT of the 3D volume that have been coregistered to the first time point (hopefully)

%miraliumarch2022
%-----------------------------------------------------------------------

function coregvol_job(varargin)

targetpath = varargin{1}; %'/Users/neuroimaging/Desktop/DATA/ASVD/Pt2/pt2_niftis/DSCPerf/pt2_dsc4d.nii'
totaltimes = varargin{2}; %how many time points
times = transpose(1:totaltimes); %so 1:60


for i =2:totaltimes %now go through every single time point and coregister it to the first time point. 
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.name = 'vol';
    num = num2str(times(i),'%.0f');
    matlabbatch{1}.cfg_basicio.file_dir.file_ops.cfg_named_file.files = {{targetpath}};
    matlabbatch{2}.spm.spatial.coreg.estwrite.ref = {[targetpath ',1']};
    matlabbatch{2}.spm.spatial.coreg.estwrite.source = {[targetpath ',' num]};
    matlabbatch{2}.spm.spatial.coreg.estwrite.other = {''};
    matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
    matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
    matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
    matlabbatch{2}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
    matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.interp = 4;
    matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.mask = 0;
    matlabbatch{2}.spm.spatial.coreg.estwrite.roptions.prefix = ['r' num];
    spm_jobman('run', matlabbatch);
end
end


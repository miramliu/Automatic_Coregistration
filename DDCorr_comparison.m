%% Comparison of Delay and Dispersion correction for ASVD vs. SPECT

%input patient number
%shows ddcorr and not ddcorr side by side with absolute difference on the right.

function DDCorr_comparison(varargin)
ptnum = varargin{1};

load(['/Users/neuroimaging/Desktop/DATA/ASCVD/Pt', ptnum, '/pt', ptnum '_DSC_sorted/Result_MSwcf2/P001GE_M.mat'],'images','image_names')
qCBF=images{strcmpi(image_names,'qCBF_nSVD')};
load(['/Users/neuroimaging/Desktop/DATA/ASCVD/Pt', ptnum, '/pt', ptnum, '_DDcorr/Result_MSwcf2/P001GE_M_DDCorr.mat'],'images', 'image_names')
qCBF_DDcorr=images{strcmpi(image_names,'qCBF_nSVD')};

View_Coregistration(qCBF,qCBF_DDcorr,'matmat difference')

end

%{
%also below is code for drawing vein: 
load stuff
dsc = cat(4,ROIs.dsc_stack{:});
AIFviewer(dsc);
imshow(images{strcmpi(image_names,'T1map_pre')}, [])
veinmask=roipoly;
veinmask = imresize(veinmask, [128 128]);
save ('/Users/neuroimaging/Desktop/Vein_Mask_P001GE_M.mat', 'veinmask')
%}
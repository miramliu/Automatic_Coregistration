% takes in dcm images, rotates and zooms them, and then rewrites them as dicoms again with correct header info... 
% done for LLpost that can't really be coregistered automatically using the other 'DSCPerusion" stuff. 
% register Post to Pre
% mira liu march 2022

function save_handcoregistered(varargin)
dcmpath = varargin{1}; %path to original folder 
totalimages = varargin{2}; %256
Z = varargin{3}; %25; %zoom of 25, rotation of -15 for pt2 (see SummaryOfResults20220405)
rotation = varargin{4};% -15;


olddcmpath = [dcmpath 'LLPost_notCoreg']; %create new folder
if ~ exist(olddcmpath, 'dir')
    tic
    mkdir (olddcmpath) %create new folder
    movefile([dcmpath 'IR_LL_EPI_POST/' '*.dcm'], olddcmpath) %move all original dicoms to old dscpath
end
fprintf('Created new folder, now rewriting...\n')


if numel(dir([dcmpath '/IR_LL_EPI_POST/'])) <=2 %if it's empty
    tic
    for i = 1:totalimages
        k = num2str(i);
        metadata = dicominfo([olddcmpath '/' k '.dcm']); %load data for the kth dcm image
        image  = dicomread([olddcmpath '/' k '.dcm']); 
        rmpixels = round(Z/2); %this follows the zoom writen in 'coregistration_setup app.
        newimage = image(rmpixels:end-rmpixels,rmpixels:end-rmpixels);
        newimage = uint16(imrotate(newimage,rotation));
        newimage = imresize(newimage,size(image));
        dicomwrite(newimage, [dcmpath 'IR_LL_EPI_POST/' k '.dcm'], metadata)
    end
end

toc
fprintf('done\n')

end
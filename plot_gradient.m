% SUMAMARY: script file to compute and plot the gradient of pixel intensity
% with respect to distance (across x-direction of image) over time

% WORKFLOW:
% 1) image correction so that the sum of pixel intensity is the same across
% each image (account for decreasing brightness due to photobleaching)
% 2) normalise pixel intensity of image relative to reference image (t=0)
% 3) compute average intensity of each column 
% 4) assume linear fit around the centre of the average intensity plot and
% determine the gradient (dc/dx)
% 5) determine gradient each image and plot change in gradient over time

% REQUIRED USER INPUT:
% - image folder name 
% - image crop size 
% - gradient computation area (only want middle section where average 
% intensity vs distance plot is approximately linear)

% Written by: Shin Wei Chong 
% Project: thermophoretic approach for gradient patterning of substrates
% version 1.0, 02-Jul-2022


% -------------------------------


% housekeeping 
close all 
clear 
clc

% load folder
% NOTE: this assumes folder is in the same directory as code file.
% Otherwise, need to ammend filepath description to map to the correct 
% directory containing the folder 
folder_name = 'analysis_29June'; % INPUT FOLDER NAME
% count number of images to analyse
a = dir([folder_name '/*jpg']); 
N = length(a); % total number of files (including ref)

% define image crop size
% syntax: [x-coord of bottom left point, y-coord of bottom left point,
% width, height]
crop_size = [1764 798 1176 1506]; % CHANGE CROP SIZE

% load reference image (t=0)
ref_name = a(1).name; % assume this is always the first image in the folder
ref = imread([folder_name '/' ref_name]); 
ref = imcrop(ref, crop_size); 
ref = double(im2gray(ref)); % convert to grayscale

sum_ref = sum(ref, "all"); % get sum of pixel intensities

t_ref = str2double(ref_name(9:10))*3600 +...
    str2double(ref_name(11:12))*60 +...
    str2double(ref_name(13:14)); % get time of ref image taken (in secs)

% for sense check
fac_array = zeros(1,N);
chck_array = zeros(1,N);

% load images to analyse
for i = 1:N

    % get image file name
    file = a(i).name;  
    img = imread([folder_name '/' file]);
    img = imcrop(img, crop_size);
    img = double(im2gray(img)); % convert to grayscale

    % determine image correction factor (assumes sum of intensity is
    % constant across images; in other words, total number of fluorescent
    % particles in frame remains constant throughout experiment, only
    % change is their position within the frame due to thermophoretic
    % movement)
    sum_img = sum(img,"all"); % get sum of pixel intensities 
    fac = sum_ref / sum_img; 
    fac_array(i) = fac;

    % image correction
    corr_img = img.*fac; 
    
    chck = sum(corr_img, "all")/ sum_ref; %check - this should be 1
    chck_array(i) = chck; 

    % normalise image 
    norm_img = corr_img./ ref;
    avg_norm_img = mean(norm_img); % get avg value of each column 

    
    % find gradient
    grad_area = 400:700; % INPUT DISTANCE BET 2 POINTS IN X-DIRECTION 
    y = avg_norm_img(grad_area);
    x = 1:length(y);
    p = polyfit(x,y,1); %linear fit
    grad = p(1); % gradient
    
    
    % find elapsed time of current image
    t_img = str2double(file(9:10))*3600 +...
        str2double(file(11:12))*60 +...
        str2double(file(13:14)); % get time of image taken (in seconds)
    % find experiment elapsed time 
    t = t_img - t_ref; 

    plot(t, grad, 'o')
    hold on 

end 

% plot features
axis tight
%legend 
xlabel("time"); ylabel("d(pixel intensity)/d(unit pixel)");

% show correction factor calculated for each image
fac_array
chck_array


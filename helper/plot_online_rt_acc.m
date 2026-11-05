function plot_online_rt_acc(trialStruct,sub_info,windowDim,windowPntr)

% plot_online_rt_acc(Flanker_task_infos, irb_information, screenDim, screenPointer) 
% calculates the RT and accuracy in the flanker task and displays it.

% Concocted by Sumitash, June 30, 2017 (MATLAB R2016b)

% -----------------------------------------------------------------------


% Calculate RT & accuracy
no_blks         = setdiff(unique(unique(trialStruct.BlockNo)),0);
mean_rt_blks    = arrayfun(@(a) mean(trialStruct.RT(trialStruct.BlockNo==a & trialStruct.TrialOutcome==1)),1:max(no_blks));
sd_rt_blks      = arrayfun(@(a) std(trialStruct.RT(trialStruct.BlockNo==a & trialStruct.TrialOutcome==1)),1:max(no_blks));
n_cor_trls      = arrayfun(@(a) sum(trialStruct.TrialOutcome(trialStruct.BlockNo==a)==1),1:max(no_blks)); 
n_tot_trls      = arrayfun(@(a) sum(trialStruct.BlockNo==a),1:max(no_blks)); 
acc_blks        = (n_cor_trls./n_tot_trls)*100;

% Reaction Time
ax(1) = subplot(2,1,1);
set(ax(1),'box','off','tickdir','out','LineWidth',1.25,'FontSize',12);
hold on
errorbar(1:length(mean_rt_blks),mean_rt_blks,sd_rt_blks,'k-','LineWidth',2,'LineStyle','none')
bar(1:length(mean_rt_blks),mean_rt_blks)
set(gca,'XTick',no_blks,'XTickLabel',num2str(no_blks))
alpha(0.3)
ylabel('Reaction time (s)')

% Accuracy
ax(2) = subplot(2,1,2);
set(ax(2),'box','off','tickdir','out','LineWidth',1.25,'FontSize',12)
hold on
bar(1:length(mean_rt_blks),acc_blks);
alpha(0.3)
set(gca,'XTick',no_blks,'XTickLabel',num2str(no_blks))
xlabel('Block number')
ylabel('Accuracy (%)')

axes('Position',[0 0 1 1],'Visible','off');
text(0.45,0.95,'Performance','FontSize',16,'FontWeight','demi','HorizontalAlignment','center','VerticalAlignment','baseline')
imageName = strcat('Flanker_performance_','Sub',num2str(sub_info.subject_id),'.jpg');

set(gcf,'PaperUnits','inches','PaperSize',[4 4],'PaperPosition',[1 1 6.65 5])
savePath  = [pwd,'/data/'];
mkdir([savePath,'/Sub',num2str(sub_info.subject_id)])
imagePath = fullfile([savePath,'/Sub',num2str(sub_info.subject_id)],imageName);
print(gcf,imagePath,'-djpeg')
delete(gcf)

% --- Display image ---

imageLoc = imread(imagePath);

[s1, s2, s3] = size(imageLoc);      % Get the size of the image

if s1 > windowDim(4) || s2 > windowDim(4)
    
    disp('Rescaling image');
    
    % Get the aspect ratio of the image. We need this to maintain the aspect
    % ratio of the image when we draw it different sizes. Otherwise, if we
    % don't match the aspect ratio the image will appear warped / stretched
    aspectRatio = s2 / s1;

    % We will set the height of each drawn image to a fraction of the screens
    % height
    heightScalers = linspace(1, 0.2, 10);
    imageHeights = windowDim(4) .* heightScalers;
    imageWidths = imageHeights .* aspectRatio;

    % Number of images we will draw
    numImages = numel(heightScalers);

    % Make the destination rectangles for our image. We will draw the image
    % multiple times over getting smaller on each iteration. So we need the big
    % dstRects first followed by the progressively smaller ones
    dstRects = zeros(4, numImages);
    for i = 1:numImages
        theRect = [0 0 imageWidths(i) imageHeights(i)];
        dstRects(:, i) = CenterRectOnPointd(theRect, windowDim(3) / 2,...
            windowDim(4) / 2);
    end

end

% Make the image into a texture
imageTexture = Screen('MakeTexture', windowPntr, imageLoc);

% Draw the image to the screen, unless otherwise specified PTB will draw
% the texture full size in the center of the screen. We first draw the
% image in its correct orientation.
Screen('DrawTextures', windowPntr, imageTexture, [], [], 0);

end
function displayRDMVideo(RD_map_raw, vVel_raw, vRange_raw, ...
                         RD_map_proc, vVel_proc, vRange_proc, ...
                         RD_map_mti, vVel_mti, vRange_mti, ...
                         outputFolder)
% displayRDMVideo - Animate and display three Range-Doppler maps in a full-screen figure,
% and optionally save a 3×-speed video to disk if 'outputFolder' is provided.

if nargin < 10
    outputFolder = ''; % no folder specified, won't save
end

% Determine the number of frames (assumed equal for all RDM inputs)
numFrames = size(RD_map_raw, 3);

%% 1) Create a figure and set reduced resolution
hFig = figure('Name','Range-Doppler Video','NumberTitle','off', ...
              'Units','pixels','Position',[100, 100, 900, 300]);  % Smaller size for 3 subplots

set(hFig, 'Resize','off');  % Disable resizing

%% 2) Subplot 1: Raw Range-Doppler Map
subplot(1,3,1);
h1 = imagesc(vVel_raw, vRange_raw, 20*log10(abs(RD_map_raw(:,:,1))));
xlim([min(vVel_mti)/1.5, max(vVel_mti)/1.5]); axis manual;
xlabel('Velocity (m/s)'); ylabel('Range (m)');
title('1) Raw RDM');
colorbar; caxis([-10 60]); colormap jet;

%% 3) Subplot 2: Processed Range-Doppler Map
subplot(1,3,2);
h2 = imagesc(vVel_proc, vRange_proc, 20*log10(abs(RD_map_proc(:,:,1))));
xlim([min(vVel_mti)/1.5, max(vVel_mti)/1.5]); axis manual;
xlabel('Velocity (m/s)'); ylabel('Range (m)');
title('2) Processed RDM');
colorbar; caxis([-10 60]); colormap jet;

%% 4) Subplot 3: Processed+MTI Range-Doppler Map
subplot(1,3,3);
h3 = imagesc(vVel_mti, vRange_mti, 20*log10(abs(RD_map_mti(:,:,1))));
xlim([min(vVel_mti)/1.5, max(vVel_mti)/1.5]); axis manual;
xlabel('Velocity (m/s)'); ylabel('Range (m)');
title('3) Processed+MTI RDM');
colorbar; caxis([-10 60]); colormap jet;

sgtitle('Range-Doppler Video');

%% 5) Prepare the video writer (4× speed + smaller size)
videoFrameRate = 40;  % 4× speed
videoFilename  = fullfile(outputFolder, 'RangeDoppler_Speed.mp4');

if ~isempty(outputFolder)
    vidObj = VideoWriter(videoFilename, 'MPEG-4');  % H.264 compressed
    vidObj.FrameRate = videoFrameRate;
    open(vidObj);
end

%% 6) Animate all frames
for t = 1:numFrames
    set(h1, 'CData', 20*log10(abs(RD_map_raw(:,:,t))));
    set(h2, 'CData', 20*log10(abs(RD_map_proc(:,:,t))));
    set(h3, 'CData', 20*log10(abs(RD_map_mti(:,:,t))));
    
    sgtitle(sprintf('Range-Doppler Frame: %d / %d', t, numFrames));
    drawnow;
    
    % Capture & write frame if saving video
    if ~isempty(outputFolder)
        frame = getframe(hFig);
        writeVideo(vidObj, frame);
    end
end

% Close video if opened
if ~isempty(outputFolder)
    close(vidObj);
    fprintf('Range-Doppler video saved to: %s\n', videoFilename);
end

end

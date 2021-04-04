%%%%  AIS length, location and localisation measurements from 2d images

function [] = ais_z3(cell)      %%% for cell-by-cell analysis
%function [batch_output] = ais_z3(cell,chosen) %%% for batch analysis of many cells (axon locations pre-drawn).  For this, 'byeye' must be zero

disp(cell)
close all

%%%%  Setting options

nCh = 2;    %%% sets number of colour channels
labels = {'ankG' 'Kv1.1'}; %%%% labels for all channels
colours = ['r' 'g'];

byeye = 0;  %%% Choose '1' for by-eye measures, '0' for not (e.g. when running with 'chosen')
    if byeye > 0
        eye = [1];    %%% picks channel for estimating AIS start+end by eye: array contains '1' for Channel1,'2' for Channel2, '3' for Channel3
        if nCh < max(eye)
            disp(' ')
            disp('nCh and eye options are incompatible')
            stop
        end
    end

draw = 1;   %%% picks channel for drawing profile along axon: '1' for Channel1,'2' for Channel2, '3' for Channel3
prof = [1 2];   %%% picks channel for profiling fluo intensity: array contains '1' for Channel1,'2' for Channel2, or '3' for Channel3
    if nCh < draw | nCh < max(prof)
        disp(' ')
        disp('nCh and draw/prof options are incompatible')
        stop
    end

pixconv = 0.138; %%% for zeiss confocal x40 objective, zoom x3  %%%% assumes square pixels - enter pixel width in um
f = 0.33; %%%% is fraction of max fluo intensity at which AIS start+end parameters taken (0.33 as default; Grubb & Burrone 2010)


%%%% finding appropriate folder to load axon co-ordinates, if using 'chosen' 

% q = length(cell);
% while strcmp(cell(q),'\')==0
%     q = q-1;
% end
% folder = cell(q-1);


%%%% opening zprojections from RGB merged tif exported from Zen 

file = [cell '_Maximumintensityprojection.tif'];
pic = imread([file]);

for n = 1:nCh
    Ch{n} = pic(:,:,n);  %%% careful if saved as GR, because green is 2nd in RGB, but track1 on confocal
    figure(n)
    imagesc(Ch{n})
    colormap(gray)
    axis square
    title(labels(n),'color',colours(n))
    hold on
end

%%%%%% plot AIS start and end by eye

if byeye>0
    disp(' ')
    disp('Plotting AIS start and end by eye')
    disp('   Press any key when correctly zoomed and ready to plot')
    disp('   Left mouse button picks AIS start')
    disp('   Right mouse button picks AIS end')
    
    for n = 1:length(eye)
        figure(eye(n))
        zoom;pause;zoom;    %%%% puts zoom on and off with key control
        but = 1;
        i = 1;
        while but == 1
            [w(i),z(i),but] = ginput(1);
            plot(w(i),z(i),'b*')
            i = i+1;
        end
        eyestartx(eye(n)) = w(1);eyestarty(eye(n)) = z(1);eyeendx(eye(n)) = w(2);eyeendy(eye(n)) = z(2);
        hold off
    end
end
    
%%%% obtaining co-ordinates of line along axon

if nargin >1	%%%% i.e. 'chosen' or not
    savexy = [cell '_xy_pix.txt'];	%%%% is text file with cell's axon co-ordinates, should have been created with previous (non-'chosen') use of this programme
    fid = fopen(savexy,'r');
    npoints = fscanf(fid,'%f',1);
    for n = 1:npoints
       x_pix(n) = fscanf(fid,'%f',1);
       y_pix(n) = fscanf(fid,'%f',1);
       saxon_um(n) = fscanf(fid,'%f',1);
    end
    fclose(fid);
    savespline = [cell '_xy_spline.txt'];   %%% txt file with axon spline co-ordinates
    fid = fopen(savespline,'r');
    npoints = fscanf(fid,'%f',1);
    for n = 1:npoints
        xysm(1,n) = fscanf(fid,'%f',1);
        xysm(2,n) = fscanf(fid,'%f',1);
        ax_um(n) = fscanf(fid,'%f',1);
    end
    fclose(fid);
else
    disp(' ')
    disp('Drawing axonal profile')
    disp('   Press any key when correctly zoomed and ready to plot')
    disp('   Left mouse button picks points.')
    disp('   Right mouse button picks last point.')
figure(draw)
hold on
zoom;pause;zoom; 
xy = [];
n = 0;  %%%% Loop, picking up the points.
but = 1;
while but == 1
    [xi,yi,but] = ginput(1);	%%%% getting co-ordinates from each mouse click
    plot(xi,yi,'ro')	%%%% plots red circle at each mouse click
    n = n+1;
    xy(:,n) = [xi;yi];
end
%%%% interpolate points with a spline curve and finer spacing.
t = 1:n;
ts = 1: 0.01: n;    %%%% fine sampling, with double deletion below, ensures pixel-by-pixel line section
xysm = spline(t,xy,ts);
for u = 2:(length(xysm))
    ax(u) = sqrt ( (xysm(1,u) - xysm(1,u-1))^2 + (xysm(2,u)-xysm(2,u-1))^2 );
end
ax = cumsum(ax);    %%%% so distance (in pixels) along spline from start of axon
ax_um = ax .* pixconv;   %%% distance along spline in um
xys = round(xysm); %%% rounding spline to whole-number pixel co-ordinates only
plot(xys(1,:),xys(2,:),'-b')
plot(xysm(1,:),xysm(2,:),'-y')

double_id = [];
for i = 1:length(xys(1,:))
    for j = (i+1):length(xys(1,:))
        if xys(1,i) == xys(1,j)
            if xys(2,i) == xys(2,j)
                double_id = [double_id; j]; %%%% so finding double co-ordinates
            end
        end
    end
end
double_id = unique(double_id);
alln = 1:length(xys(1,:));
m = setdiff(alln,double_id);    %%% so m is index of all unique xy points in line section
xs = xys(1,:); ys = xys(2,:);
x_pix = xs(m);	%%%% so x_pix is unique array of axon x co-ordinates
y_pix = ys(m);	%%%% y_pix is unique array of axon y co-ordinates

for g = 1:length(x_pix) %%%% for each pixel, finding nearest location on spline axon
    d{g} = [];
    for h = 1:length(xysm)
        d{g} = [d{g}; sqrt((x_pix(g)-xysm(1,h))^2+(y_pix(g)-xysm(2,h))^2)];
    end
    [mind(g),mindi(g)] = min(d{g});
    x_ax(g) = xysm(1,mindi(g));
    y_ax(g) = xysm(2,mindi(g));
end
saxon_um = ax_um(mindi);    %%% so is array of distances of each pixel along axon - more accurate version of axon_um

%%%% saving drawn co-ordinates to text file for easier later re-analysis with 'chosen'
savexy = [cell '_xy_pix.txt'];
fid = fopen(savexy,'wt');
fprintf(fid,'%f\n',length(x_pix)); %%%% start of txt file gives number of points in arrays
for n = 1:length(x_pix)
    fprintf(fid,'%f\t %f\t %f\n',x_pix(n),y_pix(n),saxon_um(n));	%%%% writing x & y co-ordinates
end
fclose(fid);
savespline = [cell '_xy_spline.txt'];
fid = fopen(savespline,'wt');
fprintf(fid,'%f\n',length(xysm(1,:)));
for n = 1:length(xysm(1,:))
    fprintf(fid,'%f\t %f\t %f\n',xysm(1,n),xysm(2,n),ax_um(n));
end
fclose(fid);
end

%%%% by-eye values for AIS start, end, and length

if byeye>0
    for n = eye
        for j = 1:length(xysm(1,:))
            deye(n,j) = sqrt((xysm(1,j)-eyestartx(n))^2 + (xysm(2,j)-eyestarty(n))^2);  %%% so finding distance between eye startpoint and each point on traced axon spline
        end
        [mn(n) eyestarti(n)] = min(deye(n,:));  %%% eye start where manually chosen startpoint is closest to axon trace
        for j = 1:length(xysm(1,:))
    		deye(n,j) = sqrt((xysm(1,j)-eyeendx(n))^2 + (xysm(2,j)-eyeendy(n))^2);
        end
        [mn(n) eyeendi(n)] = min(deye(n,:));    %%% same for eye end point
    end
    eye_start(n) = ax_um(eyestarti(n));%%%% converting pixels to um
    eye_end(n) = ax_um(eyeendi(n));
    eye_length(n) = eye_end(n)-eye_start(n);
    eye_mid(n) = eye_start(n) + 0.5*(eye_length(n));
end   
 
%%%% obtaining fluorescence intensities for axonal profile

for n = prof
    
    figure(nCh+1)
    subplot(2,3,n)
    imagesc(Ch{n})
    colormap(gray)
    axis square
    title(labels(n),'color',colours(n))
    hold on
    plot(x_pix,y_pix,'-m')
    plot(xysm(1,:),xysm(2,:),'-y')
    hold off
    
    for i = 1:length(x_pix) %%%% so working along the axon pixels  
        lv_c(n,i) = Ch{n}(y_pix(i),x_pix(i));  %%% lv_c is fluorescence intensity at current point of axonal profile. Picture co-ordinates actually rows, then columns. 
        lv_1(n,i) = Ch{n}(y_pix(i)+1,x_pix(i));    %%%% this and next 7 rows get values for 3x3 roi centred on lv_c(i)
        lv_2(n,i) = Ch{n}(y_pix(i)-1,x_pix(i));
        lv_3(n,i) = Ch{n}(y_pix(i),x_pix(i)+1);
        lv_4(n,i) = Ch{n}(y_pix(i),x_pix(i)-1);
        lv_5(n,i) = Ch{n}(y_pix(i)+1,x_pix(i)+1);
        lv_6(n,i) = Ch{n}(y_pix(i)-1,x_pix(i)-1);
        lv_7(n,i) = Ch{n}(y_pix(i)+1,x_pix(i)-1);
        lv_8(n,i) = Ch{n}(y_pix(i)-1,x_pix(i)+1);
        lv_smooth(n,i) = mean([lv_c(n,i) lv_1(n,i) lv_2(n,i) lv_3(n,i) lv_4(n,i) lv_5(n,i) lv_6(n,i) lv_7(n,i) lv_8(n,i)]); %%% lv_smooth is mean fluorescence intensity over 3x3 roi
    end

    v = num2str(lv_c); lv_c = str2num(v);   %%% re-formatting lv_c to avoid bugs

    %%% sliding mean to smooth intensity profile 
    for i = 1:length(x_pix)
        d = 20; %%%sets no of pixels each side, i.e. for d = 20, width of sliding window is 41
        if i<(d+1)  %%% at very start of axon profile , not allowing full window
            lv_slide(n,i) = mean([lv_c(n,1:i) lv_c(n,i:i+d)]);    %%% sliding mean with raw lv_c values
            lv_ss(n,i) = mean([lv_smooth(n,1:i) lv_smooth(n,i:i+d)]); %% sliding mean with lv_smooth values
        elseif i>(length(x_pix)-(d+1))  %%% at very end of axon profile, not allowing full window
            lv_slide(n,i) = mean([lv_c(n,i-d:i) lv_c(n,i:length(x_pix))]);
            lv_ss(n,i) = mean([lv_smooth(n,i-d:i) lv_smooth(n,i:length(x_pix))]);
        else   %%% in middle of axon profile, allowing full window
            lv_slide(n,i) = mean([lv_c(n,i-d:i) lv_c(n,i:i+d)]);
            lv_ss(n,i) = mean([lv_smooth(n,i-d:i) lv_smooth(n,i:i+d)]);
        end
    end

    norm_lvslide{n} = (lv_slide(n,:) - min(lv_slide(n,:))) ./ (max(lv_slide(n,:))-min(lv_slide(n,:))); %%% is normalised, smoothed profile for 1x1 pixel sampling
    norm_lv{n} = (lv_ss(n,:) - min(lv_ss(n,:))) ./ (max(lv_ss(n,:))-min(lv_ss(n,:)));  %%%% is normalised, smoothed profile for 3x3 pixel sampling
    
    lvs_array{n} = lv_smooth(n,:);
    base(n) = mean(lvs_array{n}(length(lvs_array{n})-19:length(lvs_array{n})));
    lvs_sub{n} = lvs_array{n}-base(n);
    
    %%%% plotting profiles
    figure(nCh+1)
    subplot(2,3,4)
    plot(saxon_um,lv_c(n,:),'-','color',colours(n)) %%%% plotting 1x1 raw fluorescence intensity values
    axis square
    title('F Raw 1x1')
    hold on
    
    subplot(2,3,5)
    plot(saxon_um,lvs_sub{n},'-','color',colours(n)) %%%% plotting 3x3 average raw fluorescence with baseline subtracted
    axis square
    title('F Raw 3x3 Sub')
    hold on
    plot([0 saxon_um(length(saxon_um))],[0 0],'k:')
    
    subplot(2,3,6)
    plot(saxon_um,norm_lv{n},'-','color',colours(n)) %%%% plotting normalised, smoothed fluo 
    title('F SmoothNorm')
    axis square
    hold on
    
    maxi_i{n} = (find(norm_lv{n}==1)); max_i(n) = maxi_i{n}(1);  %%% all measures use normalised, smoothed 3x3 pixel sampling profiles
    maxi(n) = saxon_um(max_i(n));  %%%% AIS max position in um
    plot([maxi(n) maxi(n)],[0 1],':','color',colours(n))
    aisend{n} = find( (saxon_um > maxi(n)) & (norm_lv{n}<f) );
    if length(aisend{n})>0
        ais_end(n) = aisend{n}(1);
    else
        ais_end(n) = length(saxon_um);  %%%% point index along axon past max where fluorescence intensity falls to f of its peak
    end
    aisstart{n} = find( (saxon_um < maxi(n)) & (norm_lv{n}<f)); 
    if length(aisstart{n})>0
        ais_start(n) = aisstart{n}(length(aisstart{n}));
    else
        ais_start(n) = 1;%%%% point index along axon pre max where fluorescence intensity falls to f of its peak
    end

    debut(n) = saxon_um(ais_start(n));  %%%% AIS start position in um
    fin(n) = saxon_um(ais_end(n));  %%%% AIS end position in um
    lngth(n) = fin(n)-debut(n);      %%%% AIS length in um
    mid(n) = mean([debut(n) fin(n)]); %%%% AIS mid position in um
    
    plot([fin(n) fin(n)],[0 1],'-','color',colours(n))
    plot([debut(n) debut(n)],[0 1],'-','color',colours(n))
        
end

%%%% intensity measures

aisch = 2;  %%%% sets channel for determining AIS start and end
subplot(2,3,5)
plot([debut(aisch) debut(aisch)],[0 max(lvs_sub{aisch})],':','color',colours(aisch))
plot([fin(aisch) fin(aisch)],[0 max(lvs_sub{aisch})],':','color',colours(aisch))
aisi = find((saxon_um>debut(aisch)) & (saxon_um<fin(aisch)));
aisaxarray = saxon_um(aisi);
   
for n = prof
   
   [maxF(n), maxFi(n)] = max(lvs_sub{n});   %%%% maximum fluorescence for 3x3 subtracted raw profile
   plot(saxon_um(maxFi(n)),maxF(n),'o','color',colours(n),'markerfacecolor',colours(n))
   
   aisarray{n} = lvs_sub{n}(aisi);
   %%intF1(n) = sum(aisarray{n}.*pixconv)    %%%% integrated 3x3 subtracted F within AIS, 1st rough estimate
   intF(n) = 0;
   for i = 1:(length(aisarray{n})-1)
       intF(n) = intF(n) + ((aisaxarray(i+1)-aisaxarray(i)).*aisarray{n}(i) + 0.5.*(aisaxarray(i+1)-aisaxarray(i)).*(aisarray{n}(i+1)-aisarray{n}(i)));   %%% integrated 3x3 subtracted F, proper calculation
   end
   intF(n) = intF(n)./1000;     %%% scaling for easier output
end

%%%% results output

batch_output = [];

for n = 1:nCh

    disp(' ')
    disp(['Ch' num2str(n) ' Start'])
    disp(['Ch' num2str(n) ' End'])
    disp(['Ch' num2str(n) ' Length'])
    disp(['Ch' num2str(n) ' Mid'])
    disp(['Ch' num2str(n) ' Max'])
    disp(['Ch' num2str(n) ' MaxF'])
    disp(['Ch' num2str(n) ' IntF'])
    disp(['Ch' num2str(n) ' Eye Start'])
    disp(['Ch' num2str(n) ' Eye End'])
    disp(['Ch' num2str(n) ' Eye Length'])
    disp(['Ch' num2str(n) ' Eye Mid'])
    
    disp(' ')
    
    j = find(prof==n);
    if j>0
        output(n,1) = debut(n); output(n,2) = fin(n); output(n,3) = lngth(n); output(n,4) = mid(n); output(n,5) = maxi(n); output(n,6) = maxF(n); output(n,7) = intF(n);
    else
        output(n,1) = NaN; output(n,2) = NaN; output(n,3) = NaN; output(n,4) = NaN; output(n,5) = NaN; output(n,6) = NaN;output(n,7) = NaN;
    end
    
    if byeye>0
        k = find(eye==n);
        if k>0
            output(n,8) = eye_start(n); output(n,9) = eye_end(n); output(n,10) = eye_length(n); output(n,11) = eye_mid(n);
        else
            output(n,8) = NaN; output(n,9) = NaN; output(n,10) = NaN; output(n,11) = NaN;
        end
    else
        output(n,8) = NaN; output(n,9) = NaN; output(n,10) = NaN; output(n,11) = NaN;
    end

    disp(output(n,:)')
    
    batch_output = [batch_output; output(n,:)']; %%%%% for analysing batches of cells (see initial function command)
    
end
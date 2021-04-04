%%%%  AIS length, location and localisation measurements from 2d images

function [] = ais(cell)

disp(cell)
close all

%%%%  Setting options

nCh = 2;    %%% sets number of colour channels (max = 2)

byeye = 1;  %%% Choose '1' for by-eye measures, '0' for not (e.g. when running with 'chosen')
    if byeye > 0
        eye = 1;    %%% picks channel for estimating AIS start+end by eye: '1' for Channel1,'2' for Channel2, '3' for both
        if nCh==1 & eye>1
            disp(' ')
            disp('nCh and eye options are incompatible')
            stop
        end
    end

draw = 1;   %%% picks channel for drawing profile along axon: '1' for Channel1,'2' for Channel2
prof = 3;   %%% picks channel for profiling fluo intensity: '1' for Channel1,'2' for Channel2, or '3' for both
    if nCh == 1 & sum([draw prof])>2
        disp(' ')
        disp('nCh and draw/prof options are incompatible')
        stop
    end

AISindices = 1;	%%%% Set as '1' to obtain indices of AIS localisation in one channel (e.g. YFP-NavII-III) using AIS marker in other channel (e.g. ankyrinG)
    if AISindices>0 
        if nCh==1 | prof<3
            disp(' ')
            disp('Must have 2 profiled channels for AIS localisation measures')
            stop
        end
        AISindexCh = 2; %%%% picks channel for measuring AIS localisation: '1' for Channel1,'2' for Channel2
    end
    
pixconv = 0.129; %%%% assumes square pixels - enter pixel width in um
f = 0.33; %%%% is fraction of max fluo intensity at which AIS start+end parameters taken (0.33 as default; Grubb & Burrone 2010)


%%%% finding appropriate folder to load axon co-ordinates, if using 'chosen' 

% q = length(cell);
% while strcmp(cell(q),'\')==0
%     q = q-1;
% end
% folder = cell(q-1);


%%%% opening Ch1 zprojection

Ch1_file = [cell '_Ch1.tif'];
Ch1_pic = imread([Ch1_file]);
figure(1)
imagesc(Ch1_pic)
colormap(gray)
axis square
title('Ch1')
hold on

%%%% opening Ch2 zprojection

if nCh > 1
    Ch2_file = [cell '_Ch2.tif'];
    Ch2_pic = imread([Ch2_file]);
    figure(2)
    imagesc(Ch2_pic)
    colormap(gray)
    axis square
    title('Ch2')
    hold on
end

%%%%%% plot AIS start and end by eye

if byeye>0
    disp(' ')
    disp('Plotting AIS start and end by eye')
    disp('   Press any key when correctly zoomed and ready to plot')
    disp('   Left mouse button picks AIS start')
    disp('   Right mouse button picks AIS end')
if eye==2
    figure(2)
else
    figure(1)
end
zoom;pause;zoom;    %%%% puts zoom on and off with key control
but = 1;
i = 1;
while but == 1
    [w(i),z(i),but] = ginput(1);
    plot(w(i),z(i),'b*')
    i = i+1;
end
eyestartx = w(1);eyestarty = z(1);eyeendx = w(2);eyeendy = z(2);
hold off
if eye==3
    figure(2)
    zoom;pause;zoom;
    but = 1;
    i = 1;
    while but == 1
        [w(i),z(i),but] = ginput(1);
        plot(w(i),z(i),'b*')
        i = i+1;
    end
    eyestartx3 = w(1);eyestarty3 = z(1);eyeendx3 = w(2);eyeendy3 = z(2);
    hold off
end
end



%%%% obtaining co-ordinates of line along axon

if nargin >1	%%%% i.e. 'chosen' or not
    savexy = [cell '_xy.txt'];	%%%% is text file with cell's axon co-ordinates, should have been created with previous (non-'chosen') use of this programme
    fid = fopen(savexy,'r');
    npoints = fscanf(fid,'%f',1);
    for n = 1:npoints
       x_pix(n) = fscanf(fid,'%f',1);
       y_pix(n) = fscanf(fid,'%f',1);
    end
    fclose(fid);
else
    disp(' ')
    disp('Drawing axonal profile')
    disp('   Press any key when correctly zoomed and ready to plot')
    disp('   Left mouse button picks points.')
    disp('   Right mouse button picks last point.')
if draw==1
    figure(1)
elseif draw==2
    figure(2)
end
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
xys = round(spline(t,xy,ts)); %%% rounding spline to whole-number pixel co-ordinates only
plot(xys(1,:),xys(2,:),'-b')

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


%%%% saving drawn co-ordinates to text file for easier later re-analysis with 'chosen'
savexy = [cell '_xy.txt'];
fid = fopen(savexy,'wt');
fprintf(fid,'%f\n',length(x_pix)); %%%% start of txt file gives number of points in arrays
for n = 1:length(x_pix)
    fprintf(fid,'%f\t %f\n',x_pix(n),y_pix(n));	%%%% writing x & y co-ordinates
end
fclose(fid);
end


%%%% by-eye values for AIS start, end, and length

if byeye>0
	for j = 1:length(x_pix)
    		d(j) = sqrt((x_pix(j)-eyestartx)^2 + (y_pix(j)-eyestarty)^2);  %%% so finding distance between eye startpoint and each point on traced axon
	end
	[mn eyestartpix] = min(d);  %%% eye start where manually chosen startpoint is closest to axon trace
	for j = 1:length(x_pix)
    		d(j) = sqrt((x_pix(j)-eyeendx)^2 + (y_pix(j)-eyeendy)^2);
	end
	[mn eyeendpix] = min(d);    %%% same for eye end point
    
    if eye==1
        eye_start = pixconv*eyestartpix;  %%%% converting pixels to um
        eye_end = pixconv*eyeendpix;
        eye_length = pixconv*(eyeendpix-eyestartpix);;
        eye_mid = (mean([eye_start eye_end]));
        eye_start2 = NaN; eye_end2 = NaN; eye_length2 = NaN; eye_mid2 = NaN;
    elseif eye==2
        eye_start2 = pixconv*eyestartpix ;
        eye_end2 = pixconv*eyeendpix;
        eye_length2 = pixconv*(eyeendpix-eyestartpix);
        eye_mid2 = (mean([eye_start2 eye_end2]));
        eye_start = NaN; eye_end = NaN; eye_length = NaN; eye_mid = NaN;
    elseif eye==3
        eye_start = pixconv*eyestartpix;
        eye_end = pixconv*eyeendpix;
        eye_length = pixconv*(eyeendpix-eyestartpix);
        eye_mid = (mean([eye_start eye_end]));
        for j = 1:length(x_pix)
    		d(j) = sqrt((x_pix(j)-eyestartx3)^2 + (y_pix(j)-eyestarty3)^2); 
        end
        [mn eyestartpix3] = min(d);  
        for j = 1:length(x_pix)
    		d(j) = sqrt((x_pix(j)-eyeendx3)^2 + (y_pix(j)-eyeendy3)^2);
        end
        [mn eyeendpix3] = min(d);    
        eye_start2 = pixconv*eyestartpix3;
        eye_end2 = pixconv*eyeendpix3;
        eye_length2 = pixconv*(eyeendpix3-eyestartpix3);
        eye_mid2 = (mean([eye_start2 eye_end2]));
    end
else
    eye_start = NaN; eye_end = NaN; eye_length = NaN; eye_mid = NaN;
    eye_start2 = NaN; eye_end2 = NaN; eye_length2 = NaN; eye_mid2 = NaN;
end

%%%% obtaining fluorescence intensities for axonal profile - Ch1

for i = 1:length(x_pix) %%%% so working along the axon    
    lv_c(i) = Ch1_pic(y_pix(i),x_pix(i));  %%% lv_c is fluorescence intensity at current point of axonal profile. Picture co-ordinates actually rows, then columns. 
    lv_1(i) = Ch1_pic(y_pix(i)+1,x_pix(i));    %%%% this and next 7 rows get values for 3x3 roi centred on lv_c(i)
    lv_2(i) = Ch1_pic(y_pix(i)-1,x_pix(i));
    lv_3(i) = Ch1_pic(y_pix(i),x_pix(i)+1);
    lv_4(i) = Ch1_pic(y_pix(i),x_pix(i)-1);
    lv_5(i) = Ch1_pic(y_pix(i)+1,x_pix(i)+1);
    lv_6(i) = Ch1_pic(y_pix(i)-1,x_pix(i)-1);
    lv_7(i) = Ch1_pic(y_pix(i)+1,x_pix(i)-1);
    lv_8(i) = Ch1_pic(y_pix(i)-1,x_pix(i)+1);
    lv_smooth(i) = mean([lv_c(i) lv_1(i) lv_2(i) lv_3(i) lv_4(i) lv_5(i) lv_6(i) lv_7(i) lv_8(i)]); %%% lv_smooth is mean fluorescence intensity over 3x3 roi
end

v = num2str(lv_c); lv_c = str2num(v);   %%% re-formatting lv_c to avoid bugs

    %%% sliding mean to smooth intensity profile 
for i = 1:length(x_pix)
    d = 20; %%%sets no of pixels each side, i.e. for d = 20, width of sliding window is 41
    if i<(d+1)  %%% at very start of axon profile , not allowing full window
        lv_slide(i) = mean([lv_c(1:i) lv_c(i:i+d)]);    %%% sliding mean with raw lv_c values
        lv_ss(i) = mean([lv_smooth(1:i) lv_smooth(i:i+d)]); %% sliding mean with lv_smooth values
    elseif i>(length(x_pix)-(d+1))  %%% at very end of axon profile, not allowing full window
        lv_slide(i) = mean([lv_c(i-d:i) lv_c(i:length(x_pix))]);
        lv_ss(i) = mean([lv_smooth(i-d:i) lv_smooth(i:length(x_pix))]);
    else   %%% in middle of axon profile, allowing full window
        lv_slide(i) = mean([lv_c(i-d:i) lv_c(i:i+d)]);
        lv_ss(i) = mean([lv_smooth(i-d:i) lv_smooth(i:i+d)]);
    end
    
end

axon_um = [1:length(x_pix)]*pixconv;    %%%% full length of axonal profile
xstep = axon_um(2)-axon_um(1);  %%%% sampling frequency along axonal profile, in um (should be equal to pixconv)

norm_lvslide = (lv_slide - min(lv_slide)) ./ (max(lv_slide)-min(lv_slide)); %%% is normalised, smoothed profile for 1x1 pixel sampling
norm_lv = (lv_ss - min(lv_ss)) ./ (max(lv_ss)-min(lv_ss));  %%%% is normalised, smoothed profile for 3x3 pixel sampling

figure(3)
subplot(2,2,1)
imagesc(Ch1_pic)
colormap(gray)
axis square
title('Ch1','color','g')
hold on
plot(x_pix,y_pix,'-b')
hold off

%%%% using axonal profile to obtain fluorescence intensity info for Ch2

if nCh>1 & prof>1

figure(3)
subplot(2,2,2)
imagesc(Ch2_pic)
colormap(gray)
axis square
title('Ch2','color','r')
hold on
plot(x_pix,y_pix,'-b')
hold off

for i = 1:length(x_pix)     %%%% so repeating exactly same process as for Ch1 above
    lv_cb(i) = Ch2_pic(y_pix(i),x_pix(i));  
    lv_1b(i) = Ch2_pic(y_pix(i)+1,x_pix(i));    
    lv_2b(i) = Ch2_pic(y_pix(i)-1,x_pix(i));
    lv_3b(i) = Ch2_pic(y_pix(i),x_pix(i)+1);
    lv_4b(i) = Ch2_pic(y_pix(i),x_pix(i)-1);
    lv_5b(i) = Ch2_pic(y_pix(i)+1,x_pix(i)+1);
    lv_6b(i) = Ch2_pic(y_pix(i)-1,x_pix(i)-1);
    lv_7b(i) = Ch2_pic(y_pix(i)+1,x_pix(i)-1);
    lv_8b(i) = Ch2_pic(y_pix(i)-1,x_pix(i)+1);
    lv_smoothb(i) = mean([lv_cb(i) lv_1b(i) lv_2b(i) lv_3b(i) lv_4b(i) lv_5b(i) lv_6b(i) lv_7b(i) lv_8b(i)]);        
end

for i = 1:length(x_pix)
    d = 20; 
    if i<(d+1)
        lv_slideb(i) = mean([lv_cb(1:i) lv_cb(i:i+d)]);   
        lv_ssb(i) = mean([lv_smoothb(1:i) lv_smoothb(i:i+d)]); 
    elseif i>(length(x_pix)-(d+1))
        lv_slideb(i) = mean([lv_cb(i-d:i) lv_cb(i:length(x_pix))]);
        lv_ssb(i) = mean([lv_smoothb(i-d:i) lv_smoothb(i:length(x_pix))]);
    else
        lv_slideb(i) = mean([lv_cb(i-d:i) lv_cb(i:i+d)]);
        lv_ssb(i) = mean([lv_smoothb(i-d:i) lv_smoothb(i:i+d)]);
    end
    
end

norm_lvslideb = (lv_slideb - min(lv_slideb)) ./ (max(lv_slideb)-min(lv_slideb));
norm_lvb = (lv_ssb - min(lv_ssb)) ./ (max(lv_ssb)-min(lv_ssb));

vb = num2str(lv_cb); lv_cb = str2num(vb);   %%%%% re-formatting lv_cb to avoid bugs

end

pix_narray = [1:length(x_pix)]; %%%% useful index array up to end of axonal profile


%%%%% measures of AIS location & length - Ch1

max_i = (find(norm_lv==1)); max_i = max_i(1);  %%% all measures use normalised, smoothed 3x3 pixel sampling profiles
max_x = pix_narray(max_i);  %%%% point index along axon where fluorescence intensity is highest
ais_end = find( (pix_narray>max_i) & (norm_lv<f));
if length(ais_end)>0
    ais_end = ais_end(1);
else
    ais_end = x_pix(length(x_pix));  %%%% point index along axon past max where fluorescence intensity falls to f of its peak
end
ais_start = find( (pix_narray<max_i) & (norm_lv<f)); 
if length(ais_start)>0
    ais_start = ais_start(length(ais_start));
else
    ais_start = 0;%%%% point index along axon pre max where fluorescence intensity falls to f of its peak
end

debut = ais_start*pixconv;  %%%% AIS start position in Ch1, in um
fin = ais_end*pixconv;  %%%% AIS end position in Ch1, in um
lngth = fin-debut;      %%%% AIS length in Ch1, in um
mid = mean([debut fin]); %%%% AIS mid position in Ch1, in um
maxi = max_x*pixconv;   %%%% AIS max position in Ch1, in um

%%%% measures of AIS location & length - Ch2

if nCh>1 & prof>1

max_i2 = (find(norm_lvb==1)); max_i2 = max_i2(1);   %%% so exactly as for Ch1 above
max_x2 = pix_narray(max_i2);
ais_end2 = find( (pix_narray>max_i2) & (norm_lvb<f));
if length(ais_end2)>0
    ais_end2 = ais_end2(1);
else
    ais_end2 = x_pix(length(x_pix));
end
ais_start2 = find( (pix_narray<max_i2) & (norm_lvb<f)); 
if length(ais_start2)>0
    ais_start2 = ais_start2(length(ais_start2));
else
    ais_start2 = 0;
end
ais_length2 = ais_end2 - ais_start2;

debut2 = ais_start2*pixconv;   %%%% AIS start position in Ch2, in um
fin2 = ais_end2*pixconv;   %%%% AIS end position in Ch2, in um
lngth2 = fin2-debut2;      %%%% AIS length in Ch2, in um
mid2 = mean([debut2 fin2]); %%%% AIS mid position in Ch2, in um
maxi2 = max_x2*pixconv;    %%%% AIS max position in Ch2, in um

else
    debut2 = NaN; fin2 = NaN; lngth2 = NaN; mid2 = NaN; maxi2 = NaN;
end

%%%%% measures of AIS localisation

if AISindices>0   
    if AISindexCh==1
        r = pearsonr(lv_c,lv_cb);   %%%% Pearson parametric correlation co-efficient between raw fluorescence intensity profiles
        ais = norm_lv(find((pix_narray>=ais_start2)&(pix_narray<=ais_end2)));
        nonais = [norm_lv(find((pix_narray<ais_start2))) norm_lv(find((pix_narray>ais_end2)))];
        AISi = ( mean(ais) - mean(nonais)) ./ ( mean(ais)+mean(nonais));     %%%% ratio of mean fluorescence intensity inside AIS vs outside AIS
        r2 = NaN; AISi2 = NaN;
    else
        r2 = pearsonr(lv_c,lv_cb);   
        ais = norm_lv(find((pix_narray>=ais_start)&(pix_narray<=ais_end)));
        nonais = [norm_lv(find((pix_narray<ais_start))) norm_lv(find((pix_narray>ais_end)))];
        AISi2 = ( mean(ais) - mean(nonais)) ./ ( mean(ais)+mean(nonais));    
        r = NaN; AISi = NaN;
    end
else
    r = NaN; AISi = NaN; r2 = NaN; AISi2 = NaN;
end

%%%%% plotting

figure(3)
subplot(2,2,3)
plot(axon_um,lv_c,'g-') %%%% plotting raw Ch1 fluorescence intensity values in green
axis square
title('Raw')
if nCh>1 & prof>1
    hold on
    plot(axon_um,lv_cb,'r-') %%%% plotting raw Ch2 fluorescence intensity values in red
    hold off
end
subplot(2,2,4)
plot(axon_um,norm_lv,'g-') %%%% plotting normalised, smoothed Ch1 fluo in green
hold on
if nCh>1 & prof>1
    plot(axon_um,norm_lvb,'r-') %%%% plotting normalised, smoothed Ch1 fluo in red
end
if prof==2
    plot([ais_end2*pixconv ais_end2*pixconv],[0 1],'b-')
    plot([ais_start2*pixconv ais_start2*pixconv],[0 1],'b-')
    plot([max_x2*pixconv max_x2*pixconv],[0 1],'b-')
    text((max(axon_um)-25),0.9,'Ch2 prof','color','b')
else %%% so if prof==1, or prof==3
    plot([ais_end*pixconv ais_end*pixconv],[0 1],'b-')
    plot([ais_start*pixconv ais_start*pixconv],[0 1],'b-')
    plot([max_x*pixconv max_x*pixconv],[0 1],'b-')  %%%% so plotting AIS start, max and end positions
    text((max(axon_um)-25),0.9,'Ch1 prof','color','b')
end
if byeye>0
    if eye == 2
        plot([eye_start2 eye_start2],[0 1],'m-')
        plot([eye_end2 eye_end2],[0 1],'m-') %%%% and plotting by-eye measures for comparison
        text((max(axon_um)-25),0.8,'Ch2 eye','color','m')
    else
        plot([eye_start eye_start],[0 1],'m-')
        plot([eye_end eye_end],[0 1],'m-') 
        text((max(axon_um)-25),0.8,'Ch1 eye','color','m')
    end
end
axis square
title('Smoothed & normalised')

hold off

%%%% results output

disp(' ')
disp('Ch1 Start')
disp('Ch1 End')
disp('Ch1 Length')
disp('Ch1 Mid')
disp('Ch1 Max')
disp('Ch1 Eye Start')
disp('Ch1 Eye End')
disp('Ch1 Eye Length')
disp('Ch1 Eye Mid')
disp('Ch1 r')
disp('Ch1 AISi')
disp(' ')

disp([debut fin lngth mid maxi eye_start eye_end eye_length eye_mid r AISi]')

if nCh>1
    
disp(' ')
disp('Ch2 Start')
disp('Ch2 End')
disp('Ch2 Length')
disp('Ch2 Mid')
disp('Ch2 Max')
disp('Ch2 Eye Start')
disp('Ch2 Eye End')
disp('Ch2 Eye Length')
disp('Ch2 Eye Mid')
disp('Ch2 r')
disp('Ch2 AISi')
disp(' ')

disp([debut2 fin2 lngth2 mid2 maxi2 eye_start2 eye_end2 eye_length2 eye_mid2 r2 AISi2]')

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [r] = pearsonr(x,y)

n = length(x);
sxy = sum(x.*y);
sx = sum(x);
sy = sum(y);
sx2 = sum(x.^2);
sy2 = sum(y.^2);

r = ( (n*sxy - (sx)*(sy)) / sqrt((n*sx2-sx^2)*(n*sy2-sy^2)) );

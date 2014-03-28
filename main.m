function main(img,s,r,o,alpha,l,sp,noise,b,boolM)
% alpha : Data sampled percentage
%   s   : Sampling method
%   o   : Optimisation method
% noise : Noise amplitude
%   b   : Blur Standard Deviation
%   l   : Lambda parameter (CVX)
%  sp   : Sparcity parameter (Cosamp)
% boolM : Boolean for keeping the same phi matrix

% set up original image
tic
scrsz=get(0,'ScreenSize');
perf=figure('Name','Compressive Sensing Output','NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[(scrsz(3)-800)/2 (scrsz(4)-600)/2 800 600]);
htabgroup=uitabgroup;
tab1 = uitab(htabgroup,'title','IMGS Panel');

subplot('Position',[0.01 0.505 0.485 0.44],'Parent',tab1);
imagesc(img); axis('off'); colormap(gray);
title('Original Image'); drawnow;
[m,n] = size(img);

% add uniform random noise
noi_str=['Noise variance: ',num2str(noise),'%'];
blr_str=['Blur standard deviation ',num2str(b),'%'];
if (noise||b)
    noise=noise*randn(m,n);
    try
        filter=fspecial('gaussian',[m,n],b);
        img_b=imfilter(img+noise,filter);
    catch
        img_b=img+noise;
    end
    disp(noi_str);
    disp(blr_str);
else
    img_b=img;
end
subplot('Position',[0.505 0.505 0.485 0.44],'Parent',tab1);
imagesc(img_b); axis('off'); colormap(gray);
title('Blurred Image'); drawnow;

% random sampling acquisition with y=phi*x
disp('# sampling acquisition');
if boolM
    load('phi','phi');
    y=phi*reshape(img_b,m*n,1);
else
    [phi,y]=sampling(alpha/100,img_b,s);
end
if s==1
    spl_str=['Sampling method: Random Sampling coefficient: ',num2str(alpha),'%'];
elseif s==2
    spl_str=['Sampling method: Column Sampling coefficient: ',num2str(alpha),'%'];
elseif s==3
    spl_str=['Sampling method: Line   Sampling coefficient: ',num2str(alpha),'%'];
end
disp(spl_str);

img_samp=zeros(m*n,1);
img_samp(phi*transpose(1:m*n)) = 1;
img_samp=reshape(img_samp,m,n).*img_b; % On applique le masque
subplot('Position',[0.01 0.01 0.485 0.44],'Parent',tab1);
imagesc(img_samp); axis('off'); colormap(gray);
title('Sampled Image'); drawnow;

% projection matrix on new basis with x=psi*v
disp('# fourier projection');
if r==1
elseif r==2
end
psi=getBaseFourier(m,n);

% solution optimisation
N=m*n;
tab2 = uitab(htabgroup,'title','PERF Panel');
t1=toc;
if o==1
    disp('# convex optimisation');
    opt_str=['Optimisation method: Convex (CVX)     Lambda: ',num2str(l)];
    disp(opt_str);
    subplot('Position',[0.54 0.505 0.45 0.44],'Parent',tab2);
    [v, ~] = optimisation_cvx(y,phi,psi,N,l);
elseif o==2
    disp('# cosamp optimisation');
    opt_str=['Optimisation method: Greedy (Cosamp)  Sparcity Coefficient: ',num2str(sp)];
    disp(opt_str);
    subplot('Position',[0.528 0.505 0.462 0.44],'Parent',tab2);
    [v, ~] = optimisation_cosamp(y,phi,psi,N,sp);
elseif o==3
    disp('# bayesian optimisation');
    opt_str=['Optimisation method: Bayesian :',num2str(0)];
    disp(opt_str);
    v = optimisation_bayes(y,phi,psi,m,n);drawnow;
    set(0,'CurrentFigure',perf);
    subplot('Position',[0.528 0.505 0.462 0.44],'Parent',tab2);
end
t2=toc; drawnow;

% come back in real basis
disp('# real basis come back');
x1=psi*v;
x1_2d=reshape(x1,m,n);
if o==3
    x1_bay=abs(x1);
    x1_bay=(x1_bay-min(x1_bay))/max(x1_bay);
    plot(sort(x1_bay,'descend'));hold on;
    plot(sort(reshape(img,N,1),'descend'),'r')
    legend('reconstructed image','original image')
    title('Image Dynamic');xlabel('???');ylabel('???');hold off;
end
subplot('Position',[0.505 0.01 0.485 0.44],'Parent',tab1);
imagesc(abs(x1_2d)); axis('off'); colormap(gray);
title('Reconstructed Image'); drawnow;
tab3 = uitab(htabgroup,'title','SURF Panel');
IMG = abs(fftshift(fft2(x1_2d)));
subplot('Position',[0.15 0.05 0.7 0.40],'Parent',tab3);
surf(IMG,'EdgeColor','blue'); title('Reconstructed shifted FFT 2D');
IMG = abs(fftshift(fft2(img)));
subplot('Position',[0.15 0.55 0.7 0.40],'Parent',tab3);
surf(IMG,'EdgeColor','blue'); title('Original shifted FFT 2D');

% display performances and information
uicontrol('Parent',tab2,'Style','text','Position', [80 530 200 25],...
              'FontSize',14,'String','Performance Pannel');
hii=uipanel('Parent',tab2,'Title','Image Information','FontSize',12,'Position',[.01 .68 .46 .2]);
uicontrol('Parent',hii,'Style','text','Position',[22 53 300 30],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Width: ',num2str(m),'px       Height: ',...
              num2str(n),'px']);
mm = min(min(IMG));
MM = max(max(IMG));
AA = floor(200*(IMG-mm)./(MM-mm));
uicontrol('Parent',hii,'Style','text','Position',[22 15 300 30],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Sparcity: ',num2str(100*(1-nnz(AA)/(m*n))),'%']);

snr=num2str(10*log10(sum(sum(img.*img))/sum(sum((img_b-img).*(img_b-img)))));
rmse=num2str(sqrt(sum(sum(abs(img-x1_2d).*abs(img-x1_2d))/(m*n))));
hcsp=uipanel('Parent',tab2,'Title','Compressive Sensing Parameters','FontSize',12,'Position',[.01 .1 .98 .25]);
uicontrol('Parent',hcsp,'Style','text','Position',[22 68 250 45],'FontSize',12,...
              'HorizontalAlignment','left','String',spl_str);
uicontrol('Parent',hcsp,'Style','text','Position',[22 15 300 45],'FontSize',12,...
              'HorizontalAlignment','left','String',opt_str);
uicontrol('Parent',hcsp,'Style','text','Position',[422 68 250 45],'FontSize',12,...
              'HorizontalAlignment','left','String',noi_str);
uicontrol('Parent',hcsp,'Style','text','Position',[422 15 300 45],'FontSize',12,...
              'HorizontalAlignment','left','String',blr_str);
          
hte=uipanel('Parent',tab2,'Title','Time lapse & Error','FontSize',12,'Position',[.01 .39 .46 .25]);
uicontrol('Parent',hte,'Style','text','Position',[22 15 280 45],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Root Mean Square Error: ',rmse,' Signal Noise Ratio: ',snr]);
uicontrol('Parent',tab2,'Style', 'pushbutton','FontSize',12,'String', 'Save Tabs',...
              'Position', [90 10 200 30],'Callback', @saveTabs);
uicontrol('Parent',tab2,'Style', 'pushbutton','FontSize',12,'String', 'Save Logs',...
              'Position', [380 10 200 30],'Callback', @saveLogs);
t3=toc;
uicontrol('Parent',hte,'Style','text','Position',[22 68 250 45],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Total time elapsed: ',num2str(t3),'s Optimisation period: '...
              num2str(t2-t1),'s']);
    function saveTabs(hObj,event)
        time=num2str(now*1000000,12);
        saveas(perf,['perf_',time(4:11),'.png']);
        temp=figure('Name','temp','NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[(scrsz(3)-800)/2 (scrsz(4)-600)/2 800 600]);
    subplot('Position',[0.01 0.505 0.485 0.44]);
    imagesc(img);axis('off');colormap(gray);title('Original Image');
    subplot('Position',[0.505 0.505 0.485 0.44]);
    imagesc(img_b); axis('off');title('Blurred Image');
    subplot('Position',[0.01 0.01 0.485 0.44]);
    imagesc(img_samp); axis('off');title('Sampled Image');
    subplot('Position',[0.505 0.01 0.485 0.44]);
    imagesc(abs(x1_2d));axis('off');title('Reconstructed Image');
        saveas(temp,['log_',time(4:11),'.png']);
        clf;
    IMG = abs(fftshift(fft2(x1_2d)));
    subplot('Position',[0.15 0.05 0.7 0.40]);
    surf(IMG);title('Reconstructed shifted FFT 2D');
    IMG = abs(fftshift(fft2(img)));
    subplot('Position',[0.15 0.55 0.7 0.40]);
    surf(IMG);title('Original shifted FFT 2D');
        saveas(temp,['fft2D_',time(4:11),'.png']);
        close('temp');
        disp('# saved logs');
    end
    function saveLogs(hObj,event)
    id=fopen(['log_',num2str(now*1000000,12),'.csv'],'w');
%     fprintf();
    fclose(id);
    end
end
             
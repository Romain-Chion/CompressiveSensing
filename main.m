function main(img, alpha, s, o, b,l,sp)
% alpha : Data sampled percentage
%   s   : Sampling method
%   o   : Optimisation method
%   b   : Noise amplitude
%   l   : Lambda parameter (CVX)
%   sp  : Sparcity parameter (Cosamp)

% set up original image
tic
scrsz=get(0,'ScreenSize');
perf=figure('Name','Compressive Sensing Performances','NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[scrsz(3)-800 (scrsz(4)-600)/2 800 600]);
imgf=figure('Name','Images Evolution','NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[0 (scrsz(4)-600)/2 800 600]);
subplot('Position',[0.01 0.505 0.485 0.44]);
imagesc(img); axis('off'); colormap(gray);
title('Original Image');
[m,n] = size(img);

% add uniform random noise
if b
    noise=b*randn(m,n);
    img_b=img+noise;
else
    img_b=img;
end
subplot('Position',[0.505 0.505 0.485 0.44]);
imagesc(img_b); axis('off'); colormap(gray);
title('Blurred Image');

% random sampling acquisition with y=phi*x
disp('# sampling acquisition');
[phi, y]=sampling(alpha/100,img_b,s);
if s==1
    sampl=['Sampling method: Random Sampling coefficient: ',num2str(alpha),'%'];
elseif s==2
    sampl=['Sampling method: Column Sampling coefficient: ',num2str(alpha),'%'];
elseif s==3
    sampl=['Sampling method: Line   Sampling coefficient: ',num2str(alpha),'%'];
end

img_samp=zeros(m*n,1);
img_samp(phi*transpose(1:m*n)) = 1;
img_samp=reshape(img_samp,m,n).*img_b; % On applique le masque
subplot('Position',[0.01 0.01 0.485 0.44]);
imagesc(img_samp); axis('off'); colormap(gray);
title('Sampled Image');

% projection matrix on new basis with x=psi*v
disp('# fourier projection');
[psi]=getBaseFourier(m,n);

% solution optimisation
N=m*n;
set(0,'CurrentFigure',perf)
t1=toc;
if o==1
    disp('# convex optimisation');
    [v, A] = optimisation_cvx(y,phi,psi,N,l);
    opt=['Optimisation method: Convex (CVX)     Lambda: ',num2str(l)];
elseif o==2
    disp('# cosamp optimisation');
    [v, A] = optimisation_cosamp(y,phi,psi,N,sp);
    opt=['Optimisation method: Greedy (Cosamp)  Sparcity Coefficient: ',num2str(sp)];
end
t2=toc;

% come back in real basis
disp('# real basis come back');
x1=psi*v;
x1_2d=reshape(x1,m,n);
set(0,'CurrentFigure',imgf)
subplot('Position',[0.505 0.01 0.485 0.44]);
imagesc(abs(x1_2d)); axis('off'); colormap(gray);
title('Reconstructed Image');

% display performances and information
set(0,'CurrentFigure',perf)
uicontrol('Style','text','Position', [80 565 200 25],...
              'FontSize',14,'String','Performance Pannel');
hii=uipanel('Title','Image Information','FontSize',12,'Position',[.01 .69 .46 .2]);
uicontrol('Parent',hii,'Style','text','Position',[22 53 300 30],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Width: ',num2str(m),'px       Height: ',...
              num2str(n),'px']);
IMG = abs(fft2(img));
mm = min(min(IMG));
MM = max(max(IMG));
AA = floor(200*(IMG-mm)./(MM-mm));
uicontrol('Parent',hii,'Style','text','Position',[22 15 300 30],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Sparcity: ',num2str(100*(1-nnz(AA)/(m*n))),'%']);

snr=num2str(10*log10(sum(sum(img.*img))/sum(sum((img_b-img).*(img_b-img)))));
rmse=num2str(sqrt(sum(sum(abs(img-x1_2d).*abs(img-x1_2d))/(m*n))));
hcsp=uipanel('Title','Compressive Sensing Parameters','FontSize',12,'Position',[.01 .05 .46 .25]);
uicontrol('Parent',hcsp,'Style','text','Position',[22 68 250 45],'FontSize',12,...
              'HorizontalAlignment','left','String',sampl);
uicontrol('Parent',hcsp,'Style','text','Position',[22 15 300 45],'FontSize',12,...
              'HorizontalAlignment','left','String',opt);
hte=uipanel('Title','Time lapse & Error','FontSize',12,'Position',[.01 .37 .46 .25]);
uicontrol('Parent',hte,'Style','text','Position',[22 15 280 45],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Root Mean Square Error: ',rmse,' Signal Noise Ratio: ',snr]);
t3=toc;
uicontrol('Parent',hte,'Style','text','Position',[22 68 250 45],'FontSize',12,...
              'HorizontalAlignment','left','String',...
              ['Total time elapsed: ',num2str(t3),'s Optimisation period: '...
              num2str(t2-t1),'s']);
                    
             
function interface

% clear all windows
clc;
clear all;
close all;

% initialize parameters
s = 1;          % Integer for sampling choice
r = 1;          % Integer for basis choice
o = 1;          % Integer for optimisation choice
a = 80;         % Data sampled percentage
l = 0.5;        % Lambda parameter (CVX)
sp = 30;        % Sparcity parameter (Cosamp)
n = 0;          % Noise variance
b = 0;          % Blur standard deviation
boolL = 0;      % Continuous launch
boolM = 0;      % Same sampling matix

% loading saved parameters
            try
                disp('# loading parameters');
                load('last_image', 'file_name')
                load('last_path', 'file_path');
                load('param', 'param');
                s=param(1);
                r=param(2);
                o=param(3);
                a=param(4);
                l=param(5);
                sp=param(6);
                n=param(7);
                b=param(8);
            catch
                disp('# parameters loading failed');
            end

% initialize window
scrsz=get(0,'ScreenSize');
di=dir('interface.m');
figure('Name',['Compressive Sensing Interface (v1.2 ',datestr(di.date,'dd-mm-yyyy'),')'],'NumberTitle','off',...
              'MenuBar','none','Resize','off',...
              'Position',[(scrsz(3)-800)/2 (scrsz(4)-600)/2 800 600]);

% set up settings interface
uicontrol('Style','text','Position', [60 565 200 25],...
              'FontSize',14,'String','Parameters Settings');

% set up sampling interface
hps=uipanel('Title','Sampling setting','FontSize',11,'Position',[.0 .62 .4 .3]);
uicontrol('Parent',hps,'Style','text','Position',[10 135 145 20],...
              'String','Sampling method','FontWeight','bold');
hgs = uibuttongroup('Parent',hps,'BorderType','none','Position',[0 0 .5 1]);
set(hgs,'SelectionChangeFcn',@samplMethod);
uicontrol('Style','radiobutton','String','Random','Tag','s1',...
    'Value',s==1,'pos',[20 105 145 20],'parent',hgs);
uicontrol('Style','radiobutton','String','Column','Tag','s2',...
    'Value',s==2,'pos',[20 70 145 20],'parent',hgs);
uicontrol('Style','radiobutton','String','Line','Tag','s3',...
    'Value',s==3,'pos',[20 35 145 20],'parent',hgs);
uicontrol('Parent',hps,'Style','text','Position',[165 135 145 20],...
              'String','Sampling coefficient (%)','FontWeight','bold');
uicontrol('Style','edit','Max',1,'String',a,...
              'Parent',hps,'Position',[165 70 145 20],'Callback', @getAlpha);

% set up basis interface
hpb=uipanel('Title','Basis setting','FontSize',11,'Position',[.0 .40 .4 .20]);
uicontrol('Parent',hpb,'Style','text','Position', [10 75 145 20],...
               'String','Basis representation','FontWeight','bold');
hgb = uibuttongroup('Parent',hpb,'BorderType','none','Position',[0 0 .5 1]);
set(hgb,'SelectionChangeFcn',@basisMethod);
uicontrol('Style','radiobutton','String','Fourier','Tag','b1',...
    'Value',r==1,'pos',[20 50 145 20],'parent',hgb);
uicontrol('Style','radiobutton','String','Curvlet','Tag','b2',...
    'Value',r==2,'pos',[20 20 145 20],'parent',hgb);

% set up optimisation interface
hpo=uipanel('Title','Optimisation setting','FontSize',11,'Position',[.0 .08 .4 .3]);
uicontrol('Parent',hpo,'Style','text','Position',[10 135 145 20],...
              'String','Optimisation method','FontWeight','bold');
hgo = uibuttongroup('Parent',hpo,'BorderType','none','Position',[0 0 .5 1]);
uicontrol('Style','radiobutton','String','Convex (CVX)','Tag','o1',...
    'Value',o==1,'pos',[20 105 145 20],'parent',hgo);
uicontrol('Style','radiobutton','String','Greedy (Cosamp)','Tag','o2',...
    'Value',o==2,'pos',[20 70 145 20],'parent',hgo);
uicontrol('Style','radiobutton','String','Baysian','Tag','o3',...
    'Value',o==3,'pos',[20 35 145 20],'parent',hgo);
set(hgo,'SelectionChangeFcn',@optMethod);
if o==1
    uicontrol('Parent',hpo,'Style','text','Position',[165 135 145 20],...
              'String','Lambda Coefficient','FontWeight','bold');
    uicontrol('Style','edit','Max',1,'String',l,...
              'Parent',hpo,'Position',[165 70 145 20],'Callback', @getLambda);
elseif o==2
    uicontrol('Parent',hpo,'Style','text','Position', [165 135 145 20],...
              'String','Sparcity coefficient (%)','FontWeight','bold');
    uicontrol('Style','edit','Max',1,'String',sp,...
              'Parent',hpo,'Position', [165 70 145 20],'Callback', @getSparcity);
end

% set up parameters saving
uicontrol('Style', 'pushbutton','FontSize',12,'String', 'Save parameters',...
              'Position', [60 10 200 30],'Callback', @saveParam);

% set up vizualization interface

% set up image figure and information
try
    disp('# image loading');
    hpnb=uipanel('Title','Image setting','FontSize',11,'Position',[.405 .08 .585 .3]);
    img=showPicture(file_path, file_name);
catch merr
    disp('# image loading failed');
    fprintf('Please choose an image!\n%s', ...
               merr.message);
    uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .6 .95 .1],...
              'HorizontalAlignment','left','String','Filepath: ');
    uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .5 .45 .1],...
              'HorizontalAlignment','left','String','Filename: ');
    uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .4 .45 .1],...
              'HorizontalAlignment','left','String','Width: px       Height: px');
    uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .5 .45 .1],...
              'HorizontalAlignment','left','String','Sparcity: %');
end

% set up image setting
uicontrol('Style','pushbutton','FontSize',10,'String','Select Picture',...
              'Position',[450 220 100 20],'Callback',@getPicture);
uicontrol('Style','pushbutton','FontSize',10,'String','Save Picture',...
              'Position',[600 220 100 20],'Callback',@savePicture);
uicontrol('Parent',hpnb,'Style','pushbutton','FontSize',10,'String','Crop Picture',...
              'Position',[15 130 100 20],'Callback',@cropPicture);
          
% set up image information

% set up noise and blur interface
uicontrol('Parent',hpnb,'Style','text','Position', [50 30 145 20],...
              'String','Noise variance','FontWeight','bold');
uicontrol('Parent',hpnb,'Style','edit','Max',1,'String',n,...
              'Position', [60 10 145 20],'Callback', @getNoise);
uicontrol('Parent',hpnb,'Style','text','Position', [265 30 145 20],...
              'String','Blur standard deviation','FontWeight','bold');
uicontrol('Parent',hpnb,'Style','edit','Max',1,'String',b,...
              'Position', [265 10 145 20],'Callback', @getBlur);

% set up compresive sensing launcher
uicontrol('Style','pushbutton','FontSize',12,'String','GO!',...
              'Position', [670 10 100 30],'Callback', @mainLauncher);
uicontrol('Style','checkbox','Position', [615 17 15 15],'Callback', @checkLauncher);
uicontrol('Style','text','Position', [495 17 120 15],...
              'String','clean previous launch');
uicontrol('Style','checkbox','Position', [440 17 15 15],'Callback', @checkMatrix);
uicontrol('Style','text','Position', [360 17 80 15],...
              'String','keep phi matrix');
          
% set up call back functions

% set up method functions
    function optMethod(hObj,eventdata)
        switch get(eventdata.NewValue,'Tag')
            case 'o1'
                o=1;
            case 'o2'
                o=2;
            case 'o3'
                o=3;
        end
        if o==1
            uicontrol('Parent',hpo,'Style','text','Position',[165 135 145 20],...
              'FontWeight','bold','String','Lambda Coefficient');
            uicontrol('Style','edit','Max',1,'String',l,...
              'Parent',hpo,'Position',[165 70 145 20],'Callback', @getLambda);
        elseif o==2
            uicontrol('Parent',hpo,'Style','text','Position', [165 135 145 20],...
              'FontWeight','bold','String','Sparcity coefficient (%)');
            uicontrol('Style','edit','Max',1,'String',sp,...
              'Parent',hpo,'Position', [165 70 145 20],'Callback', @getSparcity);
        elseif o==3
            uicontrol('Parent',hpo,'Style','text','Position', [165 135 145 20],...
              'FontWeight','bold','String','No parameter');
            uicontrol('Style','edit','Max',1,...
              'Parent',hpo,'Position',[165 70 145 20],'Enable','off');
        end
    end
    function basisMethod(hObj,eventdata)
        switch get(eventdata.NewValue,'Tag')
            case 'b1'
                r=1;
            case 'b2'
                r=2;
        end
    end
    function samplMethod(hObj,eventdata)
        switch get(eventdata.NewValue,'Tag')
            case 's1'
                s=1;
            case 's2'
                s=2;
            case 's3'
                s=3;
        end
    end

% set up parameters functions
    function getAlpha(hObj,event)
        getter = str2num(get(hObj,'String'));
        if (getter>=0&&getter<=100)
            a=getter;
        else
            sprintf('Please enter value between 0 and 100')
            popUp('Please enter value between 0 and 100');
        end
    end
    function getLambda(hObj,event)
        getter = str2num(get(hObj,'String'));
        if (getter>=0&&getter<=1)
            l=getter;
        else
            sprintf('Please enter value between 0 and 1')
            popUp('Please enter value between 0 and 1');
        end
    end
    function getSparcity(hObj,event)
        getter = str2num(get(hObj,'String'));
        if (getter>=0&&getter<=50)
            sp=getter;
        else
            sprintf('Please enter value between 0 and 50')
            popUp('Please enter value between 0 and 50');
        end
    end
    function getNoise(hObj,event)
        getter = str2num(get(hObj,'String'));
        if (getter>=0&&getter<=1)
            n=getter;
        else
            sprintf('Please enter value between 0 and 1')
            popUp('Please enter value between 0 and 1');
        end
    end
    function getBlur(hObj,event)
        getter = str2num(get(hObj,'String'));
        if (getter>=0&&getter<=3)
            b=getter;
        else
            sprintf('Please enter value between 0 and 3')
            popUp('Please enter value between 0 and 3');
        end
    end
    function saveParam(hObj,event)
        param=[s,r,o,a,l,sp,n,b];
        save('param', 'param');
    end
    function popUp(text)
        msgbox(text,'Parameter Error');
    end

% set up picture functions
    function getPicture(hObj,event)
        [name, path] = uigetfile( ...
           {'*.jpeg;*.jpg;*.bmp;*.tif;*.tiff;*.png;*.gif', ...
            'Image Files (JPEG, BMP, TIFF, PNG and GIF)'}, ...
            'Select Images', 'multiselect', 'off');
        if name
            file_name=name
            file_path=path
            save('last_image', 'file_name');
            save('last_path', 'file_path');
            img=showPicture(file_path, file_name);
        end
    end
    function img=showPicture(file_path, file_name)
        img = imread(strcat(file_path, file_name));
        img = double(img(:,:,1));
        mm = min(min(img));
        MM = max(max(img));
        img = (img - mm)/(MM - mm); % Normalisation dans [0,1]
        subplot('Position',[0.4 0.4 0.6 0.6]);
        imagesc(img); colormap(gray); axis('off');
        info=imfinfo(strcat(file_path, file_name));
        uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .6 .95 .1],...
              'HorizontalAlignment','left','String',['Filepath: ',file_path]);
        uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .5 .95 .1],...
              'HorizontalAlignment','left','String',['Filename: ',file_name]);
        uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .4 .45 .1],...
              'HorizontalAlignment','left','String',['Width: ',num2str(info.Width),'px       Height: ',...
              num2str(info.Height),'px']);
        IMG = abs(fftshift(fft2(img)));
        mm = min(min(IMG));
        MM = max(max(IMG));
        A = floor(200*(IMG-mm)./(MM-mm));
        uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .5 .45 .1],...
              'HorizontalAlignment','left','String',...
              ['Sparcity: ',num2str(100*(1-nnz(A)/(info.Height*info.Width))),'%']);
        try
            uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .4 .45 .1],...
                  'HorizontalAlignment','left','String',['Last edit: ',info.ImageModTime(1:20)]);
        catch
            uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .4 .45 .1],...
                  'HorizontalAlignment','left','String','Last edit: ');
        end
    end
    function savePicture(hObj,event)
        [name,path,~] = uiputfile(...
            {'*.*','All Files';...
            '*.jpeg;*.jpg','Joint Photographic Experts Group (JPEG)';...
            '*.bmp','Bitmap (BMP)';...
            '*.tif;*.tiff','Tagged Image File Format (TIFF)';...
            '*.png','Portable Network Graphics (PNG)';...
            '*.gif','Graphics Interchange Format (GIF)'});            
        try
            imwrite(img,[path,name]);
            disp(['# saved picture: ',name]);
            file_name=name;
            file_path=path;
            save('last_image', 'file_name');
            save('last_path', 'file_path');
        catch
            disp(['# saved picture: failed']);
        end
    end
    function cropPicture(hObj,event)
        p = ginput(1); % Get the x and y corner coordinates as integers
        pp(1) = round(p(1));
        pp(2) = round(p(2));
        uicontrol('Parent',hpnb,'Style','text','FontSize',10,...
              'Position',[150 130 120 20],'String',['[x1 y1] = [',...
              num2str(pp(1)),' ',num2str(pp(2)),']']);
        subplot('Position',[0.4 0.4 0.6 0.6]);
        hold on
        plot([p(1) p(1)],[0 size(img,1)+1],[0 size(img,2)+1],...
            [p(2) p(2)],'Color',[1 0 0],'LineWidth',1.5);
        hold off
        p = ginput(1);
        pp(3) = round(p(1));
        pp(4) = round(p(2));
        uicontrol('Parent',hpnb,'Style','text','FontSize',10,...
              'Position',[290 130 120 20],'String',['[x2 y2] = [',...
              num2str(pp(3)),' ',num2str(pp(4)),']']);
        subplot('Position',[0.4 0.4 0.6 0.6]);
        imgc=img(min(pp(2),pp(4)):max(pp(2),pp(4)),min(pp(1),pp(3)):max(pp(1),pp(3)));
        imagesc(imgc); colormap(gray); axis('off');
        SS = size(imgc);
        IMG = abs(fftshift(fft2(imgc)));
        mm = min(min(IMG));
        MM = max(max(IMG));
        A = floor(200*(IMG-mm)./(MM-mm));
        uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .5 .45 .1],...
              'HorizontalAlignment','left','String',...
              ['Sparcity: ',num2str(100*(1-nnz(A)/(SS(1)*SS(2)))),'%']);
        choice = questdlg('Crop the picture?', ...
            'Confirmation Box', ...
            'Yes','No','No');
        switch choice
            case 'Yes'
                img = double(imgc);
                mm = min(min(img));
                MM = max(max(img));
                img = (img - mm)/(MM - mm);
                uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.05 .4 .45 .1],...
                  'HorizontalAlignment','left','String',['Width: ',num2str(pp(3)-pp(1)),'px       Height: ',...
                  num2str(pp(4)-pp(2)),'px']);
            case 'No'
                subplot('Position',[0.4 0.4 0.6 0.6]);
                imagesc(img); colormap(gray); axis('off');
                SS = size(img);
                IMG = abs(fftshift(fft2(img)));
                mm = min(min(IMG));
                MM = max(max(IMG));
                A = floor(200*(IMG-mm)./(MM-mm));
                uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .5 .45 .1],...
                    'HorizontalAlignment','left','String',...
                    ['Sparcity: ',num2str(100*(1-nnz(A)/(SS(1)*SS(2)))),'%']);
            case ''
                subplot('Position',[0.4 0.4 0.6 0.6]);
                imagesc(img); colormap(gray); axis('off');
                SS = size(img);
                IMG = abs(fftshift(fft2(img)));
                mm = min(min(IMG));
                MM = max(max(IMG));
                A = floor(200*(IMG-mm)./(MM-mm));
                uicontrol('Parent',hpnb,'Style','text','Units','normalized','Position',[.55 .5 .45 .1],...
                    'HorizontalAlignment','left','String',...
                    ['Sparcity: ',num2str(100*(1-nnz(A)/(SS(1)*SS(2)))),'%']);
        end
    end

% set up launcher function
    function checkLauncher(hObj,event)
        boolL=get(hObj,'Value');
    end
    function checkMatrix(hObj,event)
        boolM=get(hObj,'Value');
        if boolM
        choice = questdlg('Generate new phi matrix?', ...
            'Confirmation Box', ...
            'Yes','No','No');
        switch choice
            case 'Yes'
                [phi,~]=sampling(a/100,img,s);
                save('phi','phi');
            case 'No'
            case ''
        end
        end
    end
    function mainLauncher(hObj,event)
        if file_name
            disp('# main function');
            try
                if boolL
                    while 1
                        close('Compressive Sensing Output');
                    end
                end
            catch
            end
            try
                main(img,s,r,o,a,l,sp,n,b,boolM);                   
            catch merr
                disp('# main function failed');
                errordlg(sprintf( ...
                    'Please check all parameters requirements are fulfilled !\n%s', ...
                    merr.message), merr.identifier)
            end
        else
            errordlg('No image selected')
        end
    end
end
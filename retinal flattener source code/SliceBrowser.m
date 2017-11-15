% ======================================================================
%> SLICEBROWSER M-file for SliceBrowser.fig
%>       SliceBrowser is an interactive viewer of 3D volumes, 
%>       it shows 3 perpendicular slices (XY, YZ, ZX) with 3D pointer.
%>   Input:  a) VOLUME - a 3D matrix with volume data
%>           b) VOLUME - a 4D matrix with volume data over time
%>   Control:
%>       - Clicking into the window changes the location of 3D pointer.
%>       - 3D pointer can be moved also by keyboard arrows.
%>       - Pressing +/- will switch to next/previous volume.
%>       - Pressing 1,2,3 will change the focus of current axis.
%>       - Pressing 'e' will print the location of 3D pointer.
%>       - Pressing 'c' switches between color-mode and grayscale.
%>       - Pressing 'q' switches scaling of axis (equal/normal).
%>   Example of usage:
%>       load mri.dat
%>       volume = squeeze(D);
%>       SliceBrowser(volume);
%>
%> Author: Marian Uhercik, CMP, CTU in Prague
%> Web: http://cmp.felk.cvut.cz/~uhercik/3DSliceViewer/3DSliceViewer.htm
%> Last Modified by 21-Jul-2011
% ======================================================================
function varargout = SliceBrowser(varargin)

% Documentation generated GUIDE:
%
%SLICEBROWSER M-file for SliceBrowser.fig
%      SLICEBROWSER, by itself, creates a new SLICEBROWSER or raises the existing
%      singleton*.
%
%      H = SLICEBROWSER returns the handle to a new SLICEBROWSER or the handle to
%      the existing singleton*.
%
%      SLICEBROWSER('Property','Value',...) creates a new SLICEBROWSER using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to SliceBrowser_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      SLICEBROWSER('CALLBACK') and SLICEBROWSER('CALLBACK',hObject,...) call the
%      local function named CALLBACK in SLICEBROWSER.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SliceBrowser

% Last Modified by GUIDE v2.5 24-Oct-2014 12:46:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SliceBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @SliceBrowser_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SliceBrowser is made visible.
function SliceBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

% Choose default command line output for SliceBrowser
handles.output = hObject;
global keypresson
keypresson=0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SliceBrowser wait for user response (see UIRESUME)
% uiwait(handles.figure1);

if (length(varargin) <=0)
    error('Input volume has not been specified.');
end;
volume = varargin{1};
handles.withSurfaces=0;
handles.withPoints=0;
handles.withCells=0;
if (length(varargin)>1)
    handles.cellbodies=varargin{2};
    handles.withCells=1;
    if (length(varargin)>2)
    minmesh=varargin{3};
    maxmesh=varargin{4};
%     if (size(minmesh,1)>256)||(size(minmesh,2)>256)||(size(maxmesh,1)>256)||(size(maxmesh,2)>256)
%         npointsx=floor(size(minmesh,1)/256);
%         npointsy=floor(size(minmesh,2)/256);
%         xrange=1:npointsx:size(minmesh,1);
%         yrange=1:npointsy:size(minmesh,2);
%         [meshx,meshy]=meshgrid(1:size(minmesh,1),1:size(minmesh,2));
%         [newmeshx,newmeshy]=meshgrid(xrange,yrange);
%         minmesh=interp2(meshx,meshy,minmesh,newmeshx,newmeshy);
%         maxmesh=interp2(meshx,meshy,maxmesh,newmeshx,newmeshy);
%     end
    handles.submeshmin=minmesh;
    handles.submeshmax=maxmesh;
    handles.withSurfaces=1;
    if (length(varargin)>4)
        set(handles.chatpointnum,'Enable','off');
        set(handles.addpoint,'Enable','off');
        set(handles.showallpoints,'Enable','off');
        set(handles.addtotop,'Enable','off');
        set(handles.addtobottom,'Enable','off');
    else
        handles.withPoints=1;
    end
    end
else
    set(handles.showchat,'Enable','off');
    set(handles.chatpointnum,'Enable','off');
    set(handles.addpoint,'Enable','off');
    set(handles.showallpoints,'Enable','off');
    set(handles.addtotop,'Enable','off');
    set(handles.addtobottom,'Enable','off');
end
% set(handles.topsurfpoint,'Enable','off');
% set(handles.bottomsurfpoint,'Enable','off');
if (ndims(volume) ~= 3 && ndims(volume) ~= 4)
    error('Input volume must have 3 or 4 dimensions.');
end;
handles.volume = volume;

handles.axis_equal = 0;
handles.color_mode = 1;
if (size(volume,4) ~= 3)
    handles.color_mode = 0;
end;

% set main wnd title
set(gcf, 'Name', 'Slice Viewer')

% init 3D pointer
vol_sz = size(volume); 
if (ndims(volume) == 3)
    vol_sz(4) = 1;
end;
pointer3dt = floor(vol_sz/2)+1;
handles.pointer3dt = pointer3dt;
handles.vol_sz = vol_sz;
% set(gcf,'CurrentCharacter','1')
% eval('SliceBrowserFigure_KeyPressFcn(gcf,[],handles)');
set(handles.chatpointnum,'String',{''});
set(handles.chatpointnum,'Value',1);
set(handles.addtotop,'Value',1);
global addpoint chatpointx chatpointy chatpointz chatpointradius chatpointsurf
addpoint=0;
% chatpointx=[];
% chatpointy=[];
% chatpointz=[];
% chatpointradius=[];
% chatpointsurf=[];
for i=1:length(chatpointx)
    xpos=chatpointx(i);
    ypos=chatpointy(i);
    zpos=chatpointz(i);
    radius=chatpointradius(i);
    surf=chatpointsurf(i);
    pointlist=get(handles.chatpointnum,'String');
    pointlist{length(pointlist)+1}=num2str(length(pointlist));
    set(handles.chatpointnum,'String',pointlist);
    set(handles.chatpointnum,'Value',length(pointlist));
    set(handles.chatpointx,'String',xpos);
    set(handles.chatpointy,'String',ypos);
    set(handles.chatpointz,'String',zpos);
    set(handles.chatpointradius,'String',radius);
    set(handles.topsurfpoint,'Value',surf);
    set(handles.bottomsurfpoint,'Value',~surf);
    set(handles.deletepoint,'Enable','on');
end

plot3slices(hObject, handles);

% stores ID of last axis window 
% (0 means that no axis was clicked yet)
handles.last_axis_id = 3;
set(handles.fig2scroll,'Value',1);

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = SliceBrowser_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on mouse press over axes background.
function Subplot1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the XY slice

%disp('Subplot1:BtnDown');
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); ypos=round(pt(1,1));
zpos = handles.pointer3dt(3);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
global addpoint chatpointx chatpointy chatpointz chatpointradius chatpointsurf
if addpoint
    pointlist=get(handles.chatpointnum,'String');
    pointlist{length(pointlist)+1}=num2str(length(pointlist));
    set(handles.chatpointnum,'String',pointlist);
    set(handles.chatpointnum,'Value',length(pointlist));
    chatpointx=[chatpointx,xpos];
    chatpointy=[chatpointy,ypos];
    chatpointz=[chatpointz,zpos];
    chatpointradius=[chatpointradius,50];
    surf=get(handles.addtotop,'Value');
    chatpointsurf=[chatpointsurf,surf];
    set(handles.chatpointx,'String',xpos);
    set(handles.chatpointy,'String',ypos);
    set(handles.chatpointz,'String',zpos);
    set(handles.chatpointradius,'String',50);
    set(handles.topsurfpoint,'Value',surf);
    set(handles.bottomsurfpoint,'Value',~surf);
    set(handles.deletepoint,'Enable','on');
end
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 1;
% Update handles structure
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function Subplot2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the YZ slice

%disp('Subplot2:BtnDown');
pt=get(gca,'currentpoint');
xpos=round(pt(1,2)); zpos=round(pt(1,1));
ypos = handles.pointer3dt(2);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
global addpoint chatpointx chatpointy chatpointz chatpointradius chatpointsurf
if addpoint
    pointlist=get(handles.chatpointnum,'String');
    pointlist{length(pointlist)+1}=num2str(length(pointlist));
    set(handles.chatpointnum,'String',pointlist);
    set(handles.chatpointnum,'Value',length(pointlist));
    chatpointx=[chatpointx,xpos];
    chatpointy=[chatpointy,ypos];
    chatpointz=[chatpointz,zpos];
    chatpointradius=[chatpointradius,50];
    surf=get(handles.addtotop,'Value');
    chatpointsurf=[chatpointsurf,surf];
    set(handles.chatpointx,'String',xpos);
    set(handles.chatpointy,'String',ypos);
    set(handles.chatpointz,'String',zpos);
    set(handles.chatpointradius,'String',50);
    set(handles.topsurfpoint,'Value',surf);
    set(handles.bottomsurfpoint,'Value',~surf);
    set(handles.deletepoint,'Enable','on');
end
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 2;
% Update handles structure
guidata(hObject, handles);

% --- Executes on mouse press over axes background.
function Subplot3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to Subplot3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This object contains the XZ slice

%disp('Subplot3:BtnDown');
pt=get(gca,'currentpoint');
zpos=round(pt(1,2)); ypos=round(pt(1,1));
xpos = handles.pointer3dt(1);
tpos = handles.pointer3dt(4);
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
global addpoint chatpointx chatpointy chatpointz chatpointradius chatpointsurf
if addpoint
    pointlist=get(handles.chatpointnum,'String');
    pointlist{length(pointlist)+1}=num2str(length(pointlist));
    set(handles.chatpointnum,'String',pointlist);
    set(handles.chatpointnum,'Value',length(pointlist));
    chatpointx=[chatpointx,xpos];
    chatpointy=[chatpointy,ypos];
    chatpointz=[chatpointz,zpos];
    chatpointradius=[chatpointradius,50];
    surf=get(handles.addtotop,'Value');
    chatpointsurf=[chatpointsurf,surf];
    set(handles.chatpointx,'String',xpos);
    set(handles.chatpointy,'String',ypos);
    set(handles.chatpointz,'String',zpos);
    set(handles.chatpointradius,'String',50);
    set(handles.topsurfpoint,'Value',surf);
    set(handles.bottomsurfpoint,'Value',~surf);
    set(handles.deletepoint,'Enable','on');
end
plot3slices(hObject, handles);
% store this axis as last clicked region
handles.last_axis_id = 3;
% Update handles structure
guidata(hObject, handles);

% --- Executes on key press with focus on SliceBrowserFigure and no controls selected.
function SliceBrowserFigure_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to SliceBrowserFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global keypresson chatpointx chatpointy chatpointz chatpointradius chatpointsurf
if ~keypresson
keypresson=1;
%disp('SliceBrowserFigure_KeyPressFcn');
curr_char = int8(get(gcf,'CurrentCharacter'));
if isempty(curr_char)
    return;
end;

xpos = handles.pointer3dt(1);
ypos = handles.pointer3dt(2);
zpos = handles.pointer3dt(3); 
tpos = handles.pointer3dt(4); 
% Keys:
% - up:   30
% - down:   31
% - left:   28
% - right:   29
% - '1': 49
% - '2': 50
% - '3': 51
% - 'e': 101
% - plus:  43
% - minus:  45
% - delete: 127
switch curr_char
    case 99 % 'c'
        handles.color_mode = 1 - handles.color_mode;
        if (handles.color_mode ==1 && size(handles.volume,4) ~= 3)
            handles.color_mode = 0;
        end;
        
    case 113 % 'q'
        handles.axis_equal = 1 - handles.axis_equal;
        
    case 30
        switch handles.last_axis_id
            case 1
                xpos = xpos -1;
            case 2
                xpos = xpos -1;
            case 3
                zpos = zpos -1;
            case 0
        end;
    case 31
        switch handles.last_axis_id
            case 1
                xpos = xpos +1;
            case 2
                xpos = xpos +1;
            case 3
                zpos = zpos +1;
            case 0
        end;
    case 28
        switch handles.last_axis_id
            case 1
                ypos = ypos -1;
            case 2
                zpos = zpos -1;
            case 3
                ypos = ypos -1;
            case 0
        end;
    case 29
        switch handles.last_axis_id
            case 1
                ypos = ypos +1;
            case 2
                zpos = zpos +1;
            case 3
                ypos = ypos +1;
            case 0
        end;
    case 43
        % plus key
        tpos = tpos+1
    case 45
        % minus key
        tpos = tpos-1
    case 49
        % key 1
        handles.last_axis_id = 1;
        set(handles.fig3scroll,'Value',1);
        set(handles.fig1scroll,'Value',0);
        set(handles.fig2scroll,'Value',0);
    case 50
        % key 2
        handles.last_axis_id = 2;
        set(handles.fig1scroll,'Value',1);
        set(handles.fig2scroll,'Value',0);
        set(handles.fig3scroll,'Value',0);
    case 51
        % key 3
        handles.last_axis_id = 3;
        set(handles.fig2scroll,'Value',1);
        set(handles.fig1scroll,'Value',0);
        set(handles.fig3scroll,'Value',0);
    case 101
        disp(['[' num2str(xpos) ' ' num2str(ypos) ' ' num2str(zpos) ' ' num2str(tpos) ']']);
    case 127
        % delete key
        %pointnum=get(handles.chatpointnum,'Value')-1;\
        pointnum=length(chatpointx);
        if pointnum>0
            pointnum=pointnum+1;
            pointlist=get(handles.chatpointnum,'String');
            pointlist(pointnum)=[];
            set(handles.chatpointnum,'String',pointlist);
            set(handles.chatpointnum,'Value',pointnum-1);
            chatpointx(pointnum-1)=[];
            chatpointy(pointnum-1)=[];
            chatpointz(pointnum-1)=[];
            chatpointradius(pointnum-1)=[];
            chatpointsurf(pointnum-1)=[];
            if pointnum>2
                set(handles.chatpointx,'String',chatpointx(pointnum-2));
                set(handles.chatpointy,'String',chatpointy(pointnum-2));
                set(handles.chatpointz,'String',chatpointz(pointnum-2));
                set(handles.chatpointradius,'String',chatpointradius(pointnum-2))
                set(handles.topsurfpoint,'Value',chatpointsurf(pointnum-2));
                set(handles.bottomsurfpoint,'Value',~chatpointsurf(pointnum-2));
            else
                set(handles.chatpointx,'String','');
                set(handles.chatpointy,'String','');
                set(handles.chatpointz,'String','');
                set(handles.chatpointradius,'String','')
                set(handles.topsurfpoint,'Value',0)
                set(handles.bottomsurfpoint,'Value',0)
                set(handles.deletepoint,'Enable','off')
            end
        end
    otherwise
        return
end;
handles.pointer3dt = [xpos ypos zpos tpos];
handles.pointer3dt = clipointer3d(handles.pointer3dt,handles.vol_sz);
plot3slices(hObject, handles);
pause(0.025)
% Update handles structure
guidata(hObject, handles);
keypresson=0;
end

% --- Plots all 3 slices XY, YZ, XZ into 3 subplots
function [sp1,sp2,sp3] = plot3slices(hObject, handles)
% pointer3d     3D coordinates in volume matrix (integers)

handles.pointer3dt;
size(handles.volume);
showchat=get(handles.showchat,'Value');
value3dt = handles.volume(handles.pointer3dt(1), handles.pointer3dt(2), handles.pointer3dt(3), handles.pointer3dt(4));

text_str = ['[X:' int2str(handles.pointer3dt(1)) ...
           ', Y:' int2str(handles.pointer3dt(2)) ...
           ', Z:' int2str(handles.pointer3dt(3)) ...
           ', Time:' int2str(handles.pointer3dt(4)) '/' int2str(handles.vol_sz(4)) ...
           '], value:' num2str(value3dt)];
set(handles.pointer3d_info, 'String', text_str);
guidata(hObject, handles);

if (handles.color_mode ==1)
    sliceXY = squeeze(handles.volume(:,:,handles.pointer3dt(3),:));
    sliceYZ = squeeze(handles.volume(handles.pointer3dt(1),:,:,:));
    sliceXZ = squeeze(handles.volume(:,handles.pointer3dt(2),:,:));

    max_xyz = max([ max(sliceXY(:)) max(sliceYZ(:)) max(sliceXZ(:)) ]);
    min_xyz = min([ min(sliceXY(:)) min(sliceYZ(:)) min(sliceXZ(:)) ]);
    clims = [ min_xyz max_xyz ];
    if handles.withCells==1
        cellsXY = squeeze(handles.cellbodies(:,:,handles.pointer3dt(3),:));
        cellsYZ = squeeze(handles.cellbodies(handles.pointer3dt(1),:,:,:));
        cellsXZ = squeeze(handles.cellbodies(:,handles.pointer3dt(2),:,:));
    end
else
    sliceXY = squeeze(handles.volume(:,:,handles.pointer3dt(3),handles.pointer3dt(4)));
    sliceYZ = squeeze(handles.volume(handles.pointer3dt(1),:,:,handles.pointer3dt(4)));
    sliceXZ = squeeze(handles.volume(:,handles.pointer3dt(2),:,handles.pointer3dt(4)));

    max_xyz = max([ max(sliceXY(:)) max(sliceYZ(:)) max(sliceXZ(:)) ]);
    min_xyz = min([ min(sliceXY(:)) min(sliceYZ(:)) min(sliceXZ(:)) ]);
    clims = [ min_xyz max_xyz ];
    if handles.withCells==1
        cellsXY = squeeze(handles.cellbodies(:,:,handles.pointer3dt(3),handles.pointer3dt(4)));
        cellsYZ = squeeze(handles.cellbodies(handles.pointer3dt(1),:,:,handles.pointer3dt(4)));
        cellsXZ = squeeze(handles.cellbodies(:,handles.pointer3dt(2),:,handles.pointer3dt(4)));
    end
end;
sliceZY = squeeze(permute(sliceYZ, [2 1 3]));
if handles.withCells==1
    cellsZY = squeeze(permute(cellsYZ, [2 1 3]));
end

sp1 = subplot(2,2,1);
%colorbar;

imagesc(sliceXY, clims);
if handles.withCells==1
backim=cat(3,ones(size(sliceXY)),ones(size(sliceXY)),zeros(size(sliceXY)));
hold on
im=imagesc(backim);
hold off
set(im,'AlphaData',0.25.*cellsXY);
end
title('Slice XY');
ylabel('X');xlabel('Y');
line([handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume,1)]);
line([0 size(handles.volume,2)], [handles.pointer3dt(1) handles.pointer3dt(1)]);
%set(allchild(gca),'ButtonDownFcn',@Subplot1_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot1_ButtonDownFcn'',gca,[],guidata(gcbo))');
if (handles.axis_equal == 1)
    axis image;
else
    axis normal;
end;
% handles.pointer3dt(1)
% handles.pointer3dt(2)
% handles.pointer3dt(3)
% floor(handles.pointer3dt(1)/size(handles.volume,1)*size(handles.submeshmin,1))
% floor(handles.pointer3dt(2)/size(handles.volume,2)*size(handles.submeshmin,2))
if handles.withSurfaces==1&&showchat
    hold on
    contour(linspace(1,size(handles.volume,2),size(handles.submeshmin,1)),fliplr(linspace(1,size(handles.volume,1),size(handles.submeshmin,2))),flipud(handles.submeshmin'),[handles.pointer3dt(3),handles.pointer3dt(3)],'r');
    contour(linspace(1,size(handles.volume,2),size(handles.submeshmax,1)),fliplr(linspace(1,size(handles.volume,1),size(handles.submeshmax,2))),flipud(handles.submeshmax'),[handles.pointer3dt(3),handles.pointer3dt(3)],'g');
    hold off
end
global chatpointx chatpointy chatpointz chatpointradius chatpointsurf
showall=get(handles.showallpoints,'Value');
if handles.withPoints
if showall
    for pointnum=1:length(chatpointx)
        if chatpointz(pointnum)==handles.pointer3dt(3)
            hold on
            if chatpointsurf(pointnum)
                plot(chatpointy(pointnum),chatpointx(pointnum),'ro','MarkerFaceColor','red')
            else
                plot(chatpointy(pointnum),chatpointx(pointnum),'go','MarkerFaceColor','green')
            end
            ang=0:0.01:2*pi;
            xp=chatpointradius(pointnum)*cos(ang);
            yp=chatpointradius(pointnum)*sin(ang);
            plot(chatpointy(pointnum)+xp,chatpointx(pointnum)+yp,'m','LineWidth',2);
            hold off
        end
    end
else
pointnum=get(handles.chatpointnum,'Value')-1;
if pointnum>0&&chatpointz(pointnum)==handles.pointer3dt(3)
hold on
plot(chatpointy(pointnum),chatpointx(pointnum),'y+')
ang=0:0.01:2*pi;
xp=chatpointradius(pointnum)*cos(ang);
yp=chatpointradius(pointnum)*sin(ang);
plot(chatpointy(pointnum)+xp,chatpointx(pointnum)+yp,'m','LineWidth',2);
hold off
end
end
end

sp2 = subplot(2,2,2);
imagesc(sliceXZ, clims);
if handles.withCells==1
backim=cat(3,ones(size(sliceXZ)),ones(size(sliceXZ)),zeros(size(sliceXZ)));
hold on
im=imagesc(backim);
hold off
set(im,'AlphaData',0.25.*cellsXZ);
end
title('Slice XZ');
ylabel('X');xlabel('Z');
line([handles.pointer3dt(3) handles.pointer3dt(3)], [0 size(handles.volume,1)]);
line([0 size(handles.volume,3)], [handles.pointer3dt(1) handles.pointer3dt(1)]);
%set(allchild(gca),'ButtonDownFcn',@Subplot2_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot2_ButtonDownFcn'',gca,[],guidata(gcbo))');
if (handles.axis_equal == 1)
    axis image;
else
    axis normal;
end;
if handles.withSurfaces==1&&showchat
    hold on
    plot(handles.submeshmin(floor(handles.pointer3dt(2)/size(handles.volume,1)*size(handles.submeshmin,2)),:),linspace(1,size(handles.volume,1),size(handles.submeshmin,2)),'r');
    plot(handles.submeshmax(floor(handles.pointer3dt(2)/size(handles.volume,1)*size(handles.submeshmax,2)),:),linspace(1,size(handles.volume,1),size(handles.submeshmax,2)),'g');
    hold off
end
if handles.withPoints
if showall
    for pointnum=1:length(chatpointx)
        hold on
        if chatpointy(pointnum)==handles.pointer3dt(2)
            if chatpointsurf(pointnum)
                plot(chatpointz(pointnum),chatpointx(pointnum),'ro','MarkerFaceColor','red')
            else
                plot(chatpointz(pointnum),chatpointx(pointnum),'go','MarkerFaceColor','green')
            end
        end
        ang=acos((handles.pointer3dt(2)-chatpointy(pointnum))/chatpointradius(pointnum));
        yp=chatpointradius(pointnum)*sin(ang);
        if yp>1
            plot([chatpointz(pointnum) chatpointz(pointnum)],[chatpointx(pointnum)-yp chatpointx(pointnum)+yp],'m','LineWidth',2);
        end
        hold off
    end
else
if pointnum>0
hold on
if chatpointy(pointnum)==handles.pointer3dt(2)
plot(chatpointz(pointnum),chatpointx(pointnum),'y+')
end
ang=acos((handles.pointer3dt(2)-chatpointy(pointnum))/chatpointradius(pointnum));
yp=chatpointradius(pointnum)*sin(ang);
if yp>1
plot([chatpointz(pointnum) chatpointz(pointnum)],[chatpointx(pointnum)-yp chatpointx(pointnum)+yp],'m','LineWidth',2);
end
hold off
end
end
end

sp3 = subplot(2,2,3);
imagesc(sliceZY, clims);
if handles.withCells==1
backim=cat(3,ones(size(sliceZY)),ones(size(sliceZY)),zeros(size(sliceZY)));
hold on
im=imagesc(backim);
hold off
min(min(cellsZY))
set(im,'AlphaData',0.25.*cellsZY);
end
title('Slice ZY');
ylabel('Z');xlabel('Y');
line([0 size(handles.volume,2)], [handles.pointer3dt(3) handles.pointer3dt(3)]);
line([handles.pointer3dt(2) handles.pointer3dt(2)], [0 size(handles.volume,3)]);
%set(allchild(gca),'ButtonDownFcn',@Subplot3_ButtonDownFcn);
set(allchild(gca),'ButtonDownFcn','SliceBrowser(''Subplot3_ButtonDownFcn'',gca,[],guidata(gcbo))');
if (handles.axis_equal == 1)
    axis image;
else
    axis normal;
end;
if handles.withSurfaces==1&&showchat
    hold on
    plot(linspace(1,size(handles.volume,2),size(handles.submeshmin,1)),fliplr(handles.submeshmin(:,floor(handles.pointer3dt(1)/size(handles.volume,2)*size(handles.submeshmin,1)))),'r');
    plot(linspace(1,size(handles.volume,2),size(handles.submeshmax,1)),fliplr(handles.submeshmax(:,floor(handles.pointer3dt(1)/size(handles.volume,2)*size(handles.submeshmax,1)))),'g');
    hold off
end
if handles.withPoints
if showall
    for pointnum=1:length(chatpointx)
        hold on
        if chatpointx(pointnum)==handles.pointer3dt(1)
            if chatpointsurf(pointnum)
                plot(chatpointy(pointnum),chatpointz(pointnum),'ro','MarkerFaceColor','red')
            else
                plot(chatpointy(pointnum),chatpointz(pointnum),'go','MarkerFaceColor','green')
            end
        end
        ang=acos((handles.pointer3dt(1)-chatpointx(pointnum))/chatpointradius(pointnum));
        xp=chatpointradius(pointnum)*sin(ang);
        if xp>1
            plot([chatpointy(pointnum)-xp chatpointy(pointnum)+xp],[chatpointz(pointnum) chatpointz(pointnum)],'m','LineWidth',2);
        end
        hold off
    end
else
if pointnum>0
hold on
if chatpointx(pointnum)==handles.pointer3dt(1)
plot(chatpointy(pointnum),chatpointz(pointnum),'y+')
end
ang=acos((handles.pointer3dt(1)-chatpointx(pointnum))/chatpointradius(pointnum));
xp=chatpointradius(pointnum)*sin(ang);
if xp>1
plot([chatpointy(pointnum)-xp chatpointy(pointnum)+xp],[chatpointz(pointnum) chatpointz(pointnum)],'m','LineWidth',2);
end
hold off
end
end
end

function pointer3d_out = clipointer3d(pointer3d_in,vol_size)
pointer3d_out = pointer3d_in;
for p_id=1:4
    if (pointer3d_in(p_id) > vol_size(p_id))
        pointer3d_out(p_id) = vol_size(p_id);
    end;
    if (pointer3d_in(p_id) < 1)
        pointer3d_out(p_id) = 1;
    end;
end;


% --- Executes on button press in showchat.
function showchat_Callback(hObject, eventdata, handles)
% hObject    handle to showchat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showchat
plot3slices(hObject, handles);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');



% --- Executes on button press in fig2scroll.
function fig2scroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig2scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.last_axis_id = 3;
set(hObject,'Value',1);
set(handles.fig1scroll,'Value',0);
set(handles.fig3scroll,'Value',0);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on button press in fig2leftrightscroll.
function fig2leftrightscroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig2leftrightscroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fig3leftrightscroll.
function fig3leftrightscroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig3leftrightscroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fig1updownscroll.
function fig1updownscroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig1updownscroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fig2updownscroll.
function fig2updownscroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig2updownscroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fig3updownscroll.
function fig3updownscroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig3updownscroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fig3scroll.
function fig3scroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig3scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.last_axis_id = 1;
set(hObject,'Value',1);
set(handles.fig1scroll,'Value',0);
set(handles.fig2scroll,'Value',0);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on button press in fig1scroll.
function fig1scroll_Callback(hObject, eventdata, handles)
% hObject    handle to fig1scroll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.last_axis_id = 2;
set(hObject,'Value',1);
set(handles.fig2scroll,'Value',0);
set(handles.fig3scroll,'Value',0);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');



function chatpointx_Callback(hObject, eventdata, handles)
% hObject    handle to chatpointx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chatpointx as text
%        str2double(get(hObject,'String')) returns contents of chatpointx as a double


% --- Executes during object creation, after setting all properties.
function chatpointx_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chatpointx (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chatpointy_Callback(hObject, eventdata, handles)
% hObject    handle to chatpointy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chatpointy as text
%        str2double(get(hObject,'String')) returns contents of chatpointy as a double


% --- Executes during object creation, after setting all properties.
function chatpointy_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chatpointy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chatpointz_Callback(hObject, eventdata, handles)
% hObject    handle to chatpointz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chatpointz as text
%        str2double(get(hObject,'String')) returns contents of chatpointz as a double


% --- Executes during object creation, after setting all properties.
function chatpointz_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chatpointz (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function chatpointradius_Callback(hObject, eventdata, handles)
% hObject    handle to chatpointradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of chatpointradius as text
%        str2double(get(hObject,'String')) returns contents of chatpointradius as a double


% --- Executes during object creation, after setting all properties.
function chatpointradius_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chatpointradius (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in chatpointnum.
function chatpointnum_Callback(hObject, eventdata, handles)
% hObject    handle to chatpointnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns chatpointnum contents as cell array
%        contents{get(hObject,'Value')} returns selected item from chatpointnum
global chatpointx chatpointy chatpointz chatpointradius chatpointsurf
pointnum=get(hObject,'Value');
% if pointnum==length(cellstr(get(hObject,'String')))
%     set(handles.deletepoint,'Enable','on');
% else
%     set(handles.deletepoint,'Enable','off');
% end
pointnum=pointnum-1;
if pointnum>0
set(handles.chatpointx,'String',chatpointx(pointnum));
set(handles.chatpointy,'String',chatpointy(pointnum));
set(handles.chatpointz,'String',chatpointz(pointnum));
set(handles.chatpointradius,'String',chatpointradius(pointnum));
set(handles.topsurfpoint,'Value',chatpointsurf(pointnum));
set(handles.bottomsurfpoint,'Value',~chatpointsurf(pointnum));
else
    set(handles.chatpointx,'String','');
    set(handles.chatpointy,'String','');
    set(handles.chatpointz,'String','');
    set(handles.chatpointradius,'String','');
    set(handles.topsurfpoint,'Value',0);
    set(handles.bottomsurfpoint,'Value',0);
end
plot3slices(hObject, handles);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');



% --- Executes during object creation, after setting all properties.
function chatpointnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to chatpointnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in showallpoints.
function showallpoints_Callback(hObject, eventdata, handles)
% hObject    handle to showallpoints (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showallpoints
plot3slices(hObject, handles);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on button press in addpoint.
function addpoint_Callback(hObject, eventdata, handles)
% hObject    handle to addpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addpoint
global addpoint
if get(hObject,'Value')
addpoint=1;
else
addpoint=0;
end
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on scroll wheel click while the figure is in focus.
function SliceBrowserFigure_WindowScrollWheelFcn(hObject, eventdata, handles)
% hObject    handle to SliceBrowserFigure (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	VerticalScrollCount: signed integer indicating direction and number of clicks
%	VerticalScrollAmount: number of lines scrolled for each click
% handles    structure with handles and user data (see GUIDATA)
global chatpointradius
pointnum=get(handles.chatpointnum,'Value')-1;
if pointnum>0
radius=str2double(get(handles.chatpointradius,'String'))+eventdata.VerticalScrollCount;
set(handles.chatpointradius,'String',radius);
chatpointradius(pointnum)=radius;
plot3slices(hObject, handles);
end
guidata(hObject, handles);


% --- Executes on button press in deletepoint.
function deletepoint_Callback(hObject, eventdata, handles)
% hObject    handle to deletepoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global chatpointx chatpointy chatpointz chatpointradius chatpointsurf
%pointnum=get(handles.chatpointnum,'Value')-1
pointnum=length(chatpointx);
        if pointnum>0
            pointnum=pointnum+1;
            pointlist=get(handles.chatpointnum,'String');
            pointlist(pointnum)=[];
            set(handles.chatpointnum,'String',pointlist);
            set(handles.chatpointnum,'Value',pointnum-1);
            chatpointx(pointnum-1)=[];
            chatpointy(pointnum-1)=[];
            chatpointz(pointnum-1)=[];
            chatpointradius(pointnum-1)=[];
            chatpointsurf(pointnum-1)=[];
            if pointnum>2
                set(handles.chatpointx,'String',chatpointx(pointnum-2));
                set(handles.chatpointy,'String',chatpointy(pointnum-2));
                set(handles.chatpointz,'String',chatpointz(pointnum-2));
                set(handles.chatpointradius,'String',chatpointradius(pointnum-2))
                set(handles.topsurfpoint,'Value',chatpointsurf(pointnum-2));
                set(handles.bottomsurfpoint,'Value',~chatpointsurf(pointnum-2));
            else
                set(handles.chatpointx,'String','');
                set(handles.chatpointy,'String','');
                set(handles.chatpointz,'String','');
                set(handles.chatpointradius,'String','')
                set(handles.topsurfpoint,'Value',0)
                set(handles.bottomsurfpoint,'Value',0)
                set(handles.deletepoint,'Enable','off')
            end
        end
plot3slices(hObject, handles);
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on button press in topsurfpoint.
function topsurfpoint_Callback(hObject, eventdata, handles)
% hObject    handle to topsurfpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of topsurfpoint


% --- Executes on button press in bottomsurfpoint.
function bottomsurfpoint_Callback(hObject, eventdata, handles)
% hObject    handle to bottomsurfpoint (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of bottomsurfpoint


% --- Executes on button press in addtotop.
function addtotop_Callback(hObject, eventdata, handles)
% hObject    handle to addtotop (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addtotop
set(handles.addtobottom,'Value',~get(hObject,'Value'));
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');


% --- Executes on button press in addtobottom.
function addtobottom_Callback(hObject, eventdata, handles)
% hObject    handle to addtobottom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addtobottom
set(handles.addtotop,'Value',~get(hObject,'Value'));
guidata(hObject, handles);
set(hObject,'KeyPressFcn','SliceBrowser(''SliceBrowserFigure_KeyPressFcn'',gcf,[],guidata(gcbo))');

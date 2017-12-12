function varargout = loadSliceBrowser_old(varargin)
% LOADSLICEBROWSER_OLD MATLAB code for loadSliceBrowser_old.fig
%      LOADSLICEBROWSER_OLD, by itself, creates a new LOADSLICEBROWSER_OLD or raises the existing
%      singleton*.
%
%      H = LOADSLICEBROWSER_OLD returns the handle to a new LOADSLICEBROWSER_OLD or the handle to
%      the existing singleton*.
%
%      LOADSLICEBROWSER_OLD('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LOADSLICEBROWSER_OLD.M with the given input arguments.
%
%      LOADSLICEBROWSER_OLD('Property','Value',...) creates a new LOADSLICEBROWSER_OLD or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before loadSliceBrowser_old_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to loadSliceBrowser_old_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help loadSliceBrowser_old

% Last Modified by GUIDE v2.5 08-Mar-2016 20:39:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @loadSliceBrowser_old_OpeningFcn, ...
                   'gui_OutputFcn',  @loadSliceBrowser_old_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
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


% --- Executes just before loadSliceBrowser_old is made visible.
function loadSliceBrowser_old_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to loadSliceBrowser_old (see VARARGIN)

% Choose default command line output for loadSliceBrowser_old
handles.output = hObject;
global twostacks
twostacks=0;

movegui('northwest');
set(handles.loadedfile,'String','');
set(handles.xup,'String',1);
set(handles.yup,'String',1);
set(handles.zup,'String',1);
set(handles.smoothing,'String',20);
set(handles.imethod,'String',{'nearest';'linear';'cubic'});
set(handles.imethod,'Value',3);
set(handles.volumetoview,'String',{});


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes loadSliceBrowser_old wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = loadSliceBrowser_old_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loadfile.
function loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks
[filename,pathname] = uigetfile({'*.lsm';'*.tif'});
if isequal(filename,0)
   disp('User selected Cancel')
else
h = waitbar(0,'Please Wait... Loading File');
im=tiffread(fullfile(pathname, filename));
imstack=[];
im2stack=[];
even=0;
for i=1:length(im)
    if iscell(im(i).data)
        imstack=cat(3,imstack,im(i).data{1});
        if get(handles.twochannels,'Value')
            twostacks=1;
            im2stack=cat(3,im2stack,im(i).data{2});
        else
            twostacks=0;
        end
    else
        if get(handles.twochannels,'Value')
            twostacks=1;
            if even
                im2stack=cat(3,im2stack,im(i).data);
                even=0;
            else
                imstack=cat(3,imstack,im(i).data);
                even=1;
            end
        else
            twostacks=0;
            imstack=cat(3,imstack,im(i).data);
        end
    end
    waitbar(i/length(im),h);
end
handles.imstack=uint16(imstack);
handles.im2stack=uint16(im2stack);
%delete imstack im2stack
%clear imstack im2stack
imstack=[];
im2stack=[];
set(handles.loadedfile,'String',filename);
set(handles.volumetoview,'String',{'original'});
set(handles.volumetoview,'Value',1);
if get(handles.twochannels,'Value')
    set(handles.viewchannel2,'Enable','on');
else
    set(handles.viewchannel2,'Enable','off');
end
set(handles.viewslices,'Enable','on');
set(handles.upsample,'Enable','on');
delete(h)
guidata(hObject, handles);
end



function loadedfile_Callback(hObject, eventdata, handles)
% hObject    handle to loadedfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of loadedfile as text
%        str2double(get(hObject,'String')) returns contents of loadedfile as a double


% --- Executes during object creation, after setting all properties.
function loadedfile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadedfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in upsample.
function upsample_Callback(hObject, eventdata, handles)
% hObject    handle to upsample (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks
handles.supsampledimstack=handles.imstack;
handles.supsampledim2stack=handles.im2stack;
try
xup=str2double(get(handles.xup,'String'));
yup=str2double(get(handles.yup,'String'));
zup=str2double(get(handles.zup,'String'));
imethods=get(handles.imethod,'String');
imethod=imethods(get(handles.imethod,'Value'));
% imstack=handles.imstack;
% im2stack=handles.im2stack;
% save('temp_imstacks.mat','imstack','im2stack');
%delete imstack im2stack handles.im2stack
%clear imstack im2stack handles.im2stack
% imstack=[];
% im2stack=[];
if xup>0&&yup>0&&zup>0
if xup~=1||yup~=1||zup~=1
    size(handles.imstack)
    %try
        %delete handles.supsampledimstack handles.supsampledim2stack
        %clear handles.supsampledimstack handles.supsampledim2stack
        handles.supsampledimstack=int16([]);
        handles.supsampledim2stack=int16([]);
        [null, k] = flexinterpn_method(1, 1, imethod{1});
        %[bgridx,bgridy,bgridz]=meshgrid(single(1:1/xup:size(handles.imstack,2)),single(1:1/yup:size(handles.imstack,1)),single(1:1/zup:size(handles.imstack,3)));
        h = waitbar(0,'Please Wait... Upsampling Channel 1');
        try
            handles.upsampledimstack=flexinterpn(handles.imstack,[Inf,Inf,Inf;1,1,1;1/xup,1/yup,1/zup;size(handles.imstack,1),size(handles.imstack,2),size(handles.imstack,3)],k(:),1);
            %throw;
        catch
            %strcat('error upsampling channel 1: may need to compile flexinterpn on this computer; using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
            %handles.upsampledimstack=interp3(double(handles.imstack),min([xup,yup,zup]),imethod{1});
            w = warndlg(sprintf('Error upsampling channel 1: may need to compile flexinterpn on this computer.\nClick Ok to just using original volume instead.'));
            uiwait(w);
            handles.upsampledimstack=handles.imstack;
        end
        waitbar(.5,h);
        totalslice=size(handles.upsampledimstack,3);
        subd=5;
        quarterslice=floor(totalslice/subd);
        for i=1:subd-1
            handles.supsampledimstack(:,:,quarterslice*(i-1)+1:i*quarterslice)=uint16(handles.upsampledimstack(:,:,1:quarterslice));
            handles.upsampledimstack(:,:,1:quarterslice)=[];
        end
        handles.supsampledimstack(:,:,(subd-1)*quarterslice+1:totalslice)=uint16(handles.upsampledimstack(:,:,1:end));
        %delete handles.upsampledimstack
        %clear handles.upsampledimstack
        handles.upsampledimstack=[];
        size(handles.supsampledimstack)
        waitbar(1,h);
        delete(h);
        if twostacks
            h = waitbar(0,'Please Wait... Upsampling Channel 2');
            try
                handles.upsampledim2stack=flexinterpn(handles.im2stack,[Inf,Inf,Inf;1,1,1;1/xup,1/yup,1/zup;size(handles.im2stack,1),size(handles.im2stack,2),size(handles.im2stack,3)],k(:),1);
                %throw;
            catch
                %strcat('error upsampling channel 2: may need to compile flexinterpn on this computer; using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
                %handles.upsampledim2stack=interp3(double(handles.im2stack),min([xup,yup,zup]),imethod{1});
                w = warndlg(sprintf('Error upsampling channel 2: may need to compile flexinterpn on this computer.\nClick Ok to just using original volume instead.'));
                uiwait(w);
                handles.upsampledim2stack=handles.im2stack;
            end
            waitbar(.5,h);
            for i=1:subd-1
                handles.supsampledim2stack(:,:,quarterslice*(i-1)+1:i*quarterslice)=uint16(handles.upsampledim2stack(:,:,1:quarterslice));
                handles.upsampledim2stack(:,:,1:quarterslice)=[];
            end
            handles.supsampledim2stack(:,:,(subd-1)*quarterslice+1:totalslice)=uint16(handles.upsampledim2stack(:,:,1:end));
            %delete handles.upsampledim2stack
            %clear handles.upsampledim2stack
            handles.upsampledimstack=[];
            size(handles.supsampledim2stack)
            waitbar(1,h);
            delete(h);
        end
%     catch
%         strcat('error: may need to compile flexinterpn on this computer, using Matlab interp3 with a factor of ',min([xup,yup,zup]),' instead')
%         clear bgridx bgridy bgridz
%         memory
%         handles.newimstack=interp3(handles.imstack,min([xup,yup,zup]),imethod{1});
%     end
else
end
else
    error('x, y, and z factors must be >0')
end
class(handles.supsampledimstack)
class(handles.supsampledim2stack)
set(handles.volumetoview,'String',{'original','upsampled'});
set(handles.volumetoview,'Value',2);
set(handles.findcellbodies,'Enable','on');
guidata(hObject, handles);
catch errorObj
% If there is a problem, we display the error message
errordlg(getReport(errorObj,'extended','hyperlinks','off'),'Error');
handles.supsampledimstack=handles.imstack;
handles.supsampledim2stack=handles.im2stack;
class(handles.supsampledimstack)
class(handles.supsampledim2stack)
set(handles.volumetoview,'String',{'original','upsampled'});
set(handles.volumetoview,'Value',2);
set(handles.findcellbodies,'Enable','on');
guidata(hObject, handles);
end



function xup_Callback(hObject, eventdata, handles)
% hObject    handle to xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xup as text
%        str2double(get(hObject,'String')) returns contents of xup as a double


% --- Executes during object creation, after setting all properties.
function xup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yup_Callback(hObject, eventdata, handles)
% hObject    handle to yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yup as text
%        str2double(get(hObject,'String')) returns contents of yup as a double


% --- Executes during object creation, after setting all properties.
function yup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function zup_Callback(hObject, eventdata, handles)
% hObject    handle to zup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of zup as text
%        str2double(get(hObject,'String')) returns contents of zup as a double


% --- Executes during object creation, after setting all properties.
function zup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in processchat.
function processchat_Callback(hObject, eventdata, handles)
% hObject    handle to processchat (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global twostacks
[handles.VZminmesh,handles.VZmaxmesh]=processchat_nosave2(handles.imst2,str2double(get(handles.smoothing,'String')),handles.imst11);
'chat done'
set(handles.flattench1,'Enable','on');
if twostacks
    set(handles.flattench2,'Enable','on');
else
    set(handles.flattench2,'Enable','off');
end
guidata(hObject, handles);



function smoothing_Callback(hObject, eventdata, handles)
% hObject    handle to smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smoothing as text
%        str2double(get(hObject,'String')) returns contents of smoothing as a double


% --- Executes during object creation, after setting all properties.
function smoothing_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smoothing (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewslices.
function viewslices_Callback(hObject, eventdata, handles)
% hObject    handle to viewslices (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(handles.viewchannel1,'Value')
if get(handles.volumetoview,'Value')==1
    SliceBrowser(handles.imstack);
else
    if get(handles.volumetoview,'Value')==2
        try
            SliceBrowser(handles.supsampledimstack,handles.imst10_resized,handles.VZminmesh,handles.VZmaxmesh);
        catch
            try
            SliceBrowser(handles.supsampledimstack,handles.imst10_resized);    
            catch
            SliceBrowser(handles.supsampledimstack);
            end
        end
    else
        try
            SliceBrowser(handles.newimstack,handles.imst10_resized,handles.newVZminmesh,handles.newVZmaxmesh);
        catch
            try
            SliceBrowser(handles.newimstack,handles.imst10_resized);
            catch
            SliceBrowser(handles.newimstack);
            end
        end
    end
end
else
if get(handles.volumetoview,'Value')==1
    SliceBrowser(handles.im2stack);
else
    if get(handles.volumetoview,'Value')==2
        try
            SliceBrowser(handles.supsampledim2stack,handles.imst10_resized,handles.VZminmesh,handles.VZmaxmesh);
        catch
            try
            SliceBrowser(handles.supsampledim2stack,handles.imst10_resized);
            catch
            SliceBrowser(handles.supsampledim2stack);
            end
        end
    else
        try
            SliceBrowser(handles.newim2stack,handles.newVZminmesh,handles.newVZmaxmesh,handles.imst10_resized);
        catch
            try
            SliceBrowser(handles.newim2stack,handles.imst10_resized);
            catch
            SliceBrowser(handles.newim2stack);
            end
        end
    end
end
end
guidata(hObject, handles);


% --- Executes on button press in flattench1.
function flattench1_Callback(hObject, eventdata, handles)
% hObject    handle to flattench1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newimstack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 1');
for i=1:size(handles.supsampledimstack,1)
waitbar(i/size(handles.supsampledimstack,1),h);
for j=1:size(handles.supsampledimstack,2)
handles.newimstack(i,j,1:size(handles.supsampledimstack,3))=circshift(handles.supsampledimstack(i,j,1:size(handles.supsampledimstack,3)),floor(size(handles.supsampledimstack,3)/2-(handles.VZmaxmesh(j,i)+handles.VZminmesh(j,i))/2),3);
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Top Surface');
for i=1:size(handles.supsampledimstack,2)
waitbar(i/size(handles.supsampledimstack,2),h);
for j=1:size(handles.supsampledimstack,1)
handles.newVZminmesh(i,j)=handles.VZminmesh(i,j)+(floor(size(handles.supsampledimstack,3)/2-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Bottom Surface');
for i=1:size(handles.supsampledimstack,2)
waitbar(i/size(handles.supsampledimstack,2),h);
for j=1:size(handles.supsampledimstack,1)
handles.newVZmaxmesh(i,j)=handles.VZmaxmesh(i,j)+(floor(size(handles.supsampledimstack,3)/2-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);
set(handles.savefilech1,'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in savefilech1.
function savefilech1_Callback(hObject, eventdata, handles)
% hObject    handle to savefilech1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.tif'});
for K=1:length(handles.newimstack(1, 1, :))
imwrite(handles.newimstack(:, :, K), fullfile(pathname, filename), 'WriteMode', 'append', 'Compression','none');
end



% --- Executes on selection change in imethod.
function imethod_Callback(hObject, eventdata, handles)
% hObject    handle to imethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns imethod contents as cell array
%        contents{get(hObject,'Value')} returns selected item from imethod


% --- Executes during object creation, after setting all properties.
function imethod_CreateFcn(hObject, eventdata, handles)
% hObject    handle to imethod (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in twochannels.
function twochannels_Callback(hObject, eventdata, handles)
% hObject    handle to twochannels (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of twochannels


% --- Executes on selection change in volumetoview.
function volumetoview_Callback(hObject, eventdata, handles)
% hObject    handle to volumetoview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns volumetoview contents as cell array
%        contents{get(hObject,'Value')} returns selected item from volumetoview


% --- Executes during object creation, after setting all properties.
function volumetoview_CreateFcn(hObject, eventdata, handles)
% hObject    handle to volumetoview (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in viewchannel1.
function viewchannel1_Callback(hObject, eventdata, handles)
% hObject    handle to viewchannel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of viewchannel1
global twostacks
if get(hObject,'Value')
    if twostacks
        set(handles.viewchannel2,'Value',0)
    end
else
    set(handles.viewchannel1,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in viewchannel2.
function viewchannel2_Callback(hObject, eventdata, handles)
% hObject    handle to viewchannel2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of viewchannel2
global twostacks
if get(hObject,'Value')
    if twostacks
        set(handles.viewchannel1,'Value',0)
    end
else
    set(handles.viewchannel2,'Value',1)
end
guidata(hObject, handles);


% --- Executes on button press in flattench2.
function flattench2_Callback(hObject, eventdata, handles)
% hObject    handle to flattench2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.newim2stack=[];
handles.newVZminmesh=[];
handles.newVZmaxmesh=[];
h = waitbar(0,'Please Wait... Flattening Channel 2');
for i=1:size(handles.supsampledim2stack,1)
waitbar(i/size(handles.supsampledim2stack,1),h);
for j=1:size(handles.supsampledim2stack,2)
handles.newim2stack(i,j,1:size(handles.supsampledim2stack,3))=circshift(handles.supsampledim2stack(i,j,1:size(handles.supsampledim2stack,3)),floor(size(handles.supsampledim2stack,3)/2-(handles.VZmaxmesh(j,i)+handles.VZminmesh(j,i))/2),3);
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Top Surface');
for i=1:size(handles.supsampledimstack,2)
waitbar(i/size(handles.supsampledim2stack,2),h);
for j=1:size(handles.supsampledimstack,1)
handles.newVZminmesh(i,j)=handles.VZminmesh(i,j)+(floor(size(handles.supsampledimstack,3)/2-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
end
end
delete(h);
h = waitbar(0,'Please Wait... Flattening Bottom Surface');
for i=1:size(handles.supsampledimstack,2)
waitbar(i/size(handles.supsampledim2stack,2),h);
for j=1:size(handles.supsampledimstack,1)
handles.newVZmaxmesh(i,j)=handles.VZmaxmesh(i,j)+(floor(size(handles.supsampledimstack,3)/2-(handles.VZmaxmesh(i,j)+handles.VZminmesh(i,j))/2));
end
end
delete(h);
set(handles.volumetoview,'String',{'original','upsampled','flattened'});
set(handles.volumetoview,'Value',3);
set(handles.savefilech2,'Enable','on');
guidata(hObject, handles);


% --- Executes on button press in savefilech2.
function savefilech2_Callback(hObject, eventdata, handles)
% hObject    handle to savefilech2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uiputfile({'*.tif'});
for K=1:length(handles.newim2stack(1, 1, :))
imwrite(handles.newim2stack(:, :, K), fullfile(pathname, filename), 'WriteMode', 'append', 'Compression','none');
end



function errorbox_Callback(hObject, eventdata, handles)
% hObject    handle to errorbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of errorbox as text
%        str2double(get(hObject,'String')) returns contents of errorbox as a double


% --- Executes during object creation, after setting all properties.
function errorbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in findcellbodies.
function findcellbodies_Callback(hObject, eventdata, handles)
% hObject    handle to findcellbodies (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.processchat,'Enable','on');
clear imst2 handles.imst2 imst3 imst4 imst5 imst6 imst7 imst8 imst9 imst10 handles.imst11 handles.imst10_resized
% imst2=uint8(smooth3(imstack,'gaussian',1));
h = waitbar(0,'Please Wait... Finding Cell Bodies');
for i=1:size(handles.supsampledimstack,3)
imst2(:,:,i)=imresize(uint8(handles.supsampledimstack(:,:,i)),0.5);
imst3(:,:,i)=bwareaopen(imst2(:,:,i)>200,10);
imst4(:,:,i)=bwareaopen(imst3(:,:,i),800);
imst5(:,:,i)=imst3(:,:,i).*imcomplement(imst4(:,:,i));
imst6(:,:,i)=bwdist(imcomplement(imst5(:,:,i)));
waitbar(i/size(handles.supsampledimstack,3),h);
end
imst7=(single(smooth3(imst6>3,'gaussian',9)>0).*imst6);
imst8=permute(imst7,[3 2 1]);
imst9=imst8;
delete(h);
h = waitbar(0,'Please Wait... Smoothing in Z');
for j=1:10
for i=1:size(imst8,1)
imst9(:,:,i)=imgaussfilt(imst9(:,:,i),1);
end
waitbar(j/10,h);
end
imst10=permute(uint8(imcomplement(smooth3(imst9>0.25,'gaussian',5)>0)),[3 2 1]);
handles.imst11=imst10.*imst2;
handles.imst2=imst2;
for i=1:size(imst10,3)
handles.imst10_resized(:,:,i)=imresize(imcomplement(255.*imst10(:,:,i)),2);
end
delete(h);
guidata(hObject, handles);

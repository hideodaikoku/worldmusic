function varargout = songcomparison_gui(varargin)
% SONGCOMPARISON_GUI MATLAB code for songcomparison_gui.fig
%      SONGCOMPARISON_GUI, by itself, creates a new SONGCOMPARISON_GUI or raises the existing
%      singleton*.
%
%      H = SONGCOMPARISON_GUI returns the handle to a new SONGCOMPARISON_GUI or the handle to
%      the existing singleton*.
%
%      SONGCOMPARISON_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SONGCOMPARISON_GUI.M with the given input arguments.
%
%      SONGCOMPARISON_GUI('Property','Value',...) creates a new SONGCOMPARISON_GUI or raises
%      the existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before songcomparison_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to songcomparison_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help songcomparison_gui

% Last Modified by GUIDE v2.5 14-Dec-2018 15:26:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @songcomparison_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @songcomparison_gui_OutputFcn, ...
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

% --- Executes just before songcomparison_gui is made visible.
function songcomparison_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to songcomparison_gui (see VARARGIN)

% Choose default command line output for songcomparison_gui
handles.output = hObject;

load('temporaryData.mat');
handles.firstOrder_Num = firstOrder_Num;
handles.secondOrder_Num = secondOrder_Num;
handles.results_similarity = results_similarity;
handles.results_preference = results_preference;

handles.sliderSimilarity = 50;
handles.sliderPreference = 50;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes songcomparison_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = songcomparison_gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigurejFrame = get(handle(gcf),'JavaFrame'); FigurejFrame.setMaximized(true);
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbuttonNext.
function pushbuttonNext_Callback(hObject, eventdata, handles)
% hObject    handle to pushbuttonNext (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sliderSimilarity = handles.sliderSimilarity;
sliderPreference = handles.sliderPreference;
% append VAS result
columnNum = handles.firstOrder_Num;
rowNum = handles.secondOrder_Num;

if handles.secondOrder_Num > handles.firstOrder_Num
    columnNum = handles.secondOrder_Num;
    rowNum = handles.firstOrder_Num;
end

handles.results_similarity(columnNum,rowNum) = sliderSimilarity;
handles.results_preference(columnNum,rowNum) = sliderPreference;
results_similarity = handles.results_similarity;
results_preference = handles.results_preference;
save('temporaryData1.mat','results_similarity','results_preference');
close(gcf);

% --------------------------------------------------------------------
% --- Executes on slider movement.
function sliderSimilarity_Callback(hObject, eventdata, handles)
% hObject    handle to sliderSimilarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.sliderSimilarity = get(hObject,'Value');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function sliderSimilarity_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderSimilarity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function sliderPreference_Callback(hObject, eventdata, handles)
% hObject    handle to sliderPreference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.sliderPreference = get(hObject,'Value');
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function sliderPreference_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sliderPreference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
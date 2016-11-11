function varargout = LIPRAS(varargin)
%LIPRAS MATLAB code file for LIPRAS.fig
%      LIPRAS, by itself, creates a new LIPRAS or raises the existing
%      singleton*.
%
%      H = LIPRAS returns the handle to a new LIPRAS or the handle to
%      the existing singleton*.
%
%      LIPRAS('Property','Value',...) creates a new LIPRAS using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to LIPRAS_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      LIPRAS('CALLBACK') and LIPRAS('CALLBACK',hObject,...) call the
%      local function named CALLBACK in LIPRAS.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help LIPRAS

% Last Modified by GUIDE v2.5 11-Nov-2016 14:12:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @LIPRAS_OpeningFcn, ...
                   'gui_OutputFcn',  @LIPRAS_OutputFcn, ...
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


function LIPRAS_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for LIPRAS
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes LIPRAS wait for user response (see UIRESUME)
% uiwait(handles.figure1);


function varargout = LIPRAS_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;

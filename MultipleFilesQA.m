function varargout = MultipleFilesQA(varargin)
% MULTIPLEFILESQA MATLAB code for MultipleFilesQA.fig
%      MULTIPLEFILESQA, by itself, creates a new MULTIPLEFILESQA or raises the existing
%      singleton*.
%
%      H = MULTIPLEFILESQA returns the handle to a new MULTIPLEFILESQA or the handle to
%      the existing singleton*.
%
%      MULTIPLEFILESQA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MULTIPLEFILESQA.M with the given input arguments.
%
%      MULTIPLEFILESQA('Property','Value',...) creates a new MULTIPLEFILESQA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MultipleFilesQA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MultipleFilesQA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MultipleFilesQA

% Last Modified by GUIDE v2.5 30-Apr-2015 14:24:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MultipleFilesQA_OpeningFcn, ...
                   'gui_OutputFcn',  @MultipleFilesQA_OutputFcn, ...
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


% --- Executes just before MultipleFilesQA is made visible.
function MultipleFilesQA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MultipleFilesQA (see VARARGIN)

% Choose default command line output for MultipleFilesQA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MultipleFilesQA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MultipleFilesQA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in create_bundle.
function create_bundle_Callback(hObject, eventdata, handles)
% hObject    handle to create_bundle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


DIRECTORYNAME = uigetdir('', 'Pick a directory');

FILE_LISTING = dir(DIRECTORYNAME);

%organize the files in a timewise fashion, depending on the serial date
%number of the file. This value is locale-dependent, but should represent
%the time it was created
[sx,sx]=sort([FILE_LISTING.datenum]);
FILE_LISTING=FILE_LISTING(sx);

[NumFilesinFolder NotUsed] = size(FILE_LISTING);


ii = 1;

% get those file_names in that folder that have a .dlg extension
for hh = 1:NumFilesinFolder
   
    if length(FILE_LISTING(hh).name) >= 4
        
        
        if FILE_LISTING(hh).name(end-3:end) == '.dlg'
%             fprintf('working \n')
            file_names{ii} = FILE_LISTING(hh).name;
            
            file_names_path{ii} = fullfile(DIRECTORYNAME, file_names{ii});
                
            ii = ii+1;
            
        end
    end
    
end


% determine how many files do we have
num_files = length(file_names_path);

All_files = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file
All_header = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file

% here we load all the files

for jj = 1: num_files
    
   All_files{jj} = import_file(file_names_path{jj});
   All_header{jj} = import_header(file_names_path{jj});
   All_header{jj}{7} = file_names{jj}(1); % determine if it's Bank A or B
end

% zeroincluded = 0; if step-and-shoot is choosen

if All_header{1}{2}(1:4)=='STEP'

    zeroincluded = 0; % for step-and-shoot
else
    zeroincluded = 1; % Dynamic movement
end

% work on the loaded files, do all the calculations


curr_pos = cell(1, num_files);
leaf_error = cell(1, num_files); % planned - actual position
leaf_RMS_error = cell(1, num_files); % leaf RMS error
bank_RMS_error = cell(1, num_files); % mean/bank RMS error for a given bank
th_percentile  = cell(1, num_files);
bank_th_percentile  = cell(1, num_files);
mean_leaf_error  = cell(1, num_files);
variance = cell(1, num_files);

% avg_gantry_speed = cell(1, num_files);
% gantry_angle = cell(1, num_files);

% leaf_speeds = cell(1, num_files);
% mean_leaf_speeds = cell(1, num_files);
% max_leaf_speeds = cell(1, num_files);

% beam_on_time = cell(1, num_files);

% zeroincluded = 0;

for ll = 1:num_files
    
%     [num_rows notUsed] = size(All_files{ll});
    
    [curr_pos{ll}, leaf_error{ll}, leaf_RMS_error{ll}, bank_RMS_error{ll}, th_percentile{ll}, ...
        bank_th_percentile{ll}, mean_leaf_error{ll}, variance{ll}] = ...
        LeafError(All_files{ll}, zeroincluded, All_header{ll}{7}); % Results are in cm
   
%     [leaf_speeds{ll}, mean_leaf_speeds{ll}, max_leaf_speeds{ll}] = ...
%         DynoCompute(All_files{ll}, All_header{ll}{7}); % in mm/100
%     [avg_gantry_speed{ll} gantry_angle{ll}] = GantryCompute(All_files{ll}); % in mm * sec^-1, in deg/10
    
%     [beam_on_time{ll}] = BeamOn(All_files{ll}); % in sec
 
end

% calculation of Trends of Errors and Statistical Analysis
% Here we orgainze the RMS_error and variance in an ordered list, so that
% each leaf corresponds to a column

RMS_error_list = zeros(num_files/2, 120);

variance_list = zeros(num_files/2, 120);

for jj = 1:2:num_files
    
%     RMS_error((jj+1)/2) = (bank_RMS_error{jj}+bank_RMS_error{jj+1}) / 2
    
    RMS_error_list((jj+1)/2,1:60) = leaf_RMS_error{jj};
    RMS_error_list((jj+1)/2,61:120) = leaf_RMS_error{jj+1};
    
    variance_list((jj+1)/2,1:60) = variance{jj};
    variance_list((jj+1)/2,61:120) = variance{jj+1};
    
end    

% put the useful data into the workspace
handles.DIRECTORYNAME = DIRECTORYNAME;
handles.FILE_LISTING = FILE_LISTING;

handles.num_files = num_files;
handles.bank_RMS_error = bank_RMS_error;
handles.bank_th_percentile = bank_th_percentile;


handles.RMS_error_list = RMS_error_list;
handles.variance_list = variance_list;

% click on Cancel if you don't want to save it
currentFolder = pwd;

cd(DIRECTORYNAME)

uisave

cd(currentFolder)

fprintf('Bundle loaded\n')

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in load_bundle.
function load_bundle_Callback(hObject, eventdata, handles)
% hObject    handle to load_bundle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% if you add a new Button, this section needs to be modified !!!!!
% check if this actually works
handles2 = handles;
hObject2 = hObject;
uiopen('load')

handles2.DIRECTORYNAME = handles.DIRECTORYNAME;
handles2.FILE_LISTING = handles.FILE_LISTING;
handles2.num_files = handles.num_files;
handles2.bank_RMS_error = handles.bank_RMS_error;
handles2.bank_th_percentile = handles.bank_th_percentile;
handles2.RMS_error_list = handles.RMS_error_list;
handles2.variance_list = handles.variance_list;
% handles.create_bundle = create_bundle_tmp;
% handles.output = output_tmp

clear handles
handles = handles2
hObject = hObject2;

fprintf('Bundle loaded\n')

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in plot_error.
function plot_error_Callback(hObject, eventdata, handles)
% hObject    handle to plot_error (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
subplot(1,2,1)
hold all

xx = 0.5:0.5:handles.num_files/2;
xx = round(xx);

plot(xx,cell2mat(handles.bank_RMS_error) ,'r+')
ylabel('mean RMS error (mm)')

% 95th percentile error

subplot(1,2,2)
hold all

plot(xx,cell2mat(handles.bank_th_percentile) ,'r+')
ylim([0 2])
ylabel('95th percentile (mm)')




% --- Executes on button press in trends.
function trends_Callback(hObject, eventdata, handles)
% hObject    handle to trends (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Here do a simple fitting of y=a*x+b for each leaf

xx = 1:handles.num_files/2;

fitresult_RMS = zeros(1, 120);
fitresult_RMS_con = zeros(1, 120);

fitresult_var = zeros(1, 120);
fitresult_var_con = zeros(1, 120);
% fitresult_RMS = cell(1, 120);
% gof_RMS = cell(1, 120);


for hh = 1:120

    %create least squares fit
    [xData, yData] = prepareCurveData(xx, handles.RMS_error_list(:, hh));
    %Set up fittype and options.
    ft = fittype( 'poly1' );
    %Fit model to data.
    fitresult = fit( xData, yData, ft); %, opts )

    aa = coeffvalues(fitresult);
    bb = confint(fitresult,.68);

    fitresult_RMS(1,hh) = aa(1);
    fitresult_RMS_con(1,hh) = abs(aa(1)-bb(1));

    % fitresult(2,hh) = aa(2);

    %create least squares fit
    [xData, yData] = prepareCurveData(xx, handles.variance_list(:, hh));
    %Set up fittype and options.
    % ft = fittype( 'poly1' );
    %Fit model to data.
    fitresult = fit( xData, yData, ft); %, opts )

    aa = coeffvalues(fitresult);
    bb = confint(fitresult,.68);

    fitresult_var(1,hh) = aa(1);
    fitresult_var_con(1,hh) = abs(aa(1)-bb(1));
    % fitresult(2,hh) = aa(2);


end

%
figure
subplot(2,1,1)
errorbar(fitresult_var,fitresult_var_con)
legend('Slope of Variances')
ylabel('Slope of errors')
xlabel('Leaf Number')
subplot(2,1,2)
errorbar(fitresult_RMS,fitresult_RMS_con,'r')
xlabel('Leaf Number')
ylabel('Slope of errors')
legend('Slope of RMS Errors')


% --- Executes on button press in RMS_leafwise.
function RMS_leafwise_Callback(hObject, eventdata, handles)
% hObject    handle to RMS_leafwise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
mesh(handles.RMS_error_list)
xlabel('Leaf Number')
ylabel('DynaLog Files')
zlabel('RMS Error')
% ylim([0 Inf])


% --- Executes on button press in var_leafwise.
function var_leafwise_Callback(hObject, eventdata, handles)
% hObject    handle to var_leafwise (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
mesh(handles.variance_list)
xlabel('Leaf Number')
ylabel('DynaLog Files')
zlabel('Variance')


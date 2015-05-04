function varargout = SingleFileQA(varargin)
% SINGLEFILEQA MATLAB code for SingleFileQA.fig
%      SINGLEFILEQA, by itself, creates a new SINGLEFILEQA or raises the existing
%      singleton*.
%
%      H = SINGLEFILEQA returns the handle to a new SINGLEFILEQA or the handle to
%      the existing singleton*.
%
%      SINGLEFILEQA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SINGLEFILEQA.M with the given input arguments.
%
%      SINGLEFILEQA('Property','Value',...) creates a new SINGLEFILEQA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SingleFileQA_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SingleFileQA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SingleFileQA

% Last Modified by GUIDE v2.5 30-Apr-2015 20:54:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SingleFileQA_OpeningFcn, ...
                   'gui_OutputFcn',  @SingleFileQA_OutputFcn, ...
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


% --- Executes just before SingleFileQA is made visible.
function SingleFileQA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SingleFileQA (see VARARGIN)

% Choose default command line output for SingleFileQA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SingleFileQA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SingleFileQA_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% str2double(get(handles.scaling_factor_edit,'String'))

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in create_bundle.
function create_bundle_Callback(hObject, eventdata, handles)
% hObject    handle to create_bundle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

FILENAME = cell(1, 2); % only for the single analysis

[FILENAME_tmp, DIRECTORYNAME, filterindex] = uigetfile({'*.dlg','Dynalog Files (*.dlg)';'*.bin', 'Trajectory files (*.bin)'},...
    'Pick a file',...
    'MultiSelect','on');

switch filterindex
       
    case 1 %.dlg files

        fprintf('dlg\n')
        if FILENAME_tmp(1) == 'A'
            FILENAME{1} = FILENAME_tmp;
            FILENAME{2} = FILENAME{1};
            FILENAME{2}(1) = 'B';
        elseif FILENAME_tmp(1) == 'B'
            FILENAME{2} = FILENAME_tmp;
            FILENAME{1} = FILENAME{2};
            FILENAME{1}(1) = 'A';
        else
            fprintf('Please choose a valide Dynalog file\n')
        end

        file_names_path = {fullfile(DIRECTORYNAME, FILENAME{1}) fullfile(DIRECTORYNAME, FILENAME{2})};

        num_files = 2; % only for single Dynalog file
        
        All_files = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file
        All_header = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file

        
        % here we load all the files

        for jj = 1: num_files

           All_files{jj} = import_file(file_names_path{jj}); 
           All_header{jj} = import_header(file_names_path{jj});
           All_header{jj}{7} = FILENAME{jj}(1);      % determine if it's Bank A or B

        end
        
        
        
        
    case 2 %.bin file
        
        fprintf('bin\n')
        
        FILENAME = FILENAME_tmp;
        file_names_path = fullfile(DIRECTORYNAME, FILENAME)
        
        num_files = 1;
        
        %%%%%%% !!!!!!!! implement a code, where you can run the python
        %%%%%%% code on the 'file_names_path', 
        %%%%%%% DONE, though in a very basic way, but done
        
       [actual, expected] = MatPy(file_names_path);
       
       curr_pos{1} = expected(:, 18:77).*10;
       curr_pos{2} = expected(:, 78:137).*10;

       planned_pos{1} = actual(:, 18:77).*10;
       planned_pos{2} = actual(:, 78:137).*10;

       
       All_files = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file
       All_header = cell(1,num_files); % create an array, each element corresponds to one Dynalog raw file

        
        % here we load all the files

       for jj = 1: num_files*2

          All_files{jj} = curr_pos{jj} - planned_pos{jj}; %more like leaf error
%           All_header{jj} = import_header(file_names_path{jj});
%           All_header{jj}{7} = FILENAME{jj}(1);      % determine if it's Bank A or B

       end

        
end

%  -- work on the loaded files

% determine how many files do we have
num_files = 2;

% set up variables
leaf_error = cell(1, num_files); % planned - actual position
leaf_RMS_error = cell(1, num_files); % leaf RMS error
bank_RMS_error = cell(1, num_files); % mean/bank RMS error for a given bank
th_percentile  = cell(1, num_files);
bank_th_percentile  = cell(1, num_files);
mean_leaf_error  = cell(1, num_files);


switch filterindex
    
    case 1 
        %if we've chosen a Step-and-Shoot file, this should be checked (not by user)
        % zeroincluded = 0; if step-and-shoot is choosen

        if All_header{1}{2}(1:4)=='STEP'

            zeroincluded = 0; % for step-and-shoot
        else
            zeroincluded = 1; % Dynamic movement
        end
        
        %set up variables that already exist in case 2
        curr_pos = cell(1, num_files);
        
        for ll = 1:num_files


            [curr_pos{ll}, leaf_error{ll}, leaf_RMS_error{ll}, bank_RMS_error{ll}, th_percentile{ll}, ...
                bank_th_percentile{ll}, mean_leaf_error{ll}, variance{ll}] = ...
                LeafError(All_files{ll}, zeroincluded, All_header{ll}{7}, filterindex); % Results are in mm

        %     [leaf_speeds{ll}, mean_leaf_speeds{ll}, max_leaf_speeds{ll}] = ...
        %         DynoCompute(All_files{ll}, All_header{ll}{7}); % in mm/100
        %     [avg_gantry_speed{ll} gantry_angle{ll}] = GantryCompute(All_files{ll}); % in mm * sec^-1, in deg/10

        %             [beam_on_time{ll}] = BeamOn(All_files{ll}); % in sec
        end
        
    case 2
       %% 
        zeroincluded = 1;
        
        for ll = 1:num_files

            

            [AlreadyHave, leaf_error{ll}, leaf_RMS_error{ll}, bank_RMS_error{ll}, th_percentile{ll}, ...
                bank_th_percentile{ll}, mean_leaf_error{ll}, variance{ll}] = ...
                LeafError(All_files{ll}, zeroincluded, 'A' , filterindex); % Results are in mm

        %     [leaf_speeds{ll}, mean_leaf_speeds{ll}, max_leaf_speeds{ll}] = ...
        %         DynoCompute(All_files{ll}, All_header{ll}{7}); % in mm/100
        %     [avg_gantry_speed{ll} gantry_angle{ll}] = GantryCompute(All_files{ll}); % in mm * sec^-1, in deg/10

        %             [beam_on_time{ll}] = BeamOn(All_files{ll}); % in sec
        end
%%        
end



        
       
%        for ll = 1:num_files
% 
%             leaf_error{ll} = curr_pos{ll} - planned_pos{ll};
% 
% 
%             if ll == 1
%                 leaf_error{ll} = -leaf_error{ll};
%             %     fprintf('B\n')
%             else
%             %     fprintf('A\n')
%             end
% 
% 
%             leaf_RMS_error{ll} = rms(leaf_error{ll}); % in mm
% 
% 
%             mean_leaf_error{ll} = mean(leaf_error{ll}); % in mm
% 
%             variance{ll} = var(leaf_error{ll});
% 
% 
%             for kk = 1:60 % 60 MLC leaves         
% 
% 
%                 th_percentile{ll}(1,kk) = prctile(abs(leaf_error{ll}(:,kk)),95); % in mm
% 
%             end
% 
%             bank_th_percentile{ll} = prctile(abs(leaf_error{ll}(:)),95); % in mm
% 
%             bank_RMS_error{ll} = mean(leaf_RMS_error{ll}); % in mm
% 
%        end
% 
%         
%         
% end


% put the useful data into the workspace
handles.DIRECTORYNAME = DIRECTORYNAME;
handles.curr_pos = curr_pos;
handles.leaf_error = leaf_error;
handles.leaf_RMS_error = leaf_RMS_error;

handles.num_files = num_files;
handles.bank_RMS_error = bank_RMS_error;
handles.bank_th_percentile = bank_th_percentile;

handles.pp = 0;


handles.th_percentile = th_percentile;
% handles.variance_list = variance_list;

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
handles2.curr_pos = handles.curr_pos;
handles2.leaf_error = handles.leaf_error;
handles2.num_files = handles.num_files;
handles2.bank_RMS_error = handles.bank_RMS_error;
handles2.bank_th_percentile = handles.bank_th_percentile;
handles2.leaf_RMS_error = handles.leaf_RMS_error;
handles2.th_percentile = handles.th_percentile;
handles2.pp = handles.pp;
% handles.output = output_tmp

clear handles
handles = handles2;
hObject = hObject2;

setappdata(0,'mapData',handles);

fprintf('Bundle loaded\n')

% Update handles structure
guidata(hObject, handles);



% --- Executes on button press in curr_position_button.
function curr_position_button_Callback(hObject, eventdata, handles)
% hObject    handle to curr_position_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
pcolor(handles.curr_pos{2*handles.pp+1})
shading flat
colorbar
title('True B position [mm]')
xlabel('Leaf Number')
ylabel('Record Number')


% --- Executes on button press in leaf_error_button.
function leaf_error_button_Callback(hObject, eventdata, handles)
% hObject    handle to leaf_error_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
pcolor(abs(handles.leaf_error{2*handles.pp+1}))
shading flat
colorbar
title('Leaf Error position [mm]')
xlabel('Leaf Number')
ylabel('Record Number')


% --- Executes on button press in threshold_button.
function threshold_button_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

threshold = ...
    (str2double(get(handles.threshold_input,'String'))) * 10;

ii = find(handles.leaf_RMS_error{2*handles.pp+1}>=threshold);

if size(ii) ~= 0

    xx = zeros(1, 60);
    xx(ii) = 1;
    figure
    plot(xx ,'r.');
    str = sprintf('Leaves that exceed the %f mm threshold during delivery',threshold);
    title(str);
    xlabel('Leaf number')
    ylabel('(1 = threshold exceeded, 0 = below threshold)')
    xlim([0 60])

else
    
    fprintf('No steps exceeded the given threshold\n')

end


% --- Executes on button press in tab_RMS_th_button.
function tab_RMS_th_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab_RMS_th_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Button show Error RMS Data in a table

pp = handles.pp;

% create the data
d = [handles.bank_th_percentile{2*pp+1} handles.bank_th_percentile{2*pp+2}; ...
    handles.bank_RMS_error{2*pp+1} handles.bank_RMS_error{2*pp+2}; ...
    max(handles.leaf_RMS_error{2*pp+1}) max(handles.leaf_RMS_error{2*pp+2});...
    handles.leaf_RMS_error{2*pp+1}' handles.leaf_RMS_error{2*pp+2}'];

% Create the column and row names in cell arrays 


cnames = {'Bank A','Bank B'};

for rr = 1:60
    leaves_rows{rr} = num2str(rr);
end

rnames = {'95th percentile','Average RMS','Maximum ',leaves_rows{:}};

f = figure;%('Position',[440 500 461 146]);

% Create the uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,...
            'RowName',rnames);



% --- Executes on button press in RMS_th_button.
function RMS_th_button_Callback(hObject, eventdata, handles)
% hObject    handle to RMS_th_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[num_rows notUsed] = size(handles.curr_pos{2*handles.pp+1});

time = 0:0.05:(num_rows-1)*0.05;

figure
% Error RMS Plot
subplot(2,1,1)
plot(handles.leaf_RMS_error{2*handles.pp+1} )
hold on
plot(handles.leaf_RMS_error{2*handles.pp+2} ,'r')
title('Error RMS Plot')
ylabel('RMS Error (mm)')
xlabel('Leaf Number')

% 95th Percentile Plot
subplot(2,1,2)
plot(handles.th_percentile{2*handles.pp+1} )
hold on
plot(handles.th_percentile{2*handles.pp+2} ,'r')
title('95th Percentile Error')
ylabel('95th Error (mm)')
xlabel('Leaf Number')


% --- Executes on button press in error_hist_button.
function error_hist_button_Callback(hObject, eventdata, handles)
% hObject    handle to error_hist_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure
xx = abs(nonzeros(handles.leaf_error{2*handles.pp+1}));
edges = [0:0.5:10]+0.25;
h = hist(xx,edges);
bar(edges,h,'hist')
title('Error Histogram Plot')
xlabel('Leaf Error (mm)')
ylabel('Number of counts')
set(gca,'ygrid','on')


% --- Executes on button press in tab_error_hist_button.
function tab_error_hist_button_Callback(hObject, eventdata, handles)
% hObject    handle to tab_error_hist_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


xx = abs(nonzeros(handles.leaf_error{2*handles.pp+1}));
edges = [0:0.5:10]+0.25;


N_counts = hist(xx,edges);

Bin_no = 1:1:length(edges);

sum_counts = sum(N_counts);
for jj = 1:length(edges)
    Percent(jj) = N_counts(jj)/sum_counts * 100;
    
    if jj == 1 
        Percent_sum(jj) = Percent(jj);
    else
        Percent_sum(jj) = Percent_sum(jj-1)+Percent(jj);
    end
        
end
 
% create the data
d = [Bin_no', N_counts', Percent', Percent_sum'];


% Create the column and row names in cell arrays 
cnames = {'Bin no'; '# of counts'; 'Percent'; 'Percent Sum'};


% rnames are in cm
rnames = {'0 - < 0.050 (cm)',...
    '0.050 - < 0.10',...
    '0.10 - < 0.150',...
    '0.150 - < 0.20',...
    '0.20 - < 0.250',...
    '0.250 - < 0.300',...
    '0.300 - < 0.350',...
    '0.350 - < 0.400',...
    '0.400 - < 0.450',...
    '0.450 - < 0.500',...
    '0.500 - < 0.550',...
    '0.550 - < 0.600',...
    '0.600 - < 0.650',...
    '0.650 - < 0.700',...
    '0.700 - < 0.750',...
    '0.750 - < 0.800',...
    '0.800 - < 0.850',...
    '0.850 - < 0.900',...
    '0.900 - < 0.950',...
    '0.950 - < 1.00',...
    '1.00 and above'};

% f = figure('Position',[440 500 1000 1000]);
f = figure;

% Create the uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,...
            'RowName',rnames);




function threshold_input_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_input as text
%        str2double(get(hObject,'String')) returns contents of threshold_input as a double

%Make sure that magnification factor is not negative
threshold = ...
    str2double(get(handles.threshold_input,'String'));

% Make zero when negative, leave at same value if positive
threshold = ...
    (threshold>0).*threshold;

%Reassign to edit field
set(handles.threshold_input,'String', ...
    num2str(threshold))

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function threshold_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

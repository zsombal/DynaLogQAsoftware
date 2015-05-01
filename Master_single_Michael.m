% Master file to load and analyze a single Trajectory file
clear all


%% Button - loads the file, execute the code until %---end


FILENAME = cell(1, 2); % only for the single analysis

[FILENAME_tmp, PATHNAME, filterindex] = uigetfile({'*.dlg','Dynalog Files (*.dlg)';'*.bin', 'Trajectory files (*.bin)'},...
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

        file_names_path = {fullfile(PATHNAME, FILENAME{1}) fullfile(PATHNAME, FILENAME{2})};

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
        file_names_path = fullfile(PATHNAME, FILENAME);
        
        
        %%%%%%% !!!!!!!! implement a code, where you can run the python
        %%%%%%% code on the 'file_names_path'
        
       run MatPy.m
       
       curr_pos{1} = expected(:, 18:77).*10;
       curr_pos{2} = expected(:, 78:137).*10;

       planned_pos{1} = actual(:, 18:77).*10;
       planned_pos{2} = actual(:, 78:137).*10;

       

        
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
    
    
    case 1 %.dlg
        
                %if we've chosen a Step-and-Shoot file, this should be checked (not by user)
        % zeroincluded = 0; if step-and-shoot is choosen

        if All_header{1}{2}(1:4)=='STEP'

            zeroincluded = 0; % for step-and-shoot
        else
            zeroincluded = 1; % Dynamic movement
        end


        for ll = 1:num_files

 
            [curr_pos{ll}, leaf_error{ll}, leaf_RMS_error{ll}, bank_RMS_error{ll}, th_percentile{ll}, ...
                bank_th_percentile{ll}, mean_leaf_error{ll}, variance] = ...
                LeafError(All_files{ll}, zeroincluded, All_header{ll}{7}); % Results are in cm

        %     [leaf_speeds{ll}, mean_leaf_speeds{ll}, max_leaf_speeds{ll}] = ...
        %         DynoCompute(All_files{ll}, All_header{ll}{7}); % in mm/100
        %     [avg_gantry_speed{ll} gantry_angle{ll}] = GantryCompute(All_files{ll}); % in mm * sec^-1, in deg/10

%             [beam_on_time{ll}] = BeamOn(All_files{ll}); % in sec


        end
        
        
        
        
        
        
    case 2 %.bin
        

 
       
       for ll = 1:num_files



            leaf_error{ll} = curr_pos{ll} - planned_pos{ll};


            if ll == 1
                leaf_error{ll} = -leaf_error{ll};
            %     fprintf('B\n')
            else
            %     fprintf('A\n')
            end


            leaf_RMS_error{ll} = rms(leaf_error{ll}); % in mm


            mean_leaf_error{ll} = mean(leaf_error{ll}); % in mm

            variance{ll} = var(leaf_error{ll});


            for kk = 1:60 % 60 MLC leaves         


                th_percentile{ll}(1,kk) = prctile(abs(leaf_error{ll}(:,kk)),95); % in mm


            end

            bank_th_percentile{ll} = prctile(abs(leaf_error{ll}(:)),95); % in mm






            bank_RMS_error{ll} = mean(leaf_RMS_error{ll}); % in mm



       end

        
        
end



% just for output, print figures to file
print2eps = 0;


% avg_gantry_speed = cell(1, num_files);
% gantry_angle = cell(1, num_files);

% leaf_speeds = cell(1, num_files);
% mean_leaf_speeds = cell(1, num_files);
% max_leaf_speeds = cell(1, num_files);

% beam_on_time = cell(1, num_files);





%%
currentFolder = pwd

cd(PATHNAME)

% aa = FILENAME{1}(1:end-5)
uisave

cd(currentFolder)


pp = 0;


% it should stop here
%---end


%% Button - another button that loads the existing workspace 

% uiopen('load')




pp = 0;


%% Button current_position graphs

figure
pcolor(curr_pos{2*pp+1})
shading flat
colorbar
title('True B position [mm]')
xlabel('Leaf Number')
ylabel('Record Number')

if print2eps == 1
    
    str = strcat('../Figures/trajectory_position');
    print('-depsc', str)

end

%% Leaf error graph

figure
pcolor(abs(leaf_error{2*pp+1}))
shading flat
colorbar
title('Leaf Error position [mm]')
xlabel('Leaf Number')
ylabel('Record Number')

if print2eps == 1
    
    str = strcat('../Figures/trajectory_error');
    print('-depsc', str)

end

%% Button -  Error RMS, 95th percentile plot

% Beam on plot

[num_rows notUsed] = size(curr_pos{2*pp+1});

time = 0:0.05:(num_rows-1)*0.05;

% figure
% subplot(4,1,1)
% plot(time,All_files{2*pp+1}(:,4))
% title('Beam-on plot (1=on, 0=off)')
% xlabel('Time (sec)')
% ylabel('Beam On')

% Beam Hold Off Plot

time = 0:0.05:(num_rows-1)*0.05;

% subplot(4,1,2)
% plot(time,All_files{2*pp+1}(:,3))
% title('Beam Hold Off Plot (2= transition, 1=on, 0=off)')
% xlabel('Time (sec)')
% ylabel('Beam Hold')
figure
% Error RMS Plot
subplot(2,1,1)
plot(leaf_RMS_error{2*pp+1} )
hold on
plot(leaf_RMS_error{2*pp+2} ,'r')
title('Error RMS Plot')
ylabel('RMS Error (mm)')
xlabel('Leaf Number')
% ylim([0 Inf])

% 95th Percentile Plot
subplot(2,1,2)
plot(th_percentile{2*pp+1} )
hold on
plot(th_percentile{2*pp+2} ,'r')
title('95th Percentile Error')
ylabel('95th Error (mm)')
xlabel('Leaf Number')



if print2eps == 1
    str = strcat('../Figures/trajectory_rms');
    print('-depsc', str)
end

%% Button show Error RMS Data in a table

% create the data
d = [bank_th_percentile{2*pp+1} bank_th_percentile{2*pp+2}; ...
    bank_RMS_error{2*pp+1} bank_RMS_error{2*pp+2}; ...
    max(leaf_RMS_error{2*pp+1}) max(leaf_RMS_error{2*pp+2});...
    leaf_RMS_error{2*pp+1}' leaf_RMS_error{2*pp+2}'];

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
             


%% Button - Error Histogram Data in a table
%done

xx = abs(nonzeros(leaf_error{2*pp+1}));
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
 
% Percent = round(Percent,2);
% Percent_sum = round(Percent_sum,2);


% create the data
d = [Bin_no', N_counts', Percent', Percent_sum'];


% Create the column and row names in cell arrays 
cnames = {'Bin no'; '# of counts'; 'Percent'; 'Percent Sum'};


% rnames are in cm
rnames = {'0 - < 0.050',...
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
f = figure

% Create the uitable
t = uitable(f,'Data',d,...
            'ColumnName',cnames,...
            'RowName',rnames);

        
%% Write it to an Excel Sheet (definitely needs to be changed)

% col=get(t,'ColumnName')'     % t is the handle of your table
% data=get(t,'Data')
% num=[data]
% xlswrite('file.xls',num)
%    

%% Button - plot Error Histogram
%done

figure
xx = abs(nonzeros(leaf_error{2*pp+1}));
edges = [0:0.5:10]+0.25;
h = hist(xx,edges-0.25);
bar(edges,h,'hist')
title('Error Histogram Plot')
xlabel('Leaf Error (mm)')
ylabel('Number of counts')
set(gca,'ygrid','on')

if print2eps == 1
    str = strcat('../Figures/trajectory_error_hist');
    print('-depsc', str)
end

%% determine if any of the values went over the threshold 
%done

% input - give a threshold value in mm (default is 0.5 mm)

threshold = 0.5;

ii = find(leaf_RMS_error{2*pp+1}>=threshold);

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

    if print2eps == 1
        str = strcat('../Figures/trajectory_over_threshold');
        print('-depsc', str)
    end
end


        
function modify_python_file(PATHNAME)

    %% Read txt into cell A in a linewise fashion
    fid = fopen('DatPy.py','r');
    i = 1;
    tline = fgetl(fid);
    A{i} = tline;
    while ischar(tline)
        i = i+1;
        tline = fgetl(fid);
        A{i} = tline;
    end
    fclose(fid);
    %%
    lineBeginning = 'aa = TrajectoryLog.main(''';
    lineEnd = ''')';
    
    line8 = strcat(lineBeginning,PATHNAME,lineEnd);
    
%     line8 = 'aa = TrajectoryLog.main(''/Users/zsombor/Documents/McGill/Phys339/medPhys/DynaLogQAsoftware/QA_TB_MORNING_2.Morning QA_4.T3MLCSpeed_20150320072625.bin'')';

    A{8} = line8;
%%

    % Write cell A into DatPy.py
    fid = fopen('DatPy.py', 'w');
    for i = 1:numel(A)
        if A{i+1} == -1
            fprintf(fid,'%s', A{i});
            break
        else
            fprintf(fid,'%s\n', A{i});
        end
    end

end

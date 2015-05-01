# IMRT_QA_matlab

This is a MATLAB GUI for QA of DynaLog files.

If you want to work with a single Dynalog file open 'SingleFileQA.m' in MATLAB and simply run it
- after clicking on Create Bundle from single file >> wait till it says 'Bundle loaded' in the command line
- Bundles are just simple MATLAB workspaces
- You can click on Cancel, when it offers you to save the Bundle

If you want to work with multiple (DynaLog) files, open the 'MultipleFilesQA.m' in MATLAB and simply run it
- after clicking on Create Bundle from single file >> wait till it says 'Bundle loaded' in the command line
- here, the load bundle can be really useful, especially considering the fact that you can work with a lot of files,
and also can do calculations on them


Single Trajectory file:
- It only works with SINGLE Trajectory files and not perfectly, the steps are the following:
	1, copy the .bin and .txt file to the 'DynaLogQAsoftware' folder
	2, open 'Datpy.py' and copy the name of the Trajectory file to the respective place on line 6
	3, save the datpy.py
	4, Run 'SingleFileQA.m' in MATLAB, and chose a .bin format
	4+1, You might want to consider saving this bundle, since it takes a hell lot of time to analyze one Trajectory file (compared to DynaLog files) 

Multiple Trajectory file:
- Does NOT work. As soon as the issue with calling single trajectory files from MATLAB is resolved, this can be relatively easily implemented


Note
- it doesn't work perfectly with Trajectory files, not so user friendly
- doesn't have beam-on time from trajectory files
- can be easily modified using MATLAB (less, more buttons, extra calculation, etc.)
- Pylinac (?) is a good software that does the same, I'd say. It also has the feature of get_moving_leaves()
which is NOT implemented in this software due to time constraints (results should be about the same) 



Developed in an independent class project for Phys 339 (McGill University)

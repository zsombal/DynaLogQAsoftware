# IMRT_QA_matlab

This is a MATLAB GUI for QA of DynaLog files.

If you want to work with a single file open 'SingleFileQA.m' in MATLAB and simply run it
- after clicking on Create Bundle from single file >> wait till it says 'Bundle loaded' in the command line
- Bundles are just simple MATLAB workspaces
- You can click on Cancel, when it offers you to save the Bundle
- You CAN choose to load a .bin file (Trajectory file), but at the moment it's NOT working

If you want to work with multiple (DynaLog) files, open the 'MultipleFilesQA.m' in MATLAB and simply run it
- after clicking on Create Bundle from single file >> wait till it says 'Bundle loaded' in the command line
- here, the load bundle can be really useful, especially considering the fact that you can work with a lot of files,
and can also do calculations on them



Note
- it doesn't work with Trajectory files
- can be easily modified using MATLAB (less, more buttons, extra calculation, etc.)
- Pylinac (?) is a good software that does the same, I'd say. It also has the feature of get_moving_leaves()
which is NOT implemented in this software due to time constraints (results should be about the same) 



Developed in an independent class project for Phys 339 (McGill University)

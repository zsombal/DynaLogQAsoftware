# Write output of a python program to a dat file. The top call is made from MatLab.

#import sys
#!/bin/python
import TrajectoryLog

"""  Modify this line to change the Trajectory file to be read """
aa = TrajectoryLog.main('QA_TB_MORNING_2.Morning QA_4.T3MLCSpeed_20150320072625.bin')

header = aa[1]

trajheader = aa[0]



expected = aa[2]

actual = aa[3]




#Open new data file
f = open("expected.dat", "w")

for i in expected:
    f.write( str(i) + "\n" )      # str() converts to string
f.close()


#Open new data file
f = open("actual.dat", "w")

for i in actual:
    f.write( str(i) + "\n" )      # str() converts to string



f.close()



#Open new data file
f = open("data.txt", "w")

for i in header:
    f.write( str(i) + "\n" )      # str() converts to string



f.close()


#Open new data file
f = open("data2.txt", "w")

for i in trajheader:
    f.write( str(i) + "\n" )      # str() converts to string



f.close()


#Open new data file
f = open("data3.txt", "w")

for i in trajheader:
    f.write( str(i) + "\n" )      # str() converts to string



f.close()




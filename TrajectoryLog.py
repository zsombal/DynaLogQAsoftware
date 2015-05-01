import struct, sys
import numpy as np
from argparse import ArgumentParser

""" To call this file: import TrajectoryLog; TrajectoryLog.main(<filename>) """

""" Not written by us """

"""  import TrajectoryLog; TrajectoryLog.main(QA_TB_MORNING_2.Morning QA_4.T3MLCSpeed_20150319065745.bin) """
#filename = 'QA_TB_MORNING_2.Morning QA_4.T3MLCSpeed_20150319065745.bin'


def _openFile(filename):
    '''
    Check for the existence of the binary file
    and open it
    '''        
	
    try:

        #------------------- Message that a specific file has been generated
        f = open(filename, 'rb')    
       	print("file " + filename + " exists") 
        return(f)
    except IOError:
        #------------------------ No trajectory file of the given name exits
        print("Binary trajectory file doesn't exist")        

	       
def _headerData(file):
    '''
    Header has a fixed length of 1024 bytes. 
    Integers and floats are stored in little endian format
    '''
    print("haho")
    trajectoryHeader = dict()
    
    #----------------------------------------- Start reading the header info
    trajectoryHeader['Signature'] = file.read(16)
    trajectoryHeader['Version'] = file.read(16) 
    trajectoryHeader['HeaderSize'] = struct.unpack('<i', file.read(4))[0]
    trajectoryHeader['SamplingInterval'] = struct.unpack('<i', file.read(4))[0]
    trajectoryHeader['NumberOfAxes'] = struct.unpack('<i', file.read(4))[0] 
            
    #------------- Substitute axis in integer with their corresponding names
    axeslabel = {0:'Coll Rtn', 1:'Gantry Rtn',
                 2:'Y1', 3: 'Y2', 4: 'X1', 5: 'X2',
                 6:'Couch Vrt', 7:'Couch Lng', 8:'Couch Lat', 9:'Couch Rtn', 10:'Couch Pit', 11:'Couch Rol',
                 40:'MU', 41:'Beam Hold', 42:'Control Point', 50:'MLC'
                 }
        
    axesOrder = dict()    
    for i in range(trajectoryHeader['NumberOfAxes']):
        currentAxis = struct.unpack('<i', file.read(4))[0]
        trajectoryHeader[axeslabel[currentAxis]] = currentAxis
        axesOrder[i] = axeslabel[currentAxis]

    trajectoryHeader['axesOrder'] = axesOrder
            
    #------------ Number of sample per axis, generally 1, except for mlc 122
    samplePerAxis = np.zeros(trajectoryHeader['NumberOfAxes'])
        
    axesIndex = dict()
    for i in range(trajectoryHeader['NumberOfAxes']):
        samplePerAxis[i] = struct.unpack('<i', file.read(4))[0] 
        axesIndex[axesOrder[i]] = sum(samplePerAxis) - samplePerAxis[i]
                
    trajectoryHeader['axesIndex'] = axesIndex
    trajectoryHeader['SamplePerAxis'] = samplePerAxis
    trajectoryHeader['AxisScale'] = 'Machine Scale' if(struct.unpack('<i', file.read(4))[0] == 1) else 'Modified IEC'        
    trajectoryHeader['NumberOfSubbeams'] = struct.unpack('<i', file.read(4))[0]
    trajectoryHeader['Truncated'] ='truncated' if(struct.unpack('<i', file.read(4))[0] == 1) else 'Not truncated'
    trajectoryHeader['NumberOfSnapShots'] = struct.unpack('<i', file.read(4))[0]
    trajectoryHeader['MLCModel'] = 'NDS 120' if(struct.unpack('<i', file.read(4))[0] == 2) else 'NDS 120 HD'
    
    #------------------------ Rest of the header bytes are reserved for future use
    file.seek(1024)   
    return trajectoryHeader

def _subbeamStructure(file):
    '''
    Read the subbeam data structure.
    Each subbeam is 560 bytes long 
    '''
    
    subbeam = dict()
    
    subbeam['cp'] = struct.unpack('<i', file.read(4))[0]
    subbeam['mu'] = struct.unpack('<f', file.read(4))[0]
    subbeam['radTime'] = struct.unpack('<f', file.read(4))[0]
    subbeam['Seq'] = struct.unpack('<i', file.read(4))[0]
    subbeam['NameOfTheSubbeam'] = file.read(512)
    subbeam['Reserved'] = file.read(32)

    return subbeam

def _axisDataStructure(file, trajectoryHeader):
    '''
    Read the axis data from the trajectory file.
    Data corresponding to each axis is stored in a row.
    The two matrices corresponding to the expected and actual
    axis data is stored.   
    '''
    
   
    axesLength = int(sum(trajectoryHeader['SamplePerAxis']))

    #----- Initialize matrices corresponding to expected and actual axis data
    expectedAxisDataPerAxis = np.zeros((trajectoryHeader['NumberOfSnapShots'], axesLength), dtype='float')
    actualAxisDataPerAxis = np.zeros((trajectoryHeader['NumberOfSnapShots'], axesLength), dtype='float')
                              
    #--------------------------------------- Read expected and actual values
    #for i in  range(trajectoryHeader['NumberOfSnapShots']):
    for i in  range(trajectoryHeader['NumberOfSnapShots']):
        for j in range(axesLength):
            
            expectedAxisDataPerAxis[i, j] = struct.unpack('<f', file.read(4))[0]
            actualAxisDataPerAxis[i, j] = struct.unpack('<f', file.read(4))[0]

    return trajectoryHeader['axesIndex'], expectedAxisDataPerAxis, actualAxisDataPerAxis

def main(filename):


    file = _openFile(filename)
    trajectoryHeader = _headerData(file)

    subbeam = dict()
    for i in range(trajectoryHeader['NumberOfSubbeams']):
        subbeam[i] = _subbeamStructure(file)

    header, expectedData,actualData = _axisDataStructure(file, trajectoryHeader)

    return trajectoryHeader, header, expectedData, actualData


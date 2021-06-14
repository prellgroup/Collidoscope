::Feel free to either edit this file and save over it anytime you need to run a batch, or save as "Collidoscopebatch2.bat", etc.
@ECHO off
TITLE Collidoscope Batch Run
::run this from your main Collidoscope directory, and copy and paste the following line as many times as you need, changing any of the flags as necessary
Collidoscope.exe -fc coordinateFiles\ondansetron.pdb -fp inputfiles\He.gas -C 1 -oi outputFiles\ondansetron1.info -mode CCS
Collidoscope.exe -fc coordinateFiles\ondansetron.pdb -fp inputfiles\He.gas -C 1 -oi outputFiles\ondansetron2.info -mode CCS
Collidoscope.exe -fc coordinateFiles\ondansetron.pdb -fp inputfiles\He.gas -C 1 -oi outputFiles\ondansetron3.info -mode CCS
ECHO Finished all requested operations.
PAUSE
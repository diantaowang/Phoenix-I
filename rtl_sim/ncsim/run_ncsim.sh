#!/bin/bash
if [ -e INCA_libs ]
then
	\rm -rf INCA_libs
fi

	\rm -rf *.fsdb
	\rm -rf *.log
	\rm -rf ncverilog.key
	\rm -rf ncsim.err
	\rm -rf novas*
	\rm -rf verdiLog

#getkey

#verdi env setting
export PLATFORM=LINUX
export NOVAS_INST_DIR=/opt/spring/verdi
export LD_LIBRARY_PATH=$NOVAS_INST_DIR/share/PLI/IUS/$PLATFORM:$LD_LIBRARY_PATH

#ncverilog -f run.f  +access+rw
irun -f run.f  +access+rwc
#irun -f run.f +rwc

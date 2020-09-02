#!/bin/bash
  CMSSW_v=$1
if [ "X$RELEASE_FORMAT" != "X" ];then
  CMSSW_v=$RELEASE_FORMAT
fi
if [ "X$CMSSW_IB" != "X" ]; then
  CMSSW_v=$CMSSW_IB
fi

## --1. Install CMSSW version and setup environment
if [ "X$ARCHITECTURE" != "X" ];then
  export SCRAM_ARCH=$ARCHITECTURE
else
  export SCRAM_ARCH=slc7_amd64_gcc900
fi
export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
echo "$VO_CMS_SW_DIR $SCRAM_ARCH"
source $VO_CMS_SW_DIR/cmsset_default.sh

if [ "X$PROFILING_WORKFLOW" == "X" ];then
  export PROFILING_WORKFLOW="23434.21"
fi 

if [ "X$WORKSPACE" != "X" ]; then
  cd $WORKSPACE/$CMSSW_v/src/$PROFILING_WORKFLOW
else
  cd $CMSSW_v/src/TimeMemory
fi
eval `scramv1 runtime -sh`

echo "My loc"
echo $PWD

if [ "X$WORKSPACE" != "X" ]; then
  export WRAPPER=$WORKSPACE/profiling/ascii-out-wrapper.py
fi

#step1
igprof -mp -o ./igprofMEM_step1.mp -- cmsRun  $WRAPPER $(ls *GEN_SIM.py)  >& step1_mem.log


#step2
igprof -mp -o ./igprofMEM_step2.mp -- cmsRun $WRAPPER $(ls step2*.py) >& step2_mem.log


#step3
igprof -mp -o ./igprofMEM_step3.mp -- cmsRun $WRAPPER $(ls step3*.py)  >& step3_mem.log


#step4
igprof -mp -o ./igprofMEM_step4.mp -- cmsRun $WRAPPER $(ls step4*.py)  >& step4_mem.log

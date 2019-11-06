
# The default path for the job is your home directory, so we change directory to where the files are.
cd $PBS_O_WORKDIR

# Traffic detection script writes output to a file inside a directory. We make sure that this directory exists.
# The output directory is the first argument of the bash script
OUTPUT_DIR=$1
DEVICE=$2
FP_MODEL=$3
INPUT_ADDR=$4

if [ "$DEVICE" = "HETERO:FPGA,CPU" ]; then
  # Environment variables and compilation for edge compute nodes with FPGAs
  source /opt/fpga_support_files/setup_env.sh
  aocl program acl0 /opt/intel/computer_vision_sdk/bitstreams/a10_vision_design_bitstreams/5-0_PL1_FP16_ResNet_TinyYolo_ELU.aocx
fi

# Running the traffic detection code
SAMPLEPATH=${PBS_O_WORKDIR}
if [ "$FP_MODEL" = "FP32" ]; then
  MODELPATH=${SAMPLEPATH}/models/Security/object_detection/crossroad/0078/dldt/person-vehicle-bike-detection-crossroad-0078.xml
else
  MODELPATH=${SAMPLEPATH}/models/Security/object_detection/crossroad/0078/dldt/person-vehicle-bike-detection-crossroad-0078-fp16.xml
fi

python3 live_traffic_detection.py  -m ${MODELPATH} \
                                   -i ${INPUT_ADDR} \
                                   -o ${OUTPUT_DIR} \
                                   -d ${DEVICE} \
                                   -c 300 \
                                   -l /opt/intel/openvino/deployment_tools/inference_engine/lib/intel64/libcpu_extension_avx2.so

# 
# Defines the part type that this project uses.
#
PART=__MSP432P401R__
PROJECTNAME=embedPhil1
ldname=embedPhil1_gcc.ld
FLASHTOOL=openocd
#
# Variables for ProjectName, Build and Source Directories
#
SOURCE=src
BUILD_DIR=Build

#
# The base directory for MSPWare.
#
ROOT= .
DLIB_ROOT=lib/driverlib/MSP432P4xx/



#
# Where to find header files that do not live in the source directory.
#
IPATH= .
IPATH+= lib/inc/
IPATH+= lib/inc/CMSIS/
IPATH+=${DLIB_ROOT}

#
# The default rule, which causes the driverlib_empty_project example to be built.
#
all: ${BUILD_DIR}
all: ${BUILD_DIR}/${PROJECTNAME}.axf

#
# Include the common make definitions.
#
include Makefile.defs

#
# The Variables and rule to clean out all the build products.
#
SRC_FILES =$(wildcard ${DLIB_ROOT}*.c) 
SRC_FILES+=$(wildcard ${SOURCE}/*.c)
OBJ_FILES=$(wildcard ${DLIB_ROOT}*.o) 
DEP_FILES=$(wildcard ${DLIB_ROOT}*.d)
OBJ_FILES+=$(wildcard ${BUILD_DIR}/*.o)
DEP_FILES+=$(wildcard ${BUILD_DIR}/*.d)
OBJ_FILES_FIXED = ${call FixPath,${OBJ_FILES}}
DEP_FILES_FIXED = ${call FixPath,${DEP_FILES}}
OPENOCD_CONFIG_FILE=msp432.cfg
OPENOCD_LOG_OUTPUT=.openocd.log

clean:
	${RM} ${OBJ_FILES_FIXED}
	${RM} ${DEP_FILES_FIXED}
	${RM} ${BUILD_DIR}
	${RM} ${OPENOCD_LOG_OUTPUT}
	
#
# The rule to create the target directory.
#
${BUILD_DIR}:
	${MKDIR} ${BUILD_DIR}

#
# Rules for building the driverlib_empty_project example.
#
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}adc14.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}aes256.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}comp_e.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}cpu.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}crc32.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}cs.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}dma.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}flash.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}fpu.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}gpio.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}i2c.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}interrupt.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}mpu.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}pcm.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}pmap.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}pss.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}ref_a.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}reset.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}rtc_c.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}spi.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}sysctl.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}systick.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}timer32.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}timer_a.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}uart.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${DLIB_ROOT}wdt_a.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${BUILD_DIR}/msp432_startup_${COMPILER}.o
${BUILD_DIR}/${PROJECTNAME}.axf: ${BUILD_DIR}/main.o
#${BUILD_DIR}/${PROJECTNAME}.axf: *.ld
${BUILD_DIR}/${PROJECTNAME}.axf: embedPhil1_gcc.ld
#${BUILD_DIR}/${PROJECTNAME}.axf: ${PROJECTNAME}_${COMPILER}.ld
SCATTERgcc_embedPhil1=embedPhil1_gcc.ld
#SCATTERgcc_embedPhil1=${PROJECTNAME}_${COMPILER}.ld
ENTRY_embedPhil1=ResetISR
CFLAGSgcc=-DTARGET_IS_MSP432P4XX

#
# Include the automatically generated dependency files.
#
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${BUILD_DIR}/*.d} __dummy__
endif

flash:
	${FLASHTOOL} -f ${OPENOCD_CONFIG_FILE} -l ${OPENOCD_LOG_OUTPUT} -c "init" -c "halt" -c "load_image ${BUILD_DIR}/${PROJECTNAME}.axf" -c "reset run" -c "exit"

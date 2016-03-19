#
# Defines the part type that this project uses.
#
PART=__MSP432P401R__

#
# Build directory
#
BUILD_DIR=Build

#
# The base directory for MSPWare.
#
ROOT= .
DLIB_ROOT=lib/driverlib/MSP432P4xx/

#
# Include the common make definitions.
#
include Makefile.defs

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
# The rule to clean out all the build products.
#
clean:
	@rm -rf ${BUILD_DIR} ${wildcard *~}
	@rm -rf ${DLIB_ROOT}/*.o
	@rm -rf *.d
#
# The rule to create the target directory.
#
${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}

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
	uniflash.sh -ccxml lib/VGHCONFIG.ccxml -program ${BUILD_DIR}/${PROJECT_NAME}.axf 

#
# Defines the part type that this project uses.
#
PART=__MSP432P401R__

#
# The base directory for MSPWare.
#
ROOT=../../../..

#
# Include the common make definitions.
#
include ../../Makefile.defs

#
# Where to find header files that do not live in the source directory.
#
IPATH=../../../..
IPATH+=../../../../inc/
IPATH+=../../../../inc/CMSIS/
IPATH+=../../../../driverlib/MSP432P4xx

#
# The default rule, which causes the resetctl_software_initiated_reset example to be built.
#
all: ${COMPILER}
all: ${COMPILER}/resetctl_software_initiated_reset.axf

#
# The rule to clean out all the build products.
#
clean:
	@rm -rf ${COMPILER} ${wildcard *~}

#
# The rule to create the target directory.
#
${COMPILER}:
	@mkdir -p ${COMPILER}

#
# Rules for building the resetctl_software_initiated_reset example.
#
${COMPILER}/resetctl_software_initiated_reset.axf: ${COMPILER}/msp432_startup_${COMPILER}.o
${COMPILER}/resetctl_software_initiated_reset.axf: ${COMPILER}/resetctl_software_initiated_reset.o
${COMPILER}/resetctl_software_initiated_reset.axf: ${ROOT}/driverlib/MSP432P4xx/${COMPILER}/msp432p4xx_driverlib.a
${COMPILER}/resetctl_software_initiated_reset.axf: resetctl_software_initiated_reset_gcc.ld
SCATTERgcc_resetctl_software_initiated_reset=resetctl_software_initiated_reset_gcc.ld
ENTRY_resetctl_software_initiated_reset=ResetISR
CFLAGSgcc=-DTARGET_IS_MSP432P4XX

#
# Include the automatically generated dependency files.
#
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${COMPILER}/*.d} __dummy__
endif

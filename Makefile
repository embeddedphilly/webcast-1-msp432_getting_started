# Defines the part type that this project uses.
PART=__MSP432P401R__
BUILD_DIR=Build
SOURCE_DIR=src
PROJECT_NAME=pname1
COMPILER=gcc

# Linkerscriptname
ldname=msp432_gcc_linkerscript.ld

# Get the operating system name.  
os:=${shell uname -s}

# The command for calling the compiler.
CC=arm-none-eabi-gcc

# The location of the C compiler
ARMGCC_ROOT:=${shell dirname '${shell sh -c "which ${CC}"}'}/..

# Set the compiler CPU/FPU options.
CPU=-mcpu=cortex-m4
FPU=-mfpu=fpv4-sp-d16 -mfloat-abi=softfp

# The flags passed to the assembler.
AFLAGS=-mthumb \
       ${CPU}  \
       ${FPU}  \
       -MD

# The flags passed to the compiler.
CFLAGS=-mthumb                               \
       ${CPU}                                \
       ${FPU}                                \
       -ffunction-sections                   \
       -fdata-sections                       \
       -MD                                   \
       -std=c99                              \
       -D${PART}                             \
       -DUSE_CMSIS_REGISTER_FORMAT           \
       -Dgcc                                 \
       -DTARGET_IS_MSP432P4XX                \
       -c


# The command for calling the library archiver.
AR=arm-none-eabi-ar

# The command for calling the linker.
LD=arm-none-eabi-ld

# The flags passed to the linker.
LDFLAGS=--gc-sections

# Get the location of libgcc.a from the GCC front-end.
LIBGCC:=${shell ${CC} ${CFLAGS} -print-libgcc-file-name}

# Get the location of libc.a from the GCC front-end.
LIBC:=${shell ${CC} ${CFLAGS} -print-file-name=libc.a}

# Get the location of libm.a from the GCC front-end.
LIBM:=${shell ${CC} ${CFLAGS} -print-file-name=libm.a}

# The command for extracting images from the linked executables.
OBJCOPY=arm-none-eabi-objcopy

# Tell the compiler to include debugging information if the DEBUG environment  variable is set.
ifdef DEBUG
CFLAGS+=-g -D DEBUG -O0
else
CFLAGS+=-Os
endif

# Where to find header files that do not live in the source directory.
IPATH= .
IPATH+= src/
IPATH+= inc/
IPATH+= inc/CMSIS/

# Add the tool specific CFLAGS.
CFLAGS+=${CFLAGSgcc}

# Add the include file paths to AFLAGS and CFLAGS.
# every white-space seprated word in IPATH has -I prepended
AFLAGS+=${patsubst %,-I%,${subst :, ,${IPATH}}}
CFLAGS+=${patsubst %,-I%,${subst :, ,${IPATH}}}

# The rule for building the object file from each C source file.
${BUILD_DIR}/%.o: ${SOURCE_DIR}/%.c
	@${CC} ${CFLAGS} -D${COMPILER} -o ${@} ${<}
ifneq ($(findstring CYGWIN, ${os}), )
	sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif

# The rule for building the object file from each C source file.
${BUILD_DIR}/%.o: %.c
	@${CC} ${CFLAGS} -D${COMPILER} -o ${@} ${<}
ifneq ($(findstring CYGWIN, ${os}), )
	sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif

# The rule for building the object file from each assembly source file.
${BUILD_DIR}/%.o: %.S
	${CC} ${AFLAGS} -D${COMPILER} -o ${@} -c ${<}
ifneq ($(findstring CYGWIN, ${os}), )
	@sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif

# The rule for creating an object library.
${BUILD_DIR}/%.a:
	${AR} -cr ${@} ${^}
ifneq ($(findstring CYGWIN, ${os}), )
	@sed -i -r 's/ ([A-Za-z]):/ \/cygdrive\/\1/g' ${@:.o=.d}
endif


# The rule for linking the application.
${BUILD_DIR}/${PROJECT_NAME}.axf :                                                           
	@${LD} -T ${ldname}                       \
	      ${LDFLAGSgcc_${notdir ${@:.axf=}}}                              \
	      ${LDFLAGS} -o ${@} $(filter %.o %.a, ${^})                      \
	      '${LIBM}' '${LIBC}' '${LIBGCC}'
	@${OBJCOPY} -O binary ${@} ${@:.axf=.bin}

#${ENTRY_${notdir ${@:.axf=}}}
                                                                 





# The default rule, which causes the project to be built.
all: ${BUILD_DIR}
all: ${BUILD_DIR}/${PROJECT_NAME}.axf

# The rule to clean out all the build products.
clean:
	@rm -rf ${BUILD_DIR} ${wildcard *~}

# The rule to create the target directory.
${BUILD_DIR}:
	@mkdir -p ${BUILD_DIR}


#
# Rules for building the driverlib_empty_project example.
${BUILD_DIR}/${PROJECT_NAME}.axf: ${BUILD_DIR}/msp432_startup_gcc.o
${BUILD_DIR}/${PROJECT_NAME}.axf: ${BUILD_DIR}/main.o
${BUILD_DIR}/${PROJECT_NAME}.axf: ${ldname}
#SCATTERgcc__pname1=${ldname}
SCATTERgcc__pname1=${ldname}
#ENTRY_${PROJECT_NAME}=ResetISR
ENTRY_pname1=ResetISR


#
# Include the automatically generated dependency files.
#
ifneq (${MAKECMDGOALS},clean)
-include ${wildcard ${BUILD_DIR}/*.d} __dummy__
endif

#flash:
#	uniflash.sh -ccxml inc/${wildcard *.ccxml} -program ${BUILD_DIR}/${PROJECT_NAME}.axf

flash:
	uniflash.sh -ccxml inc/VGHCONFIG.ccxml -program Build/pname1.axf

scanbuild:
	scan-build-3.5 make all

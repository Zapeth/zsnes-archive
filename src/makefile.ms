#Copyright (C) 1997-2008 ZSNES Team ( zsKnight, _Demo_, pagefault, Nach )
#
#http://www.zsnes.com
#http://sourceforge.net/projects/zsnes
#https://zsnes.bountysource.com
#
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#version 2 as published by the Free Software Foundation.
#
#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

#Parameters:
#
# PLATFORM=platform_name  Chose target platform and how you're creating it.
#                         Valid options are:
#                         msvc, win32, win32-cross, win32-unix-shell
#
# DEBUG=yes               For debugging with GDB or the like.
#
# DEBUGGER=no             To build ZSNES without the debugger.
#
# RELEASEGRADE=yes        For high assembly optimization for releases, will take
#                         at least half an hour.
#
# clean                   Cleans object and executable files.
#
#
# --Not for MSVC--
# CPU=cpu-type            Optimize for a particular CPU, find a list of cpu
#                         types in the GCC manual.

ENV=$(PLATFORM)
ifneq (${ENV},) #end if is at the bottom of the file

DELETECOMMAND=rm -f
DELPRE=rm -f
DELSUF=
SLASH=/
PSR=parsegen
ASM=nasm
ASMOPT=-O1
ASMFLAGSORIG=-w-orphan-labels
COPT=-O3
CPUOPT=i586
ifneq ($(CPU),)
CPUOPT=$(CPU)
endif
CFLAGONLY=-std=c99 -U__STRICT_ANSI__ -Wdeclaration-after-statement
CFLAGSORIG=-march=${CPUOPT} -ffast-math -fomit-frame-pointer -fno-unroll-loops -Wall -Wno-unused -I. -DNDEBUG
CXXFLAGSORIG=
LIBSORIG=-lz -lpng
DRESOBJ=${WIN_D}/zsnes.obj
CROSS=no
STRIP=-Ws -s

QT_BASE=c:\qt\4.2.3

ifeq (${ENV},win32-unix-shell)
  ENV=win32
  CROSS=yes
endif

ifeq (${ENV},win32)
  CC = gcc
  CPPC = g++
  WINDRES = windres
  OS=__WIN32__
  OBJFIX=objfix.exe
endif

ifeq (${ENV},msvc)
  CFLAGONLY=
  CFLAGSORIG=/nologo /Ox /Oy- /GA /c /EHsc "/I${DXSDK_DIR}include" /MD /Iwin\vc_head /DNDEBUG /D_CRT_SECURE_NO_DEPRECATE /D_CRT_NONSTDC_NO_DEPRECATE
  CXXFLAGSORIG=/Zc:forScope-
  MSVCLIBS=zlib.lib libpng.lib wsock32.lib ole32.lib user32.lib gdi32.lib shfolder.lib shell32.lib winmm.lib "${DXSDK_DIR}lib\x86"\dinput8.lib "${DXSDK_DIR}lib\x86"\dxguid.lib opengl32.lib glu32.lib
  DRESOBJ=${WIN_D}/zsnes.res
  OS=__WIN32__
  QT_BASE=c:\qt
endif

ifeq (${ENV},win32-cross)
  CC = i586-mingw32-gcc
  CPPC = i586-mingw32-g++
  WINDRES = i586-mingw32-windres
  OS=__WIN32__
  CROSS=yes
  OBJFIX=objfix
  QT_BASE=/mnt/C/Qt/4.2.3
endif

ifeq (${CROSS},no)
  PSR=parsegen.exe
  DELETECOMMAND=del
  ifeq (${OS},__WIN32__)
    DELPRE=@for %%n in (znotfile.nt,
    DELSUF=) do if exist %%n del %%n
  else
    DELPRE=@for %n in (znotfile.nt,
    DELSUF=) do if exist %n del %n
  endif
  SLASH=\${BLAHBLAHBLAH}
  SEP=,
endif

ifeq (${OS},__WIN32__)
  EXE=zsnesw.exe
  FILEFORMAT=win32
  LIBS=${LIBSORIG} -ldxguid -ldinput8 -lwsock32 -luser32 -lgdi32 -lshfolder -lshell32 -lwinmm -lopengl32 -lglu32 -lole32
  LIBS+=-mwindows
  OE=.obj
  CONFLOC=${WIN_D}/confloc${OE}
endif

ifeq (${DEBUG},yes)
  ifneq (${ENV},msvc)
    CFLAGSORIG=-fno-omit-frame-pointer -ggdb3 -DDEBUG
  else
    CFLAGSORIG=/nologo /c /Od /Oy- /GS /GA /Yd /DDEBUG /MD "/I${DXSDK_DIR}include" /Iwin\vc_head
  endif
  COPT=-O0
  ASMFLAGSORIG=-DDEBUG -g
  EXE=zsnesd.exe
  STRIP=
endif

ifeq (${RELEASE},yes)
  CFLAGSORIG+= -D__RELEASE__
  ASMFLAGSORIG+= -D__RELEASE__
  RELEASEGRADE=yes
endif

ifeq (${RELEASEGRADE},yes)
  ASMOPT=-O9999
endif

ifeq (${DEBUGGER},no)
  CFLAGSORIG+= -DNO_DEBUGGER
  ASMFLAGSORIG+= -DNO_DEBUGGER
endif

ifeq (${QTD},yes)
  CFLAGSORIG+= -DQT_DEBUGGER
endif

LINK=${CPPC}

ifeq (${JMA},no)
  CFLAGSORIG+= -DNO_JMA
  ASMFLAGSORIG+= -DNO_JMA
  CXXFLAGSORIG+= -fno-exceptions
else
  ifeq (${ENV},msvc)
    CFLAGSORIG+= /EHsc
  endif
endif

CHIP_D=chips
CPU_D=cpu
EFF_D=effects
GUI_D=gui
JMA_D=jma
MMLIB_D=mmlib
NET_D=net
VID_D=video
NTSC_D=video${SLASH}snes_ntsc
WIN_D=win
ZIP_D=zip
SPC_D=cpu${SLASH}zspc
DEBUG_D=debugger

CFLAGS=${CFLAGSORIG} -D${OS} ${CFLAGONLY}
CXXFLAGS=${CFLAGSORIG} -D${OS} ${CXXFLAGSORIG}
ASMFLAGS=${ASMFLAGSORIG} -f ${FILEFORMAT} -D${OS}


CHIPSOBJ=${CHIP_D}/dsp1emu${OE} ${CHIP_D}/fxemu2${OE} ${CHIP_D}/sfxproc${OE}\
	${CHIP_D}/fxemu2b${OE} ${CHIP_D}/fxemu2c${OE} ${CHIP_D}/fxtable${OE}\
	${CHIP_D}/sa1proc${OE} ${CHIP_D}/sa1regs${OE} ${CHIP_D}/dsp1proc${OE}\
	${CHIP_D}/st10proc${OE} ${CHIP_D}/seta10${OE} ${CHIP_D}/dsp2proc${OE}\
	${CHIP_D}/sdd1emu${OE} ${CHIP_D}/c4emu${OE} ${CHIP_D}/dsp4proc${OE}\
	${CHIP_D}/dsp4emu${OE} ${CHIP_D}/dsp3proc${OE} ${CHIP_D}/dsp3emu${OE}\
	${CHIP_D}/obc1emu${OE} ${CHIP_D}/obc1proc${OE} ${CHIP_D}/c4proc${OE}\
	${CHIP_D}/7110proc${OE} ${CHIP_D}/st11proc${OE} ${CHIP_D}/seta11${OE}\
	${CHIP_D}/7110emu${OE} ${CHIP_D}/sa1emu${OE}

CPUOBJ=${CPU_D}/dma${OE} ${CPU_D}/execute${OE} ${CPU_D}/executec${OE}\
	${CPU_D}/irq${OE} ${CPU_D}/memory${OE} ${CPU_D}/memtable${OE}\
	${CPU_D}/stable${OE} ${CPU_D}/table${OE} ${CPU_D}/tablec${OE}\
	$(SPC_D)/zdsp${OE} $(SPC_D)/zspc${OE}

EFFECTSOBJ=${EFF_D}/burn${OE} ${EFF_D}/water${OE} ${EFF_D}/smoke${OE}

GUIOBJ=${GUI_D}/guiold${OE} ${GUI_D}/guifuncs${OE} ${GUI_D}/menu${OE}

ifneq (${JMA},no)
JMAOBJ=${JMA_D}/7zlzma${OE} ${JMA_D}/crc32${OE} ${JMA_D}/iiostrm${OE}\
	${JMA_D}/inbyte${OE} ${JMA_D}/jma${OE} ${JMA_D}/lzma${OE}\
	${JMA_D}/lzmadec${OE} ${JMA_D}/winout${OE} ${JMA_D}/zsnesjma${OE}
endif

MAINOBJ=endmem${OE} init${OE} initc${OE} patch${OE} ui${OE} vcache${OE}\
	version${OE} zmovie${OE} zstate${OE} zloader${OE} cfg${OE} md${OE}\
	input${OE} zdir${OE} zpath${OE} ztimec${OE} ztime${OE}

ifneq (${DEBUGGER},no)
  MAINOBJ+= debugger${OE} debugasm${OE}
    LIBS+= -lpdcurses
    MSVCLIBS+= pdcurses.lib
endif

NETOBJ=
#${NET_D}/ztcp${OE}

VIDEOBJ=${VID_D}/makev16b${OE} ${VID_D}/makev16t${OE} ${VID_D}/makevid${OE}\
	${VID_D}/mode716${OE} ${VID_D}/mode716b${OE} ${VID_D}/mode716d${OE}\
	${VID_D}/mode716e${OE} ${VID_D}/mode716t${OE} ${VID_D}/mv16tms${OE}\
	${VID_D}/newg162${OE} ${VID_D}/newgfx16${OE} ${VID_D}/newgfx${OE}\
	${VID_D}/m716text${OE} ${VID_D}/procvid${OE} ${VID_D}/procvidc${OE}\
	${VID_D}/2xsaiw${OE}

ZIPOBJ=${ZIP_D}/unzip${OE} ${ZIP_D}/zpng${OE}

OBJS=${CHIPSOBJ} ${CPUOBJ} ${GUIOBJ} ${VIDEOBJ} ${MAINOBJ} ${ZIPOBJ} ${EFFECTSOBJ} ${JMAOBJ}

ifeq (${OS},__WIN32__)
WINOBJ=${DRESOBJ}\
	${CONFLOC} ${WIN_D}/winintrf${OE} ${WIN_D}/winlink${OE} \
	${WIN_D}/lib${OE} ${WIN_D}/safelib${OE} ${MMLIB_D}/mm${OE} \
	${MMLIB_D}/windows${OE} ${WIN_D}/dx_ddraw${OE} ${WIN_D}/gl_draw${OE}

WINVIDOBJ=${VID_D}/sw_draw${OE} ${VID_D}/copyvwin${OE} ${VID_D}/ntsc${OE}\
	${VID_D}/hq2x16${OE} ${VID_D}/hq2x32${OE}\
	${VID_D}/hq3x16${OE} ${VID_D}/hq3x32${OE}\
	${VID_D}/hq4x16${OE} ${VID_D}/hq4x32${OE}

ifeq (${QTD},yes)
  CXXFLAGS+=-I"$(QT_BASE)${SLASH}include" -I"$(QT_BASE)${SLASH}include${SLASH}QtCore" -I"$(QT_BASE)${SLASH}include${SLASH}QtGui" -DWIN32
#  DEBUGGEROBJ=${DEBUG_D}/load${OE} ${DEBUG_D}/ui${OE} ${DEBUG_D}/moc_ui${OE} ${DEBUG_D}/moc_zthread${OE} ${DEBUG_D}/zthread${OE}
  LIBS+= -L${QT_BASE}${SLASH}lib -lQtCore4 -lQtGui4
  MSVCLIBS+= ${QT_BASE}${SLASH}lib${SLASH}qtcore.lib ${QT_BASE}${SLASH}lib${SLASH}qtgui.lib advapi32.lib imm32.lib winspool.lib comdlg32.lib
endif

#GUIOBJ+= ${GUI_D}/gui${OE} ${GUI_D}/moc_gui${OE}

OBJS+=${WINOBJ} ${WINVIDOBJ} ${NETOBJ} ${DEBUGGEROBJ}
endif

DELETEOBJS=${OBJS}

.SUFFIXES: .c .cpp .asm .psr .ui .h

ifneq (${ENV},msvc)
%${OE}: %.c
	${CC} ${COPT} ${CFLAGS} -o $@ -c $<

%${OE}: %.cpp
	${CPPC} ${COPT} ${CXXFLAGS} -o $@ -c $<

ifeq (${OS},__WIN32__)
%${OE}: %.asm ${OBJFIX}
	${ASM} ${ASMOPT} ${ASMFLAGS} -o $@ $<
	.${SLASH}${OBJFIX} $@
else
%${OE}: %.asm
	${ASM} ${ASMOPT} ${ASMFLAGS} -o $@ $<
endif
else
%.obj : %.c
	cl ${CFLAGS} /Fo$@ $<

%.obj: %.cpp
	cl ${CXXFLAGS} /Fo$@ $<

%.obj: %.asm
	${ASM} ${ASMOPT} ${ASMFLAGS} -o $@ $<
endif

%${OE}: %.psr
ifneq (${ENV},msvc)
	.${SLASH}parsegen -D${OS} -gcc ${CC} -compile -flags "${CFLAGS} -O1" -cheader $(patsubst %${OE},%.h,$@) -fname $(notdir $(patsubst %${OE},%,$@)) $@ $<
else
	.${SLASH}parsegen -D${OS} -compile -flags "/c /MD" -cheader $(patsubst %${OE},%.h,$@) -fname $(notdir $(patsubst %${OE},%,$@)) $@ $<
endif

ui_%.h: %.ui
	uic -o $@ $<
moc_%.cpp: %.h
	moc -o $@ $<

ALL: zsnes
	${DELETECOMMAND} version${OE}

.PHONY: ALL zsnes playspc clean
zsnes: ${PSR} ${OBJFIX} ${OBJS}
ifneq (${ENV},msvc)
	${LINK} ${STRIP} -o ${EXE} ${OBJS} ${LIBS}
else
	 @echo /Fezsnesw.exe *.obj ${CPU_D}\*.obj ${VID_D}\*.obj ${CHIP_D}\*.obj ${EFF_D}\*.obj ${WIN_D}\*.obj ${GUI_D}\*.obj > link.vc
	 @echo ${ZIP_D}\*.obj ${JMA_D}\*.obj ${NET_D}\*.obj ${MMLIB_D}\*.obj ${SPC_D}\*.obj ${DEBUG_D}\*.obj >> link.vc
	 @echo ${MSVCLIBS} >> link.vc
	 cl /nologo @link.vc ${WIN_D}/zsnes.res /link /SUBSYSTEM:WINDOWS /NODEFAULTLIB:LIBCMTD.LIB /NODEFAULTLIB:LIBC.LIB /NODEFAULTLIB:LIBCMT.LIB
endif

ifneq (${ENV},msvc)
playspc: playspc.c ${SPC_D}/zdsp${OE} ${SPC_D}/zspc${OE}
	${CPPC} ${COPT} ${CXXFLAGS} -o playspc.exe playspc.c $(SPC_D)/zdsp${OE} $(SPC_D)/zspc${OE} ${LIBS} -ldsound
endif

cfg${OE}: cfg.psr ${PSR}
debugasm${OE}: debugasm.asm macros.mac
debugger${OE}: debugger.c asm_call.h zpath.h ${JMA_D}/zsnesjma.h \
	${ZIP_D}/zunzip.h
endmem${OE}: endmem.asm macros.mac
init${OE}: init.asm macros.mac
initc${OE}: initc.c asm_call.h cfg${OE} input${OE} numconv.h zpath.h \
	${CPU_D}/memtable.h ${DEBUG_D}/load.h ${JMA_D}/zsnesjma.h \
	${ZIP_D}/zunzip.h
input${OE}: input.psr ${PSR}
md${OE}: md.psr ${PSR}
patch${OE}: patch.c zpath.h ${JMA_D}/zsnesjma.h ${ZIP_D}/zunzip.h
ui${OE}: ui.c asm_call.h cfg${OE} input${OE} zpath.h ${JMA_D}/zsnesjma.h \
	${MMLIB_D}/mm.h ${ZIP_D}/zunzip.h
vcache${OE}: vcache.asm macros.mac
version${OE}: version.c
zdir${OE}: zdir.c zdir.h zpath.h ${JMA_D}/zsnesjma.h ${ZIP_D}/zunzip.h
zloader${OE}: zloader.c asm_call.h cfg${OE} input${OE} zloader.h zpath.h \
	${DEBUG_D}/load.h ${JMA_D}/zsnesjma.h ${ZIP_D}/zunzip.h
zmovie${OE}: zmovie.c asm_call.h cfg${OE} gblvars.h input${OE} md${OE} \
	numconv.h zdir.h zmovie.h zpath.h ${JMA_D}/zsnesjma.h \
	${WIN_D}/safelib.h ${ZIP_D}/zunzip.h
zpath${OE}: zpath.c cfg${OE} zpath.h ${JMA_D}/zsnesjma.h \
	${WIN_D}/lib.h ${WIN_D}/safelib.h ${ZIP_D}/zunzip.h ${CONFLOC}
zstate${OE}: zstate.c asm_call.h cfg${OE} gblvars.h input${OE} numconv.h \
	zmovie.h zpath.h ${CHIP_D}/dsp4emu.h ${JMA_D}/zsnesjma.h ${ZIP_D}/zunzip.h
ztime${OE}: ztime.asm macros.mac
ztimec${OE}: ztimec.c

${CHIP_D}/7110emu${OE}: ${CHIP_D}/7110emu.c cfg${OE} zpath.h ${JMA_D}/zsnesjma.h \
	${ZIP_D}/zunzip.h
${CHIP_D}/7110proc${OE}: ${CHIP_D}/7110proc.asm macros.mac \
	${CPU_D}/regs.mac ${CPU_D}/regsw.mac
${CHIP_D}/c4emu${OE}: ${CHIP_D}/c4emu.c
${CHIP_D}/c4proc${OE}: ${CHIP_D}/c4proc.asm macros.mac
${CHIP_D}/dsp1emu${OE}: ${CHIP_D}/dsp1emu.c
${CHIP_D}/dsp1proc${OE}: ${CHIP_D}/dsp1proc.asm macros.mac
${CHIP_D}/dsp2proc${OE}: ${CHIP_D}/dsp2proc.asm macros.mac
${CHIP_D}/dsp3emu${OE}: ${CHIP_D}/dsp3emu.c
${CHIP_D}/dsp3proc${OE}: ${CHIP_D}/dsp3proc.asm macros.mac
${CHIP_D}/dsp4emu${OE}: ${CHIP_D}/dsp4emu.c ${CHIP_D}/dsp4emu.h
${CHIP_D}/dsp4proc${OE}: ${CHIP_D}/dsp4proc.asm macros.mac
${CHIP_D}/fxemu2${OE}: ${CHIP_D}/fxemu2.asm macros.mac ${CHIP_D}/fxemu2.mac
${CHIP_D}/fxemu2b${OE}: ${CHIP_D}/fxemu2b.asm macros.mac \
	${CHIP_D}/fxemu2.mac ${CHIP_D}/fxemu2b.mac
${CHIP_D}/fxemu2c${OE}: ${CHIP_D}/fxemu2c.asm macros.mac \
	${CHIP_D}/fxemu2.mac ${CHIP_D}/fxemu2c.mac
${CHIP_D}/fxtable${OE}: ${CHIP_D}/fxtable.asm macros.mac
${CHIP_D}/obc1emu${OE}: ${CHIP_D}/obc1emu.c
${CHIP_D}/obc1proc${OE}: ${CHIP_D}/obc1proc.asm macros.mac
${CHIP_D}/sa1emu${OE}: ${CHIP_D}/sa1emu.c
${CHIP_D}/sa1proc${OE}: ${CHIP_D}/sa1proc.asm macros.mac
${CHIP_D}/sa1regs${OE}: ${CHIP_D}/sa1regs.asm macros.mac ${CPU_D}/regs.mac \
	${CPU_D}/regsw.mac
${CHIP_D}/sdd1emu${OE}: ${CHIP_D}/sdd1emu.c
${CHIP_D}/seta10${OE}: ${CHIP_D}/seta10.c
${CHIP_D}/seta11${OE}: ${CHIP_D}/seta11.c
${CHIP_D}/sfxproc${OE}: ${CHIP_D}/sfxproc.asm macros.mac ${CPU_D}/regs.mac \
	${CPU_D}/regsw.mac
${CHIP_D}/st10proc${OE}: ${CHIP_D}/st10proc.asm macros.mac
${CHIP_D}/st11proc${OE}: ${CHIP_D}/st11proc.asm macros.mac

${CPU_D}/dma${OE}: ${CPU_D}/dma.asm macros.mac
${CPU_D}/execute${OE}: ${CPU_D}/execute.asm macros.mac
${CPU_D}/executec${OE}: ${CPU_D}/executec.c gblvars.h
${CPU_D}/irq${OE}: ${CPU_D}/irq.asm macros.mac
${CPU_D}/memory${OE}: ${CPU_D}/memory.asm macros.mac
${CPU_D}/memtable${OE}: ${CPU_D}/memtable.c gblvars.h ${CPU_D}/memtable.h
${CPU_D}/stable${OE}: ${CPU_D}/stable.asm macros.mac ${CPU_D}/s65816d.inc \
	${CPU_D}/saddress.inc ${CPU_D}/saddrni.inc ${CPU_D}/se65816.inc
${CPU_D}/table${OE}: ${CPU_D}/table.asm macros.mac ${CPU_D}/65816d.inc \
	${CPU_D}/address.inc ${CPU_D}/addrni.inc ${CPU_D}/e65816.inc \
	${CPU_D}/regs.inc ${CPU_D}/regs.mac ${CPU_D}/regsw.inc \
	${CPU_D}/regsw.mac
${CPU_D}/tablec${OE}: ${CPU_D}/tablec.asm macros.mac ${CPU_D}/65816dc.inc \
	${CPU_D}/address.inc ${CPU_D}/addrni.inc ${CPU_D}/e65816c.inc
${SPC_D}/zdsp${OE}: ${SPC_D}/zdsp.cpp ${SPC_D}/b_common.h \
	${SPC_D}/b_config.h ${SPC_D}/b_endian.h ${SPC_D}/b_source.h \
	${SPC_D}/spc_dsp.h
${SPC_D}/zspc${OE}: ${SPC_D}/zspc.cpp ${SPC_D}/b_common.h \
	${SPC_D}/b_config.h ${SPC_D}/b_endian.h ${SPC_D}/b_source.h \
	${SPC_D}/disasm.c ${SPC_D}/disasm.h ${SPC_D}/resamp.c ${SPC_D}/resamp.h \
	${SPC_D}/spc_bootrom.c ${SPC_D}/spc_cpu.h ${SPC_D}/spc_dsp.h \
	${SPC_D}/spc_filt.cpp ${SPC_D}/spc_filt.h ${SPC_D}/snes_spc.cpp \
	${SPC_D}/snes_spc.h ${SPC_D}/snes_spm.cpp ${SPC_D}/snes_sps.cpp \
	${SPC_D}/zspc.h

${EFF_D}/burn${OE}: ${EFF_D}/burn.c
${EFF_D}/smoke${OE}: ${EFF_D}/smoke.c
${EFF_D}/water${OE}: ${EFF_D}/water.c ${EFF_D}/fixsin.h

${GUI_D}/guiold${OE}: ${GUI_D}/guiold.asm macros.mac ${GUI_D}/guicheat.inc \
	${GUI_D}/guicombo.inc ${GUI_D}/guikeys.inc ${GUI_D}/guimisc.inc \
	${GUI_D}/guimouse.inc ${GUI_D}/guitools.inc ${GUI_D}/guiwindp.inc
${GUI_D}/guifuncs${OE}: ${GUI_D}/guifuncs.c asm_call.h cfg${OE} input${OE} \
	md${OE} zdir.h zloader.h zpath.h ${JMA_D}/zsnesjma.h ${WIN_D}/lib.h \
	${ZIP_D}/zunzip.h
${GUI_D}/menu${OE}: ${GUI_D}/menu.asm macros.mac

${JMA_D}/7zlzma${OE}: ${JMA_D}/7zlzma.cpp ${JMA_D}/7z.h \
	${JMA_D}/aribitcd.h ${JMA_D}/ariconst.h ${JMA_D}/btreecd.h \
	${JMA_D}/iiostrm.h ${JMA_D}/inbyte.h ${JMA_D}/lencoder.h \
	${JMA_D}/litcoder.h ${JMA_D}/lzma.h ${JMA_D}/lzmadec.h \
	${JMA_D}/portable.h ${JMA_D}/rcdefs.h ${JMA_D}/rngcoder.h \
	${JMA_D}/winout.h
${JMA_D}/crc32${OE}: ${JMA_D}/crc32.cpp
${JMA_D}/iiostrm${OE}: ${JMA_D}/iiostrm.cpp ${JMA_D}/crc32.h \
	${JMA_D}/iiostrm.h ${JMA_D}/portable.h
${JMA_D}/inbyte${OE}: ${JMA_D}/inbyte.cpp ${JMA_D}/iiostrm.h \
	${JMA_D}/inbyte.h ${JMA_D}/portable.h
${JMA_D}/jma${OE}: ${JMA_D}/jma.cpp ${JMA_D}/7z.h ${JMA_D}/crc32.h \
	${JMA_D}/iiostrm.h ${JMA_D}/jma.h ${JMA_D}/portable.h
${JMA_D}/lzma${OE}: ${JMA_D}/lzma.cpp ${JMA_D}/aribitcd.h \
	${JMA_D}/ariconst.h ${JMA_D}/btreecd.h ${JMA_D}/iiostrm.h \
	${JMA_D}/inbyte.h ${JMA_D}/lencoder.h ${JMA_D}/lzma.h \
	${JMA_D}/portable.h ${JMA_D}/rcdefs.h ${JMA_D}/rngcoder.h
${JMA_D}/lzmadec${OE}: ${JMA_D}/lzmadec.cpp ${JMA_D}/aribitcd.h \
	${JMA_D}/ariconst.h ${JMA_D}/btreecd.h ${JMA_D}/iiostrm.h \
	${JMA_D}/inbyte.h ${JMA_D}/lencoder.h ${JMA_D}/litcoder.h \
	${JMA_D}/lzma.h ${JMA_D}/lzmadec.h ${JMA_D}/portable.h \
	${JMA_D}/rcdefs.h ${JMA_D}/rngcoder.h ${JMA_D}/winout.h
${JMA_D}/winout${OE}: ${JMA_D}/winout.cpp ${JMA_D}/iiostrm.h \
	${JMA_D}/portable.h ${JMA_D}/winout.h
${JMA_D}/zsnesjma${OE}: ${JMA_D}/zsnesjma.cpp ${JMA_D}/jma.h \
	${JMA_D}/zsnesjma.h

${MMLIB_D}/mm${OE}: ${MMLIB_D}/mm.c ${MMLIB_D}/mm.h
${MMLIB_D}/windows${OE}: ${MMLIB_D}/windows.c ${MMLIB_D}/mm.h

${VID_D}/2xsaiw${OE}: ${VID_D}/2xsaiw.asm macros.mac
${VID_D}/copyvwin${OE}: ${VID_D}/copyvwin.asm macros.mac
${VID_D}/hq2x16${OE}: ${VID_D}/hq2x16.asm macros.mac
${VID_D}/hq2x32${OE}: ${VID_D}/hq2x32.asm macros.mac
${VID_D}/hq3x16${OE}: ${VID_D}/hq3x16.asm macros.mac
${VID_D}/hq3x32${OE}: ${VID_D}/hq3x32.asm macros.mac
${VID_D}/hq4x16${OE}: ${VID_D}/hq4x16.asm macros.mac
${VID_D}/hq4x32${OE}: ${VID_D}/hq4x32.asm macros.mac
${VID_D}/m716text${OE}: ${VID_D}/m716text.asm macros.mac ${VID_D}/mode7.mac
${VID_D}/makev16b${OE}: ${VID_D}/makev16b.asm macros.mac ${VID_D}/vidmacro.mac
${VID_D}/makev16t${OE}: ${VID_D}/makev16t.asm macros.mac ${VID_D}/vidmacro.mac
${VID_D}/makevid${OE}: ${VID_D}/makevid.asm macros.mac
${VID_D}/mode716${OE}: ${VID_D}/mode716.asm macros.mac ${VID_D}/mode716.mac
${VID_D}/mode716b${OE}: ${VID_D}/mode716b.asm macros.mac ${VID_D}/mode7.mac
${VID_D}/mode716d${OE}: ${VID_D}/mode716d.asm macros.mac ${VID_D}/mode7.mac
${VID_D}/mode716e${OE}: ${VID_D}/mode716e.asm macros.mac ${VID_D}/mode7.mac
${VID_D}/mode716t${OE}: ${VID_D}/mode716t.asm macros.mac ${VID_D}/mode7.mac
${VID_D}/mv16tms${OE}: ${VID_D}/mv16tms.asm macros.mac ${VID_D}/vidmacro.mac
${VID_D}/newg162${OE}: ${VID_D}/newg162.asm macros.mac ${VID_D}/newg162.mac \
	${VID_D}/newg16wn.mac
${VID_D}/newgfx${OE}: ${VID_D}/newgfx.asm macros.mac
${VID_D}/newgfx16${OE}: ${VID_D}/newgfx16.asm macros.mac \
	${VID_D}/newgfx16.mac ${VID_D}/vidmacro.mac
${VID_D}/ntsc${OE}: ${VID_D}/ntsc.c ${VID_D}/ntsc.h ${NTSC_D}/snes_ntsc.c \
	${NTSC_D}/snes_ntsc.h ${NTSC_D}/snes_ntsc_config.h ${NTSC_D}/snes_ntsc_impl.h
${VID_D}/procvid${OE}: ${VID_D}/procvid.asm macros.mac
${VID_D}/procvidc${OE}: ${VID_D}/procvidc.c zmovie.h zpath.h \
	${JMA_D}/zsnesjma.h ${ZIP_D}/zunzip.h
${VID_D}/sw_draw${OE}: ${VID_D}/sw_draw.asm macros.mac

${WIN_D}/confloc${OE}: ${WIN_D}/confloc.psr ${PSR}
${WIN_D}/dx_ddraw${OE}: ${WIN_D}/dx_ddraw.cpp cfg${OE} ${WIN_D}/winlink.h
${WIN_D}/gl_draw${OE}: ${WIN_D}/gl_draw.c cfg${OE} ${WIN_D}/gl_draw.h ${WIN_D}/winlink.h
${WIN_D}/lib${OE}: ${WIN_D}/lib.c zpath.h ${JMA_D}/zsnesjma.h \
	${WIN_D}/lib.h ${ZIP_D}/zunzip.h
${WIN_D}/safelib${OE}: ${WIN_D}/safelib.c argv.h ${WIN_D}/safelib.h
${WIN_D}/winintrf${OE}: ${WIN_D}/winintrf.asm macros.mac
${WIN_D}/winlink${OE}: ${WIN_D}/winlink.cpp asm_call.h cfg${OE} input${OE} zmovie.h \
	${DEBUG_D}/load.h ${WIN_D}/gl_draw.h ${WIN_D}/resource.h ${WIN_D}/winlink.h
ifeq (${ENV},msvc)
${WIN_D}/zsnes.res: ${WIN_D}/zsnes.rc ${WIN_D}/resource.h
	rc ${WIN_D}/zsnes.rc
else
${WIN_D}/zsnes${OE}: ${WIN_D}/zsnes.rc ${WIN_D}/resource.h
	${WINDRES} --include-dir ${WIN_D} ${WIN_D}/zsnes.rc -o${WIN_D}/zsnes${OE}
${OBJFIX}: objfix.c
	gcc -O3 -s -o $@ objfix.c
endif
${PSR}: parsegen.cpp
ifeq (${ENV},msvc)
	cl /nologo /EHsc /MD /Fe$@ parsegen.cpp zlib.lib
	${DELETECOMMAND} parsegen.obj
else
	g++ -O3 -s -o $@ parsegen.cpp -lz
endif

${ZIP_D}/unzip${OE}: ${ZIP_D}/unzip.c ${ZIP_D}/zunzip.h
${ZIP_D}/zpng${OE}: ${ZIP_D}/zpng.c numconv.h zpath.h ${JMA_D}/zsnesjma.h \
	${ZIP_D}/zunzip.h

${DEBUG_D}/load${OE}: ${DEBUG_D}/load.cpp ${DEBUG_D}/load.h \
	${DEBUG_D}/ui.h ${DEBUG_D}/ui_debugger.h ${DEBUG_D}/zthread.h
${DEBUG_D}/moc_ui${OE}: ${DEBUG_D}/moc_ui.cpp ${DEBUG_D}/ui.h ${DEBUG_D}/ui_debugger.h
${DEBUG_D}/moc_ui.cpp: ${DEBUG_D}/ui.h
${DEBUG_D}/moc_zthread${OE}: ${DEBUG_D}/moc_zthread.cpp ${DEBUG_D}/zthread.h
${DEBUG_D}/moc_zthread.cpp: ${DEBUG_D}/zthread.h
${DEBUG_D}/ui${OE}: ${DEBUG_D}/ui.cpp ${DEBUG_D}/ui.h ${DEBUG_D}/ui_debugger.h
${DEBUG_D}/zthread${OE}: ${DEBUG_D}/zthread.cpp ${DEBUG_D}/load.h ${DEBUG_D}/zthread.h

${GUI_D}/gui${OE}: ${GUI_D}/gui.cpp ${GUI_D}/gui.h ${GUI_D}/ui_zsnes.h
${GUI_D}/moc_gui.cpp: ${GUI_D}/gui.h
${GUI_D}/moc_gui${OE}: ${GUI_D}/moc_gui.cpp ${GUI_D}/gui.h ${GUI_D}/ui_zsnes.h

else  #else no ENV specified
	@echo Please specify which platform to compile for with PLATFORM=platform_name
endif #endif on the ENV being empty

clean:

ifneq (${ENV},)
# Take care that the expanded text between pre and suf is less than 28 characters
	${DELPRE} ${EXE}${SEP} ${PSR}${DELSUF}
	${DELPRE} *${OE}${SEP} ${NET_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${CPU_D}${SLASH}*${OE}${SEP} ${GUI_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${JMA_D}${SLASH}*${OE}${SEP} ${MMLIB_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${EFF_D}${SLASH}*${OE}${SEP} ${ZIP_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${SPC_D}${SLASH}*${OE}${SEP} ${WIN_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${CHIP_D}${SLASH}*${OE}${SEP} ${VID_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${DEBUG_D}${SLASH}*${OE}${DELSUF}
	${DELPRE} ${DEBUG_D}${SLASH}ui_*.h${DELSUF}
	${DELPRE} ${DEBUG_D}${SLASH}moc_*.cpp${DELSUF}
else
	@echo Please specify which platform to clean for with PLATFORM=platform_name
endif


# Make sure emacs knows this is a Makefile, so it lets you put in real TABs
# Local Variables:
# mode: Makefile
# End:

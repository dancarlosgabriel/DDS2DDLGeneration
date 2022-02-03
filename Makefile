#    Makefile for DDS2DDLGeneration project.
#                                                          Scott Klement 2022-02-02
#
#    This is part of the DDS2DDLGeneration utility by Reynaldo Dandreb Medilla
#      https://github.com/dancarlosgabriel/DDS2DDLGeneration
#
#    To build (TLDR version):
#      - git clone <this repo>
#      - make LIBRARY=yourlib
#
#    More detailed instructions:
#
#    Requirements:
#      - IBM i operating system 7.3 or higher (57xx-SS1 opt base,1,3)
#      - ILE RPG compiler (57xx-WDS opt 31)
#      - QShell (57xx-SS1 opt 30)
#      - PASE (57xx-SS1 opt 33)
#      - YUM https://tinyurl.com/ibmiyum
#      - GNU Make (yum install make-gnu)
#      - Git (yum install git)
#
#    To get this repo:
#      - Start PASE. 
#          o The best way is to connect via SSH (for example, from PuTTY)
#          o If you can't use SSH, then from 5250 you can type CALL QP2TERM
#      - It is assumed that you have already set up your PASE environment with
#          the yum packages in your PATH, etc.
#      - git clone https://github.com/dancarlosgabriel/DDS2DDLGeneration.git 
#          (or if you prefer, use ssh... whatever works for you.)
#      
#    To build
#      - Log on to the PASE shell (with SSH or QP2TERM)
#      - Decide which library to compile the objects into.  This example uses 
#          a library named DDS2DDL, but you can use any library you wish
#          by substituting it into the commands below.
#
#      - Switch to the directory where you cloned the repo, for example:
#          cd ~/DDS2DDLGeneration
#
#      - To build all objects that are missing, or for which the source code has 
#        changed:
#          make LIBRARY=dds2ddl
#
#      - If you wish to delete all of the objects except the files you can type:
#           make LIBRARY=dds2ddl clean
#
#      - If you wish to delete all of the objects INCLUDING the files (and therefore
#        lose all data in the files -- for example if uninstalling) you can type:
#            make LIBRARY=dds2ddl realclean
#
#      - If you wish to force it to rebuild all programs (even if there haven't
#        been any changes), you can do this:
#           make LIBRARY=dds2ddl clean all
#
#      - If you wish to force it to delete/rebuild all programs and files (this
#        will lose all data in the files), you can do this:
#           make LIBRARY=dds2ddl realclean all
#
#      - If you wish to build the tool with debuggable sources (for example to
#        troubleshoot problems, or if you plan to help develop the tool) you can
#        add DEBUG=1 when running make.  For example:
#           make DEBUG=1 LIBRARY=dds2ddl clean all
#
#      - You can set the library and other options using environment variables 
#        if you prefer to avoid typing them each time.  For example:
#           export LIBRARY=dds2ddl
#           export DEBUG=1
#           make clean all
#            ... notice I didn't have to type the library on the make command. 
#                now I make changes to sources, try again ...
#           make
#            ... This recompiled only the programs that changed. Now I run it, but
#                I found bugs, so need to make again ...
#           make
#
#  Note: If you are changing the sources, I recommend using either RDi or VS Code.
#        and creating an IFS filter that points to the directory you cloned the
#        repo.
#          

.SECONDARY:
.PRECIOUS:

.SECONDEXPANSION:
.ONESHELL:
SHELL = /usr/bin/qsh
.SHELLFLAGS = -ec

ifneq (1,$(words [$(LIBRARY)]))
$(error LIBRARY variable is not set correctly. Set to a valid library name and try again)
endif
ifeq (,$(LIBRARY))
$(error LIBRARY variable is not set correctly. Set to a valid library name and try again)
endif

TGTRLS        ?= *current
TGTCCSID      ?= *job
ILIBRARY      := /qsys.lib/$(LIBRARY).lib
OWNER         := qpgmr
DEBUG         := 0
RPG_OPTS      := option(*seclvl)
CL_OPTS       :=
TMPSRC        := tmpsrc
ISRCFILE      := $(ILIBRARY)/$(TMPSRC).file
SRCFILE       := srcfile($(LIBRARY)/$(TMPSRC)) srcmbr($(TMPSRC))
SRCFILE2      := $(LIBRARY)/$(TMPSRC)($(TMPSRC))
SRCFILE3      := file($(LIBRARY)/$(TMPSRC)) mbr($(TMPSRC))
SRCCCSID      :=


ifeq ($(DEBUG), 1)
	DEBUG_OPTS     := dbgview(*all)
	SQL_DEBUG_OPTS := dbgview(*source)
else
	DEBUG_OPTS     := dbgview(*none) 
	SQL_DEBUG_OPTS := dbgview(*none) output(*none)
	RPG_OPTS       := $(RPG_OPTS) optimize(*full) output(*none)
	CL_OPTS        := $(CL_OPTS) optimize(*full) output(*none)
endif

define NONFILES
  GENDDLDRVR.pgm GENDDLOBJ.pgm GENDDLSRC.pgm GENDEPFILS.pgm GENDDLCMD.cmd GENFLTROBJ.pgm GENDDLLOG.pgm GENDDLCMD.pnlgrp
endef
define FILES
  GENFILTER.file GENLOGPF.file
endef


NONFILES  := $(addprefix $(ILIBRARY)/, $(NONFILES))
FILES := $(addprefix $(ILIBRARY)/, $(FILES))

GENDDLCMD.cmd_deps     := $(addprefix $(ILIBRARY)/, GENDDLDRVR.pgm)
GENDDLDRVR.pgm_deps    := $(addprefix $(ILIBRARY)/, GENFILTER.file GENFLTROBJ.pgm GENDDLSRC.pgm GENDDLOBJ.pgm GENDEPFILS.pgm)
GENDDLDRVR.pgm_deps    := $(addprefix $(ILIBRARY)/, GENFILTER.file GENDDLSRC.pgm GENDDLOBJ.pgm GENDEPFILS.pgm)
GENDDLOBJ.pgm_deps     := $(addprefix $(ILIBRARY)/, GENDDLLOG.pgm)
GENDDLSRC.pgm_deps     := $(addprefix $(ILIBRARY)/, GENDDLLOG.pgm)
GENDDLLOG.pgm_deps     := $(addprefix $(ILIBRARY)/, GENLOGPF.file)

.PHONY: all clean realclean

all: $(ILIBRARY) $(FILES) $(NONFILES)

clean: 
	system -v 'dltf file($(LIBRARY)/TMPSRC)' || true
	rm -f $(NONFILES)

realclean:
	system -v 'dltf file($(LIBRARY)/TMPSRC)' || true
	system -v 'dltf file($(LIBRARY)/GENFILTER)' || true
	system -v 'dltf file($(LIBRARY)/GENLOGPF)' || true
	rm -f $(NONFILES)

$(ILIBRARY):
	-system -v 'crtlib lib($(LIBRARY)) type(*PROD)'

$(ISRCFILE): | $(ILIBRARY)
	-system -v 'crtsrcpf rcdlen(250) $(SRCFILE3) $(SRCCCSID)'

$(ILIBRARY)/%.pgm: %.sqlrpgle | $(ILIBRARY) $$($$*.pgm_deps)
	liblist -fa $(LIBRARY) || true
	system -v 'dltpgm pgm($(LIBRARY)/$(*F))' || true
	system -v "crtsqlrpgi obj($(LIBRARY)/$(*F)) srcstmf('$(<)') objtype(*pgm) compileopt('$(RPG_OPTS)') tgtrls($(TGTRLS)) $(SQL_DEBUG_OPTS) cvtccsid($(TGTCCSID))"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

$(ILIBRARY)/%.pgm: %.rpgle | $(ILIBRARY) $$($$*.pgm_deps)
	liblist -fa $(LIBRARY) || true
	system -v 'dltpgm pgm($(LIBRARY)/$(*F))' || true
	system -v "crtbndrpg pgm($(LIBRARY)/$(*F)) srcstmf('$(<)') $(RPG_OPTS) tgtrls($(TGTRLS)) $(DEBUG_OPTS) tgtccsid($(TGTCCSID))"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

$(ILIBRARY)/%.pgm: %.clle | $(ILIBRARY) $$($$*.pgm_deps)
	liblist -fa $(LIBRARY) || true
	system -v 'dltpgm pgm($(LIBRARY)/$(*F))' || true
	system -v "crtbndcl  pgm($(LIBRARY)/$(*F)) srcstmf('$(<)') tgtrls($(TGTRLS)) $(DEBUG_OPTS) $(CL_OPTS)"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

$(ILIBRARY)/%.file: %.sql | $(ILIBRARY) $$($$*.file_deps)
	liblist -fa $(LIBRARY) || true
	system -v 'dltf file($(LIBRARY)/$(*F))' || true
	system -v "runsqlstm dftrdbcol($(LIBRARY)) srcstmf('$(<)') commit(*none)"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

$(ILIBRARY)/GENDDLCMD.cmd: GENDDLCMD.cmd $(ILIBRARY)/GENDDLCMD.pnlgrp $(ILIBRARY)/GENDDLDRVR.pgm | $(ILIBRARY) $(GENDDLCMD.cmd_deps)
	liblist -fa $(LIBRARY) || true
	system -v 'dltcmd cmd($(LIBRARY)/GENDDLCMD)' || true
	system -v "crtcmd cmd($(LIBRARY)/GENDDLCMD) pgm(*libl/GENDDLDRVR) srcstmf('$(<)') hlppnlgrp(*libl/GENDDLCMD) hlpid(*cmd)"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

$(ILIBRARY)/%.pnlgrp: %.pnlgrp | $(ISRCFILE) $$($$*.pnlgrp_deps) 
	liblist -fa $(LIBRARY) || true
	cat '$(<)' | Rfile -wQ '$(SRCFILE2)'
	system -v "crtpnlgrp pnlgrp($(LIBRARY)/$(*F)) $(SRCFILE)"
	system -v "chgobjown obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) newown($(OWNER)) curownaut(*revoke)"
	system -v "grtobjaut obj($(LIBRARY)/$(basename $(@F))) objtype(*$(subst .,,$(suffix $(@F)))) user(*public) aut(*use) replace(*yes)"

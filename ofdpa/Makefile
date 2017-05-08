################################################################
#
# Makefile for ofdpa P4 project
#
################################################################

export TARGET_ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

include ../../init.mk

ifndef P4FACTORY
P4FACTORY := $(TARGET_ROOT)/../..
endif
MAKEFILES_DIR := ${P4FACTORY}/makefiles

# This target's P4 name
export P4_INPUT := p4src/ofdpa.p4
export P4_NAME := ofdpa

# Common defines targets for P4 programs
include ${MAKEFILES_DIR}/common.mk

# Put custom targets in ofdpa-local.mk
-include ofdpa-local.mk

all:bm


BOARD_DEFCONFIG= xxxx_defconfig
PROJECT= XXXX
PROJECT_DOTCONFIG= .config

ROOT_PATH := $(shell pwd)/$(ROOT_PATH)
PROJECT_DIR := src/platfrom/$(PROJECT)
# Environments
PYTHON_EXECUTABLE := /usr/bin/python3
ifneq ($(PROJECT_DOTCONFIG), )
DOTCONFIG := $(PROJECT_DOTCONFIG)
else
$(error "Kconfig required DOTCONFIG environment value")
endif
BOARD_DIR := $(PROJECT_DIR)
SOC_DIR := $(PROJECT_DIR)
KCONFIG_ROOT := $(ROOT_PATH)/Kconfig
srctree := $(ROOT_PATH)
AUTOCONF_H_DIR := $(ROOT_PATH)/src/include
AUTOCONF_H := $(AUTOCONF_H_DIR)/sdkconfig.h

KCONFIG_PHONY := menuconfig mrproper
.PHONY += $(KCONFIG_PHONY)

all:

$(DOTCONFIG):
	$(Q)$(MAKE) $(BOARD_DEFCONFIG)

$(AUTOCONF_H):
	$(Q)$(MAKE) $(BOARD_DEFCONFIG)

menuconfig: ${AUTOCONF_H_DIR}
	PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} \
	srctree=${ROOT_PATH} \
	SDK_VERSION=${SDK_VERSION} \
	BOARD_DEFCONFIG_NAME=$(ROOT_PATH)/$(PROJECT_DIR)/gcc/defconfig/${BOARD_DEFCONFIG} \
	KCONFIG_CONFIG=${DOTCONFIG} \
	ARCH=${ARCH} \
	BOARD_DIR=${BOARD_DIR} \
	SOC_DIR=${SOC_DIR} \
	${PYTHON_EXECUTABLE} ${ROOT_PATH}scripts/Kconfiglib/menuconfig.py ${KCONFIG_ROOT}
	if [ -f ${DOTCONFIG} ]; then \
		srctree=${ROOT_PATH} \
		${PYTHON_EXECUTABLE} \
		${ROOT_PATH}/scripts/Kconfiglib/kconfig.py \
		${KCONFIG_ROOT} \
		${DOTCONFIG} \
		${AUTOCONF_H} \
		${DOTCONFIG}; \
	fi

%_defconfig: $(ROOT_PATH)/$(PROJECT_DIR)/gcc/defconfigs/%_defconfig
	$(Q)mkdir -p ${AUTOCONF_H_DIR} && \
	PYTHON_EXECUTABLE=${PYTHON_EXECUTABLE} \
	BOARD_DEFCONFIG_NAME=$(ROOT_PATH)/$(PROJECT_DIR)/gcc/defconfigs/$@ \
	srctree=${ROOT_PATH} \
	${PYTHON_EXECUTABLE} \
	${ROOT_PATH}/scripts/Kconfiglib/kconfig.py \
	${KCONFIG_ROOT} \
	${DOTCONFIG} \
	${AUTOCONF_H} \
	$(PROJECT_DIR)/gcc/defconfigs/$@ && \
	echo "Generated autoconf by $@"

savedefconfig:
	$(Q)if [ -f ${DOTCONFIG} ]; then \
		cp -f ${DOTCONFIG} ${CONFIG_BOARD_DEFCONFIG}; \
		sed -i '/CONFIG_BOARD_DEFCONFIG/d' ${CONFIG_BOARD_DEFCONFIG}; \
	fi

mrproper:
	$(Q)-rm -rf $(AUTOCONF_H)
	$(Q)-rm -f $(ROOT_PATH)/$(PROJECT_DIR)/gcc/.config

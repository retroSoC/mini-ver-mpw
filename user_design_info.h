#ifndef _RETROSOC_USER_DESIGN_INFO_DEF_H_
#define _RETROSOC_USER_DESIGN_INFO_DEF_H_

typedef struct {
    char *name;
    char *isa;
    char *maintainer;
    char *repo;
} design_info;

const design_info user_core_info[] = {
    {"name", "isa", "maintainer", "repo"},
    {"PicoRV32", "rv32imc", "YosysHQ", "https://github.com/YosysHQ/picorv32"},
};

const design_info user_ip_info[] = {
    {"name", "isa", "maintainer", "repo"},
    {"archinfo", "none", "maksyuki", "https://github.com/retroSoC/archinfo"},
};

#endif
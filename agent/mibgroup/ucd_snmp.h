/* module to include the various ucd-snmp specific extension modules. */
config_require(proc)
config_require(versioninfo)
config_require(pass)
config_require(disk)
config_require(loadave)
config_require(extensible)
config_require(errormib)
config_require(registry)
config_arch_require(linux, memory)
config_arch_require(hpux9, memory)
config_arch_require(hpux10, memory)
config_arch_require(hpux9, hpux)
config_arch_require(hpux10, hpux)
config_arch_require(bsdi2, memory)
config_arch_require(bsdi3, memory)
config_arch_require(linux, vmstat)
config_add_mib(UCD-SNMP-MIB) 

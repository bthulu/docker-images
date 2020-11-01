#!/bin/bash
# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with Oracle installation
# ------------------------------------------------------------
# Creating Directories, Install Required Softwares
mkdir -p $ORACLE_BASE/scripts/setup && \
mkdir $ORACLE_BASE/scripts/startup && \
ln -s $ORACLE_BASE/scripts /docker-entrypoint-initdb.d && \
mkdir $ORACLE_BASE/oradata && \
mkdir -p $ORACLE_HOME && \
chmod ug+x $ORACLE_BASE/*.sh && \
yum -y install binutils compat-libcap1 compat-libstdc++-33 gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel libXi libXtst make sysstat openssl && \
yum clean all

# Configuring Kernel Parameters
echo "# sysctl settings are defined through files in
# /usr/lib/sysctl.d/, /run/sysctl.d/, and /etc/sysctl.d/.
#
# Vendors settings live in /usr/lib/sysctl.d/.
# To override a whole file, create a new file with the same in
# /etc/sysctl.d/ and put new settings there. To override
# only specific settings, add a file with a lexically later
# name in /etc/sysctl.d/ and put new settings there.
#
# For more information, see sysctl.conf(5) and sysctl.d(5).

# oracle-rdbms-server-11gR2-preinstall setting for fs.file-max is 6815744
fs.file-max = 6815744

# oracle-rdbms-server-11gR2-preinstall setting for kernel.sem is '250 32000 100 128'
kernel.sem = 250 32000 100 128

# oracle-rdbms-server-11gR2-preinstall setting for kernel.shmmni is 4096
kernel.shmmni = 4096

# oracle-rdbms-server-11gR2-preinstall setting for kernel.shmall is 2097152 on i386
kernel.shmall = 1073741824

# oracle-rdbms-server-11gR2-preinstall setting for kernel.shmmax is 4294967295 on i386
kernel.shmmax = 4398046511104

# oracle-rdbms-server-11gR2-preinstall setting for kernel.panic_on_oops is 1 per Orabug 19212317
kernel.panic_on_oops = 1

# oracle-rdbms-server-11gR2-preinstall setting for net.core.rmem_default is 262144
net.core.rmem_default = 262144

# oracle-rdbms-server-11gR2-preinstall setting for net.core.rmem_max is 4194304
net.core.rmem_max = 4194304

# oracle-rdbms-server-11gR2-preinstall setting for net.core.wmem_default is 262144
net.core.wmem_default = 262144

# oracle-rdbms-server-11gR2-preinstall setting for net.core.wmem_max is 1048576
net.core.wmem_max = 1048576

# oracle-rdbms-server-11gR2-preinstall setting for net.ipv4.conf.all.rp_filter is 2
net.ipv4.conf.all.rp_filter = 2

# oracle-rdbms-server-11gR2-preinstall setting for net.ipv4.conf.default.rp_filter is 2
net.ipv4.conf.default.rp_filter = 2

# oracle-rdbms-server-11gR2-preinstall setting for fs.aio-max-nr is 1048576
fs.aio-max-nr = 1048576

# oracle-rdbms-server-11gR2-preinstall setting for net.ipv4.ip_local_port_range is 9000 65500
net.ipv4.ip_local_port_range = 9000 65500
" > /etc/sysctl.conf
/sbin/sysctl -p

# Configuring Resource Limits for the Oracle Software Installation Users
echo "
# oracle-rdbms-server-11gR2-preinstall setting for nofile soft limit is 1024
oracle   soft   nofile    1024

# oracle-rdbms-server-11gR2-preinstall setting for nofile hard limit is 65536
oracle   hard   nofile    65536

# oracle-rdbms-server-11gR2-preinstall setting for nproc soft limit is 16384
# refer orabug15971421 for more info.
oracle   soft   nproc    16384

# oracle-rdbms-server-11gR2-preinstall setting for nproc hard limit is 16384
oracle   hard   nproc    16384

# oracle-rdbms-server-11gR2-preinstall setting for stack soft limit is 10240KB
oracle   soft   stack    10240

# oracle-rdbms-server-11gR2-preinstall setting for stack hard limit is 32768KB
oracle   hard   stack    32768

oracle   hard   memlock    134217728

# oracle-rdbms-server-11gR2-preinstall setting for memlock hard limit is maximum of 128GB on x86_64 or 3GB on x86 OR 90 % of RAM
oracle   soft   memlock    134217728" >> /etc/security/limits.conf

# Creating Required Operating System Groups and Users
groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper
useradd -g oinstall -G dba,oper oracle

# Change Directory Owner To Oracle
ln -s $ORACLE_BASE/$PWD_FILE /home/oracle/ && \
echo oracle:oracle | chpasswd && \
chown -R oracle:dba $ORACLE_BASE

#!/bin/bash
# disk health  plugin for Nagios

# Nagios return codes
#定义 nagios返回的状态变量
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3      

# Paths to commands used in this script.  These may have to be modified to match your system setup.
# 定义关键的核心命令smartctl 路径 如果你的系统不是这个地址，请更改。 以下注释的是调试的信息，是自动获取命令路径的方法。
SMARTCTL="/usr/sbin/smartctl"
#SMARTCTL=`which smartctl`
#if [ $? -ne 0 ]; then
#        echo " smartctl is found in $SMARTCTL ; Go on ... "
#        echo "smartctl the command cannot find"
#        exit $STATE_UNKNOWN
#fi
# Plugin parameters value if not define
# 定义默认的检测硬盘
CHECK_DISK="/dev/sda"                  

# Plugin variable description
# 插件描述信息
PROGNAME=$(basename $0)
RELEASE="Revision 1.2.0"
AUTHOR="(c) 2009 Ajian (ajian521@gmail.com)"

# Functions plugin usage
# 插件的使用方法函数
print_release() {
    echo "$RELEASE $AUTHOR"
}                          

print_usage() {
        echo ""
        echo "$PROGNAME $RELEASE - Disk health check script for Nagios"
        echo ""
        echo "Usage: check_disk_health.sh -d /dev/sdb"
        echo ""
        echo "  -d  the disk (/dev/sda) "
        echo "          not the Hard disk partition(sda2 is wrong)"
        echo "  -v  check the version"
        echo "  -h  Show this page"
        echo ""
    echo "Usage: $PROGNAME"
    echo "Usage: $PROGNAME --help"
    echo ""
    exit 0
}                                                                                                          

print_help() {
        print_usage
        echo ""
        echo "This plugin will check disk health  "
        echo ""
        exit 0
}                                                  

# Parse parameters
# 传递参数
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)
            print_help
            exit $STATE_OK
            ;;
        -v | --version)
                print_release
                exit $STATE_OK
                ;;
        -d | --disk)
                shift
                CHECK_DISK=$1
                #判断磁盘是否存在
                if [ ! -b $CHECK_DISK ];then
                        echo "$CHECK_DISK is no exsit,Please change it "
                        exit $STATE_CRITICAL
                fi
                ;;
        *)  echo "Unknown argument: $1"
            print_usage
            exit $STATE_UNKNOWN
            ;;
        esac
shift
done

# 根据不同的操作进行不同的操作，这里暂时只支持Linux
case `uname` in
        Linux )
             #最核心的部分 前面都是些脚本的基本功能 一个框架 因为第一个脚本牵扯到了很多东西，虽然功能很简单，
             #但折腾了我不少，在后面的分析中会具体说到 总之注意sudo用法 脚本一开始就有说哦
                DISK_HEALTH=`$SMARTCTL  -H $CHECK_DISK | tail -1 | cut -d: -f2- `
                #DISK_HEALTH="OK"
        #       DISK_INFO=`/usr/bin/sudo $SMARTCTL -i $CHECK_DISK | grep "Device:"`
                if [ "$DISK_HEALTH" = " OK" ]|| [  "$DISK_HEALTH" = " PASSED" ];then
                        echo "OK - $CHECK_DISK status is $DISK_HEALTH "
                        #echo "OK - $CHECK_DISK status is $DISK_HEALTH | $DISK_INFO"
                        exit $STATE_OK
                else
                        echo "CRITICAL - $CHECK_DISK status is $DISK_HEALTH "
                        #echo "CRITICAL - $CHECK_DISK status is $DISK_HEALTH | $DISK_INFO"
                        exit $STATE_CRITICAL
        fi
            ;;

        *)              echo "UNKNOWN: 'uname' not yet supported by this plugin. Coming soon !"
                        exit $STATE_UNKNOWN
            ;;
        esac
# 基于原生 OpenWrt 的 Dragino2 固件

## 说明

- ipv4: 192.168.33.1:8083
- username: root
- password: password

外网ssh 端口8022
外网ftp和samba默认打开端口

## tips: create patch files
```
git add .
git commit -m "set some change by default"
git format-patch -s -1,2...
```

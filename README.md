# macos-inode-mon-replacement

## 功能主治：

1. 扫除系统日志 `system.log` 中每 10 秒报一次的 iNodeMon 重启信息(原始 iNodeMon 大概从catalina开始有问题，服务总是启动失败)
2. 每分钟检测 `AuthenMngService` 进程状态,并执行一下操作
   - 如果退出，则启动(原 iNodeMon 服务功能)(macOS，iNode 客户端版本 E517); 
   - 如果 cpu 占用超过 80%，则重启;

## 部署方法

1. 使用 `sudo -s` （输入自己用户的密码）来切换至超级用户;
2. 用附件中的 `iNodeMon` 来替换 `/Applications/iNodeClient/iNodeMon`, 记得备份;
3. 使用命令 `chmod a+x /Applications/iNodeClient/iNodeMon` 来赋予可执行权限;
4. 执行 `/Applications/iNodeClient/StopService.sh` 来停掉现在的服务;
5. 执行 `/Library/StartupItems/iNodeAuthService/iNodeAuthService start` 来启动服务;
6. 使用 `exit` 或者 **`CTRL`** + **`D`** 退出超级用户;


## 一些说明

- 由于 iNode 本身的启动脚本使用的 ps 命令观察进程状态是不支持脚本的,所以这个 iNodeMon 是通过 `shc` 来编译脚本,生成可执行程序
- 使用 `ps -ef | grep -Hin inode` 可以看到 `iNodeMon` 的脚本内容;
- 安装 `shc` 可以使用 `brew install shc` 来进行(不要问我 brew 是什么,我也不会告诉你不装后悔一辈子，前往[官网](https://brew.sh)自行了解。
- 使用 `shc -r -f iNodeMon.sh -o iNodeMon` 即可对脚本进行编译并生成可执行.
- 日志位置在 `/Library/Logs/iNode/` 每天转存`.log` 为`.old`

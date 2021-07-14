# macos-inode-mon-replacement

## 主要用途

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

## 关于可执行文件

- 由于 iNode 本身的启动脚本观察晋城状态使用的 `ps` 命令是不支持查看脚本运行状态的的，所以通过 `shc` 来编译脚本,生成可执行程序；
- 如果不想使用附件里面的 `inodeMon` 可以自行安装 `shc`，可以使用 `brew install shc` 来进行，`brew` 的使用可以前往[官网](https://brew.sh)自行了解。
- 执行 `shc -r -f iNodeMon.sh -o iNodeMon` 即可对脚本进行编译并生成可执行.

## 关于日志

- 日志位置在 `/Library/Logs/iNode/` 每天转存`.log` 为`.old`

## inode.sh的使用

> 安装了inodeClient之后，在macOS系统启动时inode服务也会自动启动，如果不希望它自动启动，并在需要时手动启动，可以使用 `inode.sh`；

1. 首先执行以下命令，来取消inode相关服务在macOS启动是自动启动

   ```bash
      sudo launchctl unload /Library/LaunchDaemons/com.apple.iNodeClient.plist
      sudo rm -f /Library/LaunchDaemons/com.apple.iNodeClient.plist
   ```

2. 将 `inode.sh` 放在 **`${PATH}`** 能找到的位置，例如 `/usr/local/bin/` 下；
3. 执行 `inode.sh start|stop|restart` 来启动启动|停止|重启 `inode` 服务；

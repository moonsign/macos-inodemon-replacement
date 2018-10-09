#macos-inode-mon-replacement
##功能主治(macOS，iNode客户端版本E517)：

1. 扫除系统日志system.log中没10秒报一次的iNodeMon重启信息(原始iNodeMon有问题，服务总是启动失败)
2. 每分钟检测AuthenMngService进程状态,并执行一下操作
	- 如果退出，则启动(原iNodeMon服务功能)(macOS，iNode客户端版本E517);
	- 如果cpu占用超过80%，则重启(新增功能);

#部署方法：

1. 使用 sudo -s （输入自己用户的密码）来切换至超级用户;
2. 用附件中的iNodeMon来替换 /Applications/iNodeClient/iNodeMon 记得备份;
3. 使用命令 chmod a+x /Applications/iNodeClient/iNodeMon 来赋予可执行权限;
4. 执行 /Applications/iNodeClient/StopService.sh 来停掉现在的服务;
5. 执行 /Library/StartupItems/iNodeAuthService/iNodeAuthService start 来启动服务;
6. 退出超级用户;

- 日志位置在 /Library/Logs/iNode/ 每天转存.log 为.old

#一些说明:

- 由于iNode本身的启动脚本使用的ps命令观察进程状态是不支持脚本的,所以这个iNodeMon是通过shc来编译脚本,生成可执行程序
- 使用 ps -ef可以轻松看到 iNodeMon的脚本内容;
- 安装shc 可以使用 brew install shc 来进行(不要问我brew是什么,我也不会告诉你不装后悔一辈子,这里自行了解 https://brew.sh)
- 使用 shc -r -f iNodeMon.sh -o iNodeMon 即可对脚本进行编译并生成可执行.
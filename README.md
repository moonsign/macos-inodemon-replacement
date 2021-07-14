# ✨macos-inode-mon-replacement

> 从macOS catalina开始，**`iNodeMon`** 会遇到服务启动失败的问题😫，而且在macbook💻休眠或者断开电源时，**`AuthenMngService`** 进程可能会出现cpu占用过高的问题🥵。

## 💊 功能主治

* ✅扫除系统日志 **`system.log`** 中每 10 秒报一次的 iNodeMon 重启信息；

* ✅每分钟检测 **`AuthenMngService`** 进程状态，并执行以下操作：
  * 服务退出自动重新启动；

  * 如果cpu占用超过 **`80%`**，则重新启动;

## 🔨 部署方法

1. 切换至超级用户，并根据提示输入 **当前用户** 的密码；

   ```bash
   sudo -s
   ```

2. 停掉当前的inode相关服务；

   ```bash
   /Applications/iNodeClient/StopService.sh
   ```

3. 备份原始的 **`/Applications/iNodeClient/iNodeMon`** 文件；

   ```bash
   mv /Applications/iNodeClient/iNodeMon /Applications/iNodeClient/iNodeMon~origin
   ```

4. 使用下载的可执行文件 **`iNodeMon`** 放回指定的位置 **`/Applications/iNodeClient/`**；

   ```bash
   mv /path/to/downloaded/iNodeMon/ /Applications/iNodeClient/
   ```

5. 对新的 **`iNodeMon`** 赋予可执行权限；

   ```bash
   chmod a+x /Applications/iNodeClient/iNodeMon
   ```

6. 重新启动inode相关服务；

   ```bash
   /Library/StartupItems/iNodeAuthService/iNodeAuthService start
   ```

7. 使用 **`exit`** 或者 **`CTRL`** + **`D`** 退出超级用户;

## 🗄 关于可执行文件

* 由于iNode本身的启动脚本观察进程状态使用的 **`ps`** 命令是不支持查看脚本运行状态的的，所以需要将bash脚本转换为可执行程序；
* 如果不想使用附件里面的 **`inodeMon`** 可以自行安装 **`shc`**，可以使用 **`brew install shc`** 来进行，**`brew`** 的使用可以前往[官网](https://brew.sh)自行了解。
* 脚本进行编译并生成可执行需要在超级用户下进行，参考 **部署方法** 中切换超级用户的方法
  
   ```bash
   cd /Applications/iNodeClient/
   ```

   ```bash
   shc -r -f iNodeMon.sh -o iNodeMon
   ```

## 📃 关于日志

* 日志位置在 **`/Library/Logs/iNode/`** 每天转存 **`.log`** 为 **`.old`**

## 🚫 防止inode随macOS启动

> 安装了inodeClient之后，在macOS系统启动时inode服务也会自动启动。
>
> 如果不希望它自动启动，并在需要时手动启动，可以卸载自启动的配置，并使用 **`inode.sh`**；

1. 首先执行以下命令，来取消inode相关服务在macOS启动是自动启动

   ```bash
   sudo launchctl unload /Library/LaunchDaemons/com.apple.iNodeClient.plist
   ```

   ```bash
   sudo rm -f /Library/LaunchDaemons/com.apple.iNodeClient.plist
   ```

2. 将 **`inode.sh`** 放在 **`${PATH}`** 能找到的位置，例如 **`/usr/local/bin/`** 下；

   ```bash
   mv /path/to/downloaded/inode.sh /usr/local/bin/
   ```

3. 赋予 **`inode.sh`** 可执行权限；

   ```bash
   chmod a+x /usr/local/bin/inode.sh
   ```

4. 执行 **`inode.sh start|stop|restart`** 来启动启动|停止|重启 **`inode`** 服务；

   ```bash
   inode.sh start
   ```

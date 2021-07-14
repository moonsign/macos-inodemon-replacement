#!/bin/sh
authService="/Library/StartupItems/iNodeAuthService/iNodeAuthService"
if [[ $1 =~ ^(start|stop|restart)$ ]]; then
    if [[ $1 == "stop" ]]; then
        sudo launchctl unload /Library/LaunchDaemons/com.apple.iNodeClient.plist
    fi
    sudo "${authService}" $1
else
    if [ $1 ]; then
        echo "parameter should be start, stop or restart"
        exit 1
    fi
    read -p "Restart inode service? (y/n): " input
    if [[ "${input}" =~ ^(y|yes)$ ]]; then
        sudo "${authService}" restart
    fi
fi

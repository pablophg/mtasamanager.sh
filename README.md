# mtasamanager.sh

mtasamanager.sh is a standalone Linux bash script that installs, configures and runs a Multi Theft Auto: San Andreas server.

> The script is able to detect the right packages to be installed on the server, download MTA:SA linux server files and default resources, install them, prompt for the correct configuration such as server name, ports, password... If the script detects an installed server, it will check if the server is running or not, and then ask if it should start or stop the server.

*It was tested on 32 and 64 bit Debian 7 servers. It should also work on Ubuntu distributions.*

### How to use it:

Just place mtasamanager.sh on the directory where you want the server to be installed and run it:

```sh
chmod +x mtasamanager.sh
./mtasamanager.sh
```

Then just follow the instructions.
Execute the script again if you want to start or stop the server.

![Alt text](http://i.imgur.com/ArQcdtk.png)
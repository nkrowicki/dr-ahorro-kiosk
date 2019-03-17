# Use Raspbian as Website display

Proyect developed for Farmacias Dr Ahorro.

0. Start Raspbian (on Raspberry Pi)
1. Use the default user
2. Run this script
3. Adjust the website url on instalation
4. If necessary (due to an unresponsive dashboard or a superlarge screen), change the zoom factor on config file (1 = 100%, 0.5 = 50%, 2 = 200%)

Note: This software generates a file called 'kiosk.log' which contains events that happen (errors, warnings and information)

## How to install:
Open terminal and run the following command:

git clone https://github.com/nkrowicki/dr-ahorro-kiosk.git && cd dr-ahorro-kiosk && sudo bash install.sh

## How to reinstall:
Open terminal and run the following command: (replace "DIRECTORY" for the directory where the project is located)
cd DIRECTORY
sudo rm -rf dr-ahorro-kiosk/
git clone https://github.com/nkrowicki/dr-ahorro-kiosk.git && cd dr-ahorro-kiosk && sudo bash install.sh

## Developer contact

To contact the developer directly, email nahuelkrowicki@gmail.com

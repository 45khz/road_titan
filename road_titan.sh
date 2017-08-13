###################  Made by 45khz   ####################
########## ROADWARRIOR DEAMONSAW ROUTER SETUP ###########
########## https://github.com/45khz/road_titan ##########

#Vars
FILEPATHDS="$HOME"
ROUTER_ADDRESS="0.0.0.0"
HOME_ADDRESS="127.0.0.1"
WAN_ADDRESS="$(wget -qO- ipv4.icanhazip.com)"
LAN_ADDRESS="$(ip addr | grep 'inet' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"
TUN_ADRESS="$(ip addr | grep 'tun0' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | head -1)"
PORT_NUMBER="8080"

#Welcome screen
clear
echo ""
echo ""
echo "██████╗  ██████╗  █████╗ ██████╗     ████████╗██╗████████╗ █████╗ ███╗   ██╗"
echo "██╔══██╗██╔═══██╗██╔══██╗██╔══██╗    ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║"
echo "██████╔╝██║   ██║███████║██║  ██║       ██║   ██║   ██║   ███████║██╔██╗ ██║"
echo "██╔══██╗██║   ██║██╔══██║██║  ██║       ██║   ██║   ██║   ██╔══██║██║╚██╗██║"
echo "██║  ██║╚██████╔╝██║  ██║██████╔╝       ██║   ██║   ██║   ██║  ██║██║ ╚████║"
echo "╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝        ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝"
echo "----------------------------------------------------------------------------"
echo "    Welcom to the Roadwarrior's installation of Demonsaw (Titan) router     "
echo "----------------------------------------------------------------------------"
echo ""

#check if screen is present
if which screen >/dev/null; then
  echo "Perfect you already have screen installed"
else
  echo "looks like your missing screen lets fix that, its used so we can run Demonsaw in the background"
  echo "The code that is going to be run is (apt update && apt install screen && apt install unzip)"
  su -c 'apt update && apt install screen && apt install unzip'
fi

#Install path
read -e -p "Enter where you want Demonsaw to be installed if untouched Default path= " -i "$FILEPATHDS" FILEPATHDS
echo "You entered: $FILEPATHDS"

#download
if [ ! -f $FILEPATHDS/demonsaw/demonsaw_router ]; then
  mkdir $FILEPATHDS/demonsaw
  wget https://demonsaw.com/download/demonsaw_router.zip -P /tmp/
  unzip /tmp/demonsaw_router.zip -d $FILEPATHDS/demonsaw/
  rm /tmp/demonsaw_router.zip*
else
  echo "you already have demonsaw downloaded and extracted it, nice"
fi

#Make .toml
if [ ! -f $FILEPATHDS/demonsaw/nix_64/demonsaw.toml ]; then
  echo "demonsaw.toml not found, lets fix that!"
  touch $FILEPATHDS/demonsaw/nix_64/demonsaw.toml
 else
  echo "looks like you already have the config file (demonsaw.toml) let's update"
fi
clear

#Get ip adress
echo "-- WAN if the router is hosted on VPS"
echo ""
echo "-- LAN if the router is hosted from your home (needs portforward on the router)"
echo ""
echo "-- VPN if the router is hosted from home over a VPN (VPN needs to support portforward you need to set up the portforwarding youself) "
echo ""
echo "-- Local for tesing only"
echo ""
echo "Enter how the router are going be hosted"
  echo "   1) WAN $WAN_ADDRESS (External VPS)"
  echo "   2) LAN $LAN_ADDRESS (Internal Home)"
  echo "   3) VPN $TUN_ADRESS (VPN with portforward)"
  echo "   4) LOCAL $HOME_ADDRESS (Localhost)"
   read -p "Select an option [1-4]:" ROUTER_ADDRESS
 case $ROUTER_ADDRESS in
1)
ROUTER_ADDRESS="$WAN_ADDRESS"
;;
2)
ROUTER_ADDRESS="$LAN_ADDRESS"
;;
3)
ROUTER_ADDRESS="$TUN_ADRESS"
;;
4)
ROUTER_ADDRESS="$HOME_ADDRESS"
;;
esac
clear

#Port for the server
read -e -p "Enter what port Demonsaw will talk on (most be 1024 or above can be forwarded with iptables, Default port=:" -i "$PORT_NUMBER" PORT_NUMBER
echo "You entered: $PORT_NUMBER"

#make executable
chmod +x $FILEPATHDS/demonsaw/nix_64/demonsaw_router
clear

#Make the .toml file
(echo -e "[[router]]\nenable = true\nthreads = 128\nname = 'message router 1'\naddress = '$ROUTER_ADDRESS'\npassword = ''\nport = "$PORT_NUMBER"\n[router.option]\nbuffer_size = 32\nmotd = 'Roadwarriors Titan router'\nredirect = 'https://demonsaw.com'\n[[router.room]]\nenable = true\nname = 'Room#1'\ncolor = 'ff52c175'\n[[router.room]]\nenable = true\nname = 'Room#2'\ncolor = 'ff0c9bdc'\n[[router.room]]\nenable = true\nname = 'Room#3'\ncolor = 'ffff029d'\n" )>$FILEPATHDS/demonsaw/nix_64/demonsaw.toml

#finnish
echo "-- Config Done --"
echo ""
echo "-- Your router is going to be avalible at ip $ROUTER_ADDRESS:$PORT_NUMBER"
echo ""
echo "-- If you selected to host it at home you need to setup portforward on $LAN_ADDRESS:$PORT_NUMBER then you can connect with $WAN_ADDRESS:$PORT_NUMBER"
echo ""
echo "-- If you selected to host it over a VPN $WAN_ADDRESS:$PORT_NUMBER"
echo ""
echo "What do you want to do now?"
  echo "   1) Start router (one time)"
  echo "   2) Start router on boot (Presistance)"
  echo "   3) Start router (window only, testing)"
  echo "   4) Exit)"
   read -p "Select an option [1-4]:" ROUTER_START
 case $ROUTER_START in
1)
 cd "$FILEPATHDS/demonsaw/nix_64/"
 screen -h 1024 -dmS demonsaw ./demonsaw_router
 clear
  echo "one time background service now active"
  echo "The router is now avalible at $ROUTER_ADDRESS:$PORT_NUMBER"
  echo "to enter the screen session enter (screen -r demonsaw) WITHOUT () into terminal"
  echo "Your done, have a nice day"
;;
2)
 touch $FILEPATHDS/demonsaw/nix_64/autostart
 (crontab -l 2>/dev/null; echo "@reboot bash $FILEPATHDS/demonsaw/nix_64/autostart") | crontab -
 (echo -e "cd $FILEPATHDS/demonsaw/nix_64\nscreen -h 1024 -dmS demonsaw ./demonsaw_router")>$FILEPATHDS/demonsaw/nix_64/autostart
 cd "$FILEPATHDS/demonsaw/nix_64/"
 screen -h 1024 -dmS demonsaw ./demonsaw_router
 clear
echo ""
echo "██╗    ██╗███████╗██╗      ██████╗ ██████╗ ███╗   ███╗███████╗"
echo "██║    ██║██╔════╝██║     ██╔════╝██╔═══██╗████╗ ████║██╔════╝"
echo "██║ █╗ ██║█████╗  ██║     ██║     ██║   ██║██╔████╔██║█████╗  "
echo "██║███╗██║██╔══╝  ██║     ██║     ██║   ██║██║╚██╔╝██║██╔══╝  "
echo "╚███╔███╔╝███████╗███████╗╚██████╗╚██████╔╝██║ ╚═╝ ██║███████╗"
echo " ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝"
echo ""
echo "████████╗ ██████╗     ████████╗██╗████████╗ █████╗ ███╗   ██╗ "
echo "╚══██╔══╝██╔═══██╗    ╚══██╔══╝██║╚══██╔══╝██╔══██╗████╗  ██║ "
echo "   ██║   ██║   ██║       ██║   ██║   ██║   ███████║██╔██╗ ██║ "
echo "   ██║   ██║   ██║       ██║   ██║   ██║   ██╔══██║██║╚██╗██║ "
echo "   ██║   ╚██████╔╝       ██║   ██║   ██║   ██║  ██║██║ ╚████║ "
echo "   ╚═╝    ╚═════╝        ╚═╝   ╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝ "
echo "----------------------------------------------------------------------------"
echo "Presistance added and router avalibe on start up"
echo "The router is now avalible at $ROUTER_ADDRESS:$PORT_NUMBER"
echo "Your done, have a nice day"
echo "----------------------------------------------------------------------------"
;;
3)
clear
 echo "Your done, have a nice day"
 echo "The router is now avalible at $ROUTER_ADDRESS:$PORT_NUMBER"
  cd "$FILEPATHDS/demonsaw/nix_64/"
  ./demonsaw_router
;;
4)
exit 0
;;
esac

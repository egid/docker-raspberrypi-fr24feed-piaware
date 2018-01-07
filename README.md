# Fr24feed and FlightAware with dump1090-mutability as a Docker image for Raspberry PI
Docker image of Fr24feed, FlightAware and dump1090-mutability for Raspberry PI.

Feed FlightRadar24 and FlightAware, allow you to see the positions of aircrafts on a map.

![Image of dump1090 webapp](https://raw.githubusercontent.com/dmorehouse/docker-raspberrypi-fr24feed-piaware-dump1090-mutability/master/screenshot.png)
# Usage
Go to http://dockerhost:8080/gmap.html to view a map of retrieved data (screenshot above).  (dockerhost ==> localhost on the Raspberry PI itself)

Go to http://dockerhost:8754 to view fr24feed configuration panel.

# Requirements
- Raspberry PI B+, 2, 3, Zero W, Zero (probably if you add network connectivity)
- Docker on Raspberry PI
- RTL-SDR DVBT USB Dongle (RTL2832)

# Run as Docker Image (highly recommended and easiest route)
(see below if you want to build the Docker image yourself (it takes over an hour to build/compile))

## Install Docker (if you don't have it yet)
There's a lot of ways to get Docker but the simplest way to get the latest stable version is
```bash 
curl -sSL https://get.docker.com | sh
```

## Set Receiver Location (this determines where the map is centered) 
Download and edit [`config.js`](https://raw.githubusercontent.com/dmorehouse/docker-raspberrypi-fr24feed-piaware-dump1090-mutability/master/config.js) to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;             // position of the marker
SiteLon     = 2.5;
SiteName    = "Home";         // tooltip of the marker
```

## Verify the Docker image runs / detects RTL-SDR / flight data collection is working
No point in registering to submit your Flight data to the services below if you can't gather flight data.
```bash
docker run -it -p 8080:8080 -p 8754:8754 \
--privileged --device=/dev/bus/usb:/dev/bus/usb \
--mac-address="ff:ff:ff:ff:ff:ff" \
-v /absolute/path/to/your/config.js:/usr/lib/fr24/public_html/config.js \
REPLACE/fr24feed-piaware
```
### Check that everything is working
Goto http://dockerhost:8080/gmap.html (dockerhost is probably localhost).  If you see an error in the bottom left saying "Problem fetching data from dump1090" something isn't working
Look at the console/terminal window you started docker from and look for errors if the map isn't working.

If things didn't work and you see errors about "exec wrong/invalid exec format" then you will need to go Building the Docker image on yourself on YOUR raspberry pi.  Otherwise double check the above steps and the console output for hints as to what isn't quite working.

If everything worked (you didn't see any errors on the bottom left of the map screen), use Control-C to kill the docker container and proceed to steps below to actually send the received flight data to FlightAware and FlightRadar and also actually run the docker container as a docker container in the background.  So proceed below.

## FlightAware Registration
Register to https://flightaware.com/account/join/.

Download and edit [`piaware.conf`](https://raw.githubusercontent.com/dmorehouse/docker-raspberrypi-fr24feed-piaware-dump1090-mutability/master/piaware.conf)

Replace `flightaware-user YOUR_USERNAME` with your username (ex: `flightaware-user JohnDoe`) and `flightaware-password YOUR_PASSWORD` with your password (ex: `flightaware-password azerty`).

## FlightRadar24 Registration
Make sure you enter the MAC address of your raspberry pi's active network interface.  You can get it with ```ifconfig eth0 | grep --color "HWaddr .*"``` for Ethernet connections, or ```ifconfig wlan0 | grep --color "HWaddr .*"``` for Wireless connections.

```bash
docker run -it --privileged -v /dev/bus/usb:/dev/bus/usb \
--mac-address="ff:ff:ff:ff:ff:ff" \
--entrypoint /fr24feed/fr24feed_armhf/fr24feed REPLACE_WITH_DOCKER_IMAGE --signup
```
Enter your email address
If you do NOT already have a sharing key (which you probably don't) just hit Enter
Yes for MLAT
Enter nearest airport code (it does NOT have to be within 20 miles, this just skips LOTS of additional questions.  The lat/lon you entered into config.js above is what needs to be accurate)
Yes to continue
1 for 48 hours
/var/log (doesn't matter we override this)

You should see a response like this
```
Congratulations! You are now registered and ready to share ADS-B data with Flightradar24.
+ Your sharing key (xxxxxxxxxxxxxxxx) has been configured and emailed to you for backup purposes.
+ Your radar id is YYYYYYY, please include it in all email communication with us.
+ Please make sure to start sharing data within the next 3 days as otherwise your ID/KEY will be deleted.

Thank you for supporting Flightradar24! We hope that you will enjoy our Premium services that will be available to you when you become an active feeder.
```
REPLACE_REMOVE Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Make a copy of your 16 character sharing key AND your radar id.  Contrary to the notice they do NOT email either to you.  The sharing key is needed to submit your data, the radar id is needed if you want to look up your stats on the leaderboard.

Download and edit [`fr24feed.ini`](https://raw.githubusercontent.com/dmorehouse/docker-raspberrypi-fr24feed-piaware-dump1090-mutability/master/fr24feed.ini)
Replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).

### Terrain-limit rings (optional and you probably don't need it):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=1000,10000 as upintheair.json.

*Note : the "id" value XXXX correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*

*Note add ```-v /path/to/your/upintheair.json:/usr/lib/fr24/public_html/upintheair.json \``` after the piaware.conf line in the docker run command below

## Installation / Run as a service

Run : 
```
docker run -d -p 8080:8080 -p 8754:8754 \
--device=/dev/bus/usb:/dev/bus/usb \
--mac-address="ff:ff:ff:ff:ff:ff" \
-v /path/to/your/piaware.conf:/etc/piaware.conf \
-v /path/to/your/config.js:/usr/lib/fr24/public_html/config.js \
-v /path/to/your/fr24feed.ini:/etc/fr24feed.ini \
REPLACE_IMAGE
```
Change `--mac-address="ff:ff:ff:ff:ff:ff"` with your own MAC address.  See above for instructions on how to get this.


# Build Docker image yourself

## FlightAware
Register to https://flightaware.com/account/join/.

Edit `piaware.conf` and replace `user YOUR_USERNAME` with your username (ex: `user JohnDoe`) and `password YOUR_PASSWORD` with your password (ex: `password azerty`).
## Dump1090
### Receiver location
Edit `config.js` to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```
## FlightRadar24
Register to https://www.flightradar24.com/share-your-data and get a sharing key.

Edit `fr24feed.ini` and replace `fr24key="YOUR_KEY_HERE"` with your key (ex: `fr24key="a23165za4za56"`).
## Dump1090
### Receiver location
Edit `config.js` to suite your receiver location and name:
```javascript
SiteShow    = true;           // true to show a center marker
SiteLat     = 47;            // position of the marker
SiteLon     = 2.5;
SiteName    = "Home"; // tooltip of the marker
```
### Terrain-limit rings (optional):
If you don't need this feature ignore this.

Create a panorama for your receiver location on http://www.heywhatsthat.com.

Download http://www.heywhatsthat.com/api/upintheair.json?id=XXXX&refraction=0.25&alts=1000,10000 place the file upintheair.json in this directory and uncomment `#COPY upintheair.json /usr/lib/fr24/...` from Dockerfile.

*Note : the "id" value XXXX correspond to the URL at the top of the panorama http://www.heywhatsthat.com/?view=XXXX, altitudes are in meters, you can specify a list of altitudes.*
## Installation
Edit `docker-compose.yml` and replace `mac-address: ff:ff:ff:ff:ff:ff` with your own MAC address.
Run : `docker-compose up`


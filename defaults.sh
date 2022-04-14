#!/bin/bash
#
#
#
#           Created by A.Hodgson                     
#            Date: 2022-03-24                            
#            Purpose: Configure test machine to my preferred defaults upon re-enrollment
#
#
#
#############################################################
loggedInUser=$(/bin/ls -l /dev/console | /usr/bin/awk '{ print $3 }')

function configure_dock(){
	# Variables
	dockutil="/usr/local/bin/dockutil"
	userdock="/Users/$loggedInUser/Library/Preferences/com.apple.dock.plist"
	# Install DockUtil
	if [ -f "$dockutil" ]; then
		echo "Dockutil is already installed..."
	else 
		echo "Installing Dockutil..."
		URL=$(curl -v https://api.github.com/repos/kcrawford/dockutil/releases/latest 2>&1 | grep -v ant | grep browser_download_url | grep -v .asc | cut -d '"' -f 4)
		curl -sLo /tmp/dockutil.pkg $URL
		installer -pkg /tmp/dockutil.pkg -target /
		rm -rf /tmp/dockutil.pkg
	fi
	echo "Configuring Dock..."
	$dockutil --remove all --restart $userdock
	sleep 3
	$dockutil --add "/Applications/Safari.app" $userDock
	sleep 1
	$dockutil --add "/Applications/Google Chrome.app" $userDock
	sleep 1
	$dockutil --add "/System/Applications/Utilities/Terminal.app" $userDock
	sleep 1
	$dockutil --add '~/Downloads' --view grid --display folder $userDock
	sleep 2
	defaults write $userdock orientation -string bottom
	defaults write $userdock autohide -bool true
	defaults write $userdock show-recents -bool false
	# kill system processes that prevent dock updates
	killall cfprefsd
	killall Dock
	# mod permissions so dock can be executed
	chown $loggedInUser $userdock
	chmod 775 $userdock
}

function install_chrome(){
	if [ -d "/Applications/Google Chrome.app" ]; then
		echo "Chrome is already installed..."
	else
		echo "Installing Chrome..."
		curl -sLo "/tmp/chrome.dmg" https://dl.google.com/chrome/mac/universal/stable/CHFA/googlechrome.dmg
		TMPMOUNT=`/usr/bin/mktemp -d /tmp/chrome.XXXX`
		/usr/bin/hdiutil attach "/tmp/chrome.dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen
		cp -Rp $TMPMOUNT/"Google Chrome.app" /Applications
		sleep 2
		/usr/bin/hdiutil detach "$TMPMOUNT"
		rm -rf "$TMPMOUNT"
		rm -rf "/tmp/chrome.dmg"
	fi
}

function install_sublime(){
	if [ -d "/Applications/Sublime Text.app" ]; then
		echo "Sublime is already installed..."
	else 
		echo "Installing Sublime..."
		URL=$(curl -v https://www.sublimetext.com/download 2>&1| grep "mac.zip" | sed 's/^[^"]*"\([^"]*\)".*/\1/')
		curl -sLo /tmp/sublime.zip $URL
		unzip -qq /tmp/sublime.zip
		mv "Sublime Text.app" /Applications
		rm -rf /tmp/sublime.zip
	fi
}
#############################################################
# MAIN
#############################################################
echo "Setting Timezone..."
/usr/sbin/systemsetup -settimezone America/Chicago
#############################################################
echo "Setting Name..."
if [ $(/usr/bin/arch) == "arm64" ]; then 
	name="Counterfeit-Sky"
else
	name="Distorted-Fields"
fi
/usr/sbin/scutil --set ComputerName "$name"
/usr/sbin/scutil --set LocalHostName "$name"
/usr/sbin/scutil --set HostName	"$name"
#############################################################
echo "Setting Desktop picture..."
curl -sLo /tmp/desktop.png 'https://drive.google.com/uc?export=download&id=1Aw-YTYQ3eeoTsILhc_PLxy1dGu8NDweK'
sleep 3
chmod 775 /tmp/desktop.png
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/tmp/desktop.png"'
#############################################################
echo "Configuring Finder..."
defaults write /Users/$loggedInUser/Library/Preferences/com.apple.finder.plist FXPreferredViewStyle -string "Nlsv"
defaults write /Users/$loggedInUser/Library/Preferences/com.apple.finder.plist ShowHardDrivesOnDesktop -bool true
chown $loggedInUser /Users/$loggedInUser/Library/Preferences/com.apple.finder.plist
chmod 775 /Users/$loggedInUser/Library/Preferences/com.apple.finder.plist
killall cfprefsd
killall Finder
#############################################################
install_chrome
install_sublime
configure_dock

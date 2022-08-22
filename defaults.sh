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
	$dockutil --add "~/Downloads" --view grid --display folder $userDock
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
		curl -sLo /tmp/sublime.zip "https://www.sublimetext.com/download_thanks?target=mac"
		unzip -qq /tmp/sublime.zip
		mv "Sublime Text.app" /Applications
		rm -rf /tmp/sublime.zip
	fi
}

function install_1password() {
	if [ -d "/Applications/1Password.app" ]; then
		echo "1Password is already installed..."
	else
		if [[ $(arch) == "arm64" ]]; then
        	archiveName="1Password-latest-aarch64.zip"
        	op_latestVer_download="https://downloads.1password.com/mac/1Password-latest-aarch64.zip"
    	elif [[ $(arch) == "i386" ]]; then
        	archiveName="1Password-latest-x86_64.zip"
        	op_latestVer_download="https://downloads.1password.com/mac/1Password-latest-x86_64.zip"
    	fi
		curl -sLo /tmp/1pass.zip "${op_latestVer_download}"
		unzip -qq /tmp/1pass.zip
		mv "1password.app" /Applications
		rm -rf /tmp/1pass.zip
	fi
}

function install_asana() {
	if [ -d "/Applications/Asana.app" ]; then
		echo "Asana is already installed..."
	else
		curl -sLo /tmp/asana.dmg "https://desktop-downloads.asana.com/darwin_x64/prod/latest/Asana.dmg"
		TMPMOUNT=`/usr/bin/mktemp -d /tmp/asana.XXXX`
		/usr/bin/hdiutil attach "/tmp/asana.dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen
		cp -Rp $TMPMOUNT/"Asana.app" /Applications
		sleep 2
		/usr/bin/hdiutil detach "$TMPMOUNT"
		rm -rf "$TMPMOUNT"
		rm -rf "/tmp/asana.dmg"
	fi
}

function install_githubdesktop() {
	if [ -d "/Applications/Github Desktop.app" ]; then
		echo "Github Desktop is already installed..."
	else
		if [ "$arch" == "arm64" ]; then
			downloadURL="https://central.github.com/deployments/desktop/desktop/latest/darwin-arm64"
		else
			downloadURL="https://central.github.com/deployments/desktop/desktop/latest/darwin"
		fi
		curl -sLo /tmp/github.zip "${downloadURL}"
		unzip -qq /tmp/github.zip
		mv "Github Desktop.app" /Applications
		rm -rf /tmp/github.zip
	fi
}

function install_slack() {
	if [ -d "/Applications/Slack.app" ]; then
		echo "Slack is already installed..."
	else
		if [ "$arch" == "arm64" ]; then
			slackDownload="https://slack.com/ssb/download-osx-silicon"
		else
			slackDownload="https://slack.com/ssb/download-osx"
		fi
		curl -sLo /tmp/slack.dmg "$slackDownload"
		TMPMOUNT=`/usr/bin/mktemp -d /tmp/slack.XXXX`
		/usr/bin/hdiutil attach "/tmp/slack.dmg" -mountpoint "$TMPMOUNT" -nobrowse -noverify -noautoopen
		cp -Rp $TMPMOUNT/"Slack.app" /Applications
		sleep 2
		/usr/bin/hdiutil detach "$TMPMOUNT"
		rm -rf "$TMPMOUNT"
		rm -rf "/tmp/slack.dmg"
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
curl -sLo /Users/Shared/desktop.png 'https://drive.google.com/uc?export=download&id=1Aw-YTYQ3eeoTsILhc_PLxy1dGu8NDweK'
sleep 3
chmod 775 /Users/Shared/desktop.png
osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/Users/Shared/desktop.png"'
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
install_1password
install_asana
install_githubdesktop
install_slack
configure_dock

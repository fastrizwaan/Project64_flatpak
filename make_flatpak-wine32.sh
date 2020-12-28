#!/bin/bash
# Project64 version 1.6 was created with this
# see build.sh 
# depends on 32 bit version of flatpak-wine https://github.com/fastrizwaan/flatpak-wine

# Start the process

echo "1.  Cleaning up previous target		[x]"

#remove target 
rm -rf ./target/


ARGV="$@" ; #saving program creation as commandline.sh

NAME="$1"; shift ;
APP="$1"; shift  ;
EXE="$1"; shift  ;

NICE_NAME=$(echo $(echo "$NAME" | sed 's/[A-Z]/ \0/g'))
DOT_NAME=$(echo "$NICE_NAME" | tr " " . )
WINEEXE="/app/bin/wine"
ARCH="i386"

#Output
echo "2.  Creating new target directory	[x]"

mkdir -p target/package/files/bin
mkdir -p target/package/files/lib
mkdir -p target/package/export/share/applications
mkdir -p target/package/export/share/icons/hicolor/48x48/apps/
mkdir -p target/\[flatpak-wine32\]$DOT_NAME

#Output
echo "3.  Creating run.sh script for sandbox	[x]"

cat << EOF > target/package/files/bin/run.sh
#!/bin/bash
mkdir -p /tmp/wine.$$.prefix/
export WINEPREFIX=~/.local/share/flatpak-wine32/$NAME/
export WINEDLLOVERRIDES="mscoree=d;mshtml=d;"
export LD_LIBRARY_PATH=$(pwd):$LD_LIBRARY_PATH:/app/lib:/app/$NAME:/app/lib/wine

export WINEEXE="$WINEEXE"

cd "/app/$(basename "$APP")"

if [ -e flatpak-wine32.md ] ; then
	cat flatpak-wine32.md | sed -e "s|FLATPAKNAME|org.flatpakwine32.$NAME|" -e "s|WINEPREFIX|\$WINEPREFIX|"
fi

if [ -e pj64_plugin.reg ] ; then
	$WINEEXE regedit /C pj64_plugin.reg
fi


if [ "\$1" == "winecfg" ] ; then
	$WINEEXE winecfg
elif [ "\$1" == "regedit" ] ; then
	$WINEEXE regedit
elif [ -e run.sh ] ; then
	sh run.sh \$@
	exit $?
elif [ "\$1" == "bash" ] ; then
	bash 

# on 1st run, copy Project64 to ~/.local/share/flatpak-wine32/$NAME/
elif [ ! -f ~/.local/share/flatpak-wine32/$NAME/1st-run-done.txt ];
     then
     cp -r /app/Project64_v164/ ~/.local/share/flatpak-wine32/$NAME/ && \
     touch ~/.local/share/flatpak-wine32/$NAME/1st-run-done.txt && \
     chmod a+rwx ~/.local/share/flatpak-wine32/$NAME/Project64_v164 -R
     cd ~/.local/share/flatpak-wine32/$NAME/Project64_v164 && \
     $WINEEXE "$EXE" \$@


else
	#normal startup
        cd ~/.local/share/flatpak-wine32/$NAME/Project64_v164/
	$WINEEXE "$EXE" \$@
	exit $?
fi
EOF


echo "4.  Creating flatpak metadata 		[x]"

cat << EOF >target/package/metadata
[Application]
name=org.flatpakwine32.$NAME
runtime=org.freedesktop.Platform/$ARCH/18.08
command=run.sh

[Context]
features=devel;multiarch;
shared=network;ipc;
sockets=x11;pulseaudio;wayland;
devices=all;
filesystems=xdg-documents;~/games;~/Games;~/.local/share/flatpak-wine32/$NAME:create
EOF

echo "5.  Creating flatpak install script	[x]"

cat << EOF >target/\[flatpak-wine32\]$DOT_NAME/install.sh
#!/bin/bash
# Installs game bundle for user.
# You can delete everything after installation.

DIR=\$(dirname "\$0")
set -ex
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true
flatpak --user install -y --app --bundle "\$DIR/$NAME.flatpak" || echo "Installation failed. Check if you have Flatpak properly configured. See http://flatpak.org/ for more info."
EOF

echo "6.  Creating flatpak uninstall script	[x]"
cat << EOF >target/\[flatpak-wine32\]$DOT_NAME/uninstall.sh
#!/bin/bash
# You can as well use package manager to uninstall the game
echo You can as well use package manager to uninstall the game

set -ex
flatpak --user uninstall org.flatpakwine32.$NAME
EOF

echo "7.  Creating flatpak run script		[x]"
cat << EOF >target/\[flatpak-wine32\]$DOT_NAME/run.sh
#!/bin/bash
set -ex
flatpak run org.flatpakwine32.$NAME \$@
EOF

echo "8.  Creating desktop shortcut 		[x]"
cat << EOF >target/package/export/share/applications/org.flatpakwine32.$NAME.desktop
[Desktop Entry]
Version=1.0
Name=$NICE_NAME
Exec=run.sh
Icon=org.flatpakwine32.$NAME
StartupNotify=true
Terminal=false
Type=Application
Categories=Game;
Keywords=wine;flatpak;emulation
EOF

echo "9.  Copying icon file	 		[x]"
# If custom icon.png is provided by the flatpak maker
#set -ex
## adding ImageMagicks's convert for different icon support for non gnome desktops
if [ -e "$APP"/icon.png ]; then 
   cp "$APP"/icon.png \
   target/package/export/share/icons/hicolor/48x48/apps/org.flatpakwine32.$NAME.png;
else
   echo "    Extracting icon from $EXE file"
   # Extract Icon and copy
   # dnf install icoutils ImageMagick
   wrestool -x --output=. -t14 "$APP"/"$EXE" ; #extracts ico file
   convert "*.ico" "hello.png"; #this will get ping files as hello-0...hellol7.png

   #hello-0.png is the highest resolution 256x256 (some has 48x48)
   #so copy hello-0.png as icon
   cp hello-0.png target/package/export/share/icons/\
hicolor/48x48/apps/org.flatpakwine32.$NAME.png;

fi


#remove ico and png files
rm -f hello-?.png $EXE*.ico

echo "10. Copying all files 	 		[x]"
cp -rd "$APP" target/package/files/
#32 bit wine files are copied to 
cp -rf ../flatpak-wine/files/* target/package/files

chmod +x target/package/files/bin/run.sh
chmod +x target/\[flatpak-wine32\]$DOT_NAME/install.sh
chmod +x target/\[flatpak-wine32\]$DOT_NAME/uninstall.sh
chmod +x target/\[flatpak-wine32\]$DOT_NAME/run.sh
cp "$0" target/package/files/make_flatpak-wine32.sh
echo "$0" "$ARGV" > target/package/files/commandline.sh

echo "11. Building flatpak 			[x]"
flatpak build-export target/repo target/package
flatpak build-bundle --arch=$ARCH target/repo target/\[flatpak-wine32\]$DOT_NAME/$NAME.flatpak org.flatpakwine32.$NAME

echo "12. Flatpak made! 			[x]"

# Project64_flatpak
Finally, Project64 on Linux, without headaches.
This flapak is Project64 version 1.6 created using flatpak-wine. It includes GLideN64.dll with which Project64 can go fullscreen without any issues on gnome-shell too.
Nintendo 64 Games work smoothly at 60 fps. 
Project64 is most compatible and mature emulator than any Linux Nintendo64 emulator.

Version 2 is there but it won't run, and there are other issues with settings.

# Install existing Project64 1.6 flatpak
```
git clone https://github.com/fastrizwaan/Project64_flatpak
cd Project64_flatpak
cd  \[flatpak-wine32\]Project64/
sh ./install.sh 
sh ./run.sh
```
# Build on your own
```
git clone https://github.com/fastrizwaan/Project64_flatpak
Project64_flatpak
sh build.sh
```
After build completes, `target/\[flatpak-wine32\]Project64/` has the flatpak

# Playing Nintendo 64 Games/ROM
```
Copy ROMs to ~/Games directory
and Load the ROM from Project64 emulator
```

# build project64 flapak

# Needs flathub and sdk
flatpak --user remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo -y
flatpak install --user flathub org.freedesktop.Platform/i386/18.08 org.freedesktop.Sdk/i386/18.08 -y

# Now Get git repo
mkdir -p ~/Project64-Flatpak

cd ~/Project64-Flatpak
git clone https://github.com/fastrizwaan/flatpak-wine
git clone https://github.com/fastrizwaan/Project64_flatpak

# build
cd Project64_flatpak
./make_flatpak-wine32.sh Project64 Project64_v164/ Project64.exe



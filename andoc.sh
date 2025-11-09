#!/bin/bash
set -e

# ----------------------------
# Android Emulator Docker Setup for Arch Linux
# ----------------------------

echo "📦 Installing host dependencies..."
sudo pacman -Syu --noconfirm qemu virt-manager libvirt base-devel git wget unzip mesa libpulse xorg-xhost docker docker-compose

sudo systemctl enable --now libvirtd
sudo systemctl enable --now docker

if [ ! -e /dev/kvm ]; then
    echo "❌ Error: /dev/kvm not found. Enable virtualization in BIOS/UEFI."
    exit 1
fi

WORKDIR="$HOME/android-docker"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "🧱 Creating Dockerfile..."
cat > Dockerfile << 'EOF'
FROM archlinux:latest

# ----------------------------
# Base System Setup
# ----------------------------
RUN pacman -Syu --noconfirm \
    git wget unzip base-devel qemu libglvnd libpulse mesa xorg-xhost \
    jdk-openjdk sudo curl python

ENV JAVA_HOME=/usr/lib/jvm/default
ENV PATH=$JAVA_HOME/bin:$PATH

# ----------------------------
# Android SDK Setup
# ----------------------------
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/emulator:$ANDROID_SDK_ROOT/platform-tools:$PATH

RUN mkdir -p $ANDROID_SDK_ROOT
WORKDIR $ANDROID_SDK_ROOT

# Download and structure cmdline-tools properly
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O cmdline-tools.zip \
    && unzip -q cmdline-tools.zip -d cmdline-tools-temp \
    && mkdir -p cmdline-tools/latest \
    && mv cmdline-tools-temp/cmdline-tools/* cmdline-tools/latest/ \
    && rm -rf cmdline-tools-temp cmdline-tools.zip

# Accept all licenses safely
RUN yes | sdkmanager --licenses || true
RUN sdkmanager --update

# ----------------------------
# Install Android SDK Components (with retry)
# ----------------------------
RUN for i in 1 2 3; do sdkmanager "platform-tools" && break || sleep 30; done
RUN for i in 1 2 3; do sdkmanager "emulator" && break || sleep 30; done
RUN for i in 1 2 3; do sdkmanager "system-images;android-33;google_apis;x86_64" && break || sleep 30; done

# ----------------------------
# Create and Configure AVD
# ----------------------------
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-33;google_apis;x86_64" --force

# ----------------------------
# Expose Ports and Launch Command
# ----------------------------
EXPOSE 5554 5555 5901

CMD ["emulator", "-avd", "test", "-no-snapshot-save", "-gpu", "swiftshader_indirect", "-no-window", "-qemu", "-vnc", ":1"]
EOF

echo "🔧 Building Docker image (this may take a while)..."
docker build --network=host -t android-emulator .

echo "🚀 Starting Android emulator container..."
docker run --rm --privileged --device /dev/kvm:/dev/kvm -p 5555:5555 -p 5901:5901 android-emulator

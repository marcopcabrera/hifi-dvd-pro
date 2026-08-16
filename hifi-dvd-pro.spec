Name:           hifi-dvd-pro
Version:        1.0.0
Release:        1%{?dist}
Summary:        Interactive Bash script designed for creating and authoring professional Hi-Fi Audio DVDs

License:        GPL-3.0-or-later
URL:            https://github.com/marcopcabrera/hifi-dvd-pro
Source0:        %{url}/archive/refs/tags/v%{version}.tar.gz

BuildArch:      noarch

Requires:       bash
Requires:       ffmpeg
Requires:       dvdauthor
Requires:       genisoimage
Requires:       ncurses
Requires:       coreutils
Requires:       procps-ng
Recommends:     libnotify

%description
HiFi DVD Pro is an interactive Bash script designed for creating and authoring
professional Hi-Fi Audio DVDs (VIDEO_TS folders and/or .iso disc images) from
lossless (FLAC, WAV) or compressed (MP3, OGG, M4A, AAC) audio files,
incorporating album artwork as a static background during playback.

%prep
%autosetup -n %{name}-%{version}

%build
# Paquete de solo scripts, no requiere compilación.

%install
mkdir -p %{buildroot}%{_bindir}
# NOTA: Si tu archivo fuente en GitHub se llama 'hifi-dvd-pro.sh', cámbialo aquí a 'hifi-dvd-pro.sh'
install -p -m 0755 hifi-dvd-pro %{buildroot}%{_bindir}/%{name}

%files
%license LICENSE
%doc README.md
%{_bindir}/%{name}

%changelog
* Sun Aug 16 2026 Marco P. Cabrera <graphinux@gmail.com> - 1.0.0-1
- First packaged version for Fedora.

# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
GCONF_DEBUG="no"

URELEASE="vivid"
inherit base gnome2 ubuntu-versionator

UURL="mirror://ubuntu/pool/main/g/${PN}"

DESCRIPTION="Collection of GSettings schemas for GNOME desktop"
HOMEPAGE="http://www.gnome.org/"
SRC_URI="${UURL}/${MY_P}.orig.tar.xz
        ${UURL}/${MY_P}-${UVER}.debian.tar.xz"

LICENSE="LGPL-2.1+"
SLOT="0"
IUSE="+introspection"
#KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~x64-macos ~sparc-solaris ~x86-solaris"

RDEPEND="
	>=dev-libs/glib-2.31:2
	introspection? ( >=dev-libs/gobject-introspection-1.31.0 )
	>=x11-themes/gnome-backgrounds-3.8.1
	x11-themes/gtk-engines-unico
	x11-themes/ubuntu-themes
	x11-themes/ubuntu-wallpapers
	!<gnome-base/gdm-3.8
"
DEPEND="${RDEPEND}
	>=dev-util/intltool-0.40
	sys-devel/gettext
	virtual/pkgconfig
"

src_prepare() {
	for patch in $(cat "${WORKDIR}/debian/patches/series" | grep -v '#'); do
		PATCHES+=( "${WORKDIR}/debian/patches/${patch}" )
	done
	PATCHES+=( "${FILESDIR}/nautilus_show_desktop_icons.diff" )

        base_src_prepare
	gnome2_src_prepare

	# Set Ambiance as the default window theme #
	sed -e '/gtk-theme/{n;s/Adwaita/Ambiance/}' \
		-i schemas/org.gnome.desktop.wm.preferences.gschema.xml.in.in  \
			schemas/org.gnome.desktop.interface.gschema.xml.in.in

	# Set Ubuntu-mono-dark as the default icon theme #
	sed -e '/icon-theme/{n;s/Adwaita/ubuntu-mono-dark/}' \
		-i schemas/org.gnome.desktop.interface.gschema.xml.in.in

	# Set default Ubuntu release backgrounds #
	sed -e "s:backgrounds/gnome/adwaita-timed.xml:backgrounds/contest/${URELEASE}.xml:" \
		-i schemas/org.gnome.desktop.background.gschema.xml.in.in
}

src_configure() {
	DOCS="AUTHORS HACKING NEWS README"
	gnome2_src_configure $(use_enable introspection)
}
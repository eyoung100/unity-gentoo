# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
PYTHON_COMPAT=( python{3_3,3_4} )

URELEASE="utopic"
inherit distutils-r1 gnome2-utils ubuntu-versionator

UURL="mirror://ubuntu/pool/universe/i/${PN}"

DESCRIPTION="CPU frequency scaling indicator for the Unity desktop environment"
HOMEPAGE="https://launchpad.net/classicmenu-indicator"
SRC_URI="${UURL}/${PN}_${PV}.orig.tar.gz
	${UURL}/${PN}_${PV}-${UVER}.debian.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
RESTRICT="mirror"

RDEPEND="dev-libs/glib:2
	dev-libs/libappindicator
	dev-python/dbus-python[${PYTHON_USEDEP}]
	dev-python/pygobject:3[${PYTHON_USEDEP}]
	sys-power/cpufrequtils
	x11-libs/gtk+:3"
DEPEND="${RDEPEND}
	dev-util/intltool
	sys-devel/gettext
	virtual/pkgconfig
	${PYTHON_DEPS}"

src_prepare() {
	# Allow users to use the indicator #
	sed -e 's:auth_admin_keep:yes:' \
		-i indicator_cpufreq/com.ubuntu.indicatorcpufreq.policy.in
}

src_install() {
	distutils-r1_src_install

	insinto /var/lib/polkit-1/localauthority/50-local.d
	doins "${WORKDIR}/debian/indicator-cpufreq.pkla"

	doman "${WORKDIR}/debian/indicator-cpufreq.1"
	doman "${WORKDIR}/debian/indicator-cpufreq-selector.1"

	insinto /etc/xdg/autostart
	doins "${ED}usr/share/applications/indicator-cpufreq.desktop"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	gnome2_icon_cache_update
}

pkg_postrm() {
	gnome2_icon_cache_update
}

# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python{3_6,3_7} )
DISTUTILS_SINGLE_IMPL=1

URELEASE="disco"
inherit distutils-r1 eutils ubuntu-versionator

UVER_PREFIX="+17.10.${PVR_MICRO}"

DESCRIPTION="Photo lens for the Unity desktop"
HOMEPAGE="https://launchpad.net/unity-lens-photos"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

# Let people emerge this by default, bug #472932
IUSE+=" +python_single_target_python3_6 python_single_target_python3_7"
RESTRICT="mirror"

RDEPEND="dev-libs/libgee
	net-libs/liboauth
	net-libs/libsoup
	$(python_gen_cond_dep '
		dev-libs/dee[${PYTHON_MULTI_USEDEP}]
		dev-python/pygobject[${PYTHON_MULTI_USEDEP}]
		dev-libs/libunity[${PYTHON_MULTI_USEDEP}]
		dev-python/httplib2[${PYTHON_MULTI_USEDEP}]
		dev-python/oauthlib[${PYTHON_MULTI_USEDEP}]
	')
	media-gfx/shotwell
	unity-base/unity
	unity-base/unity-language-pack
	${PYTHON_DEPS}"

S="${WORKDIR}"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare() {
	ubuntu-versionator_src_prepare
	distutils-r1_src_prepare
}

src_install() {
	distutils-r1_src_install

	# Remove all installed language files as they can be incomplete #
	#  due to being provided by Ubuntu's language-pack packages #
	rm -rf "${ED}usr/share/locale"

	python_fix_shebang "${ED}"
}

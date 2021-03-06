# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python2_7 )

URELEASE="disco"
inherit autotools eutils python-single-r1 ubuntu-versionator vala

UVER_PREFIX="+18.04.${PVR_MICRO}"

DESCRIPTION="Application indicators used by the Unity desktop"
HOMEPAGE="https://launchpad.net/libappindicator"
SRC_URI="${UURL}/${MY_P}${UVER_PREFIX}.orig.tar.gz
	${UURL}/${MY_P}${UVER_PREFIX}-${UVER}.diff.gz"

LICENSE="LGPL-2.1 LGPL-3"
SLOT="3/1.0.0"
KEYWORDS="~amd64 ~x86"
IUSE="+introspection java mono test"
RESTRICT="mirror"

# legacy dep #
#dev-libs/xapian:=
#dev-libs/xapian-bindings[python]
DEPEND="dev-libs/dbus-glib
	dev-libs/glib:2
	dev-libs/libdbusmenu:=
	dev-libs/libindicator:3=
	dev-perl/XML-LibXML
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	$(python_gen_cond_dep '
		dev-python/dbus-python[${PYTHON_MULTI_USEDEP}]
		dev-python/pygobject:2[${PYTHON_MULTI_USEDEP}]
		dev-python/pygtk[${PYTHON_MULTI_USEDEP}]
		dev-python/pyxdg[${PYTHON_MULTI_USEDEP}]
	')

	introspection? ( >=dev-libs/gobject-introspection-1:= )
	java? ( dev-java/jayatana )
	mono? ( dev-dotnet/gtk-sharp:2 )

	$(vala_depend)
	${PYTHON_DEPS}"

S="${WORKDIR}"
MAKEOPTS="${MAKEOPTS} -j1"

pkg_setup() {
	ubuntu-versionator_pkg_setup
	python-single-r1_pkg_setup
}

src_prepare () {
	eapply "${WORKDIR}/${MY_P}${UVER_PREFIX}-${UVER}.diff" # This needs to be applied for the debian/ directory to be present #
	ubuntu-versionator_src_prepare

	eapply "${FILESDIR}/${PN}-optional-mono.patch"

	# gio-unix-2.0 needs to be explicitly set so gtk-2.0 can find gio-unix-2.0 includes #
	sed '/gio-2.0/a gio-unix-2.0' -i configure.ac

	if use mono; then
		# The /usr/lib/cli location for Mono bindings is specific to Ubuntu
		sed -e 's:assemblydir = $(libdir)/cli/appindicator-sharp-0.1:assemblydir = $(libdir)/appindicator-sharp-0.1:' \
			-i bindings/mono/Makefile.am
		sed -e 's:assemblies_dir=${libdir}/cli/appindicator-sharp-0.1:assemblies_dir=${libdir}/appindicator-sharp-0.1:' \
			-i bindings/mono/appindicator-sharp-0.1.pc.in

		export CSC="/usr/bin/mcs"	# Mono-4* (needed for gcc5) has removed gmcs to be now mcs
	fi

	# Disabled, vala error -> see launchpad
	sed -i -e '/examples/d' "${S}"/bindings/vala/Makefile.am || die

	vala_src_prepare
	export VALA_API_GEN="$VAPIGEN"
	eautoreconf
}

src_configure() {
	# Build GTK2 support #
	[[ -d build-gtk2 ]] || mkdir build-gtk2
	pushd build-gtk2
		PYTHON="${EPYTHON}" ../configure \
			--prefix=/usr \
			--libdir=/usr/$(get_libdir) \
			--disable-static \
			--with-gtk=2 \
			$(use_enable introspection ) \
			$(use_enable mono ) \
			$(use_enable test tests ) \
			$(use_enable test mono-test ) || die
	popd
	# Build GTK3 support #
	[[ -d build-gtk3 ]] || mkdir build-gtk3
	pushd build-gtk3
		PYTHON="${EPYTHON}" ../configure \
			--prefix=/usr \
			--libdir=/usr/$(get_libdir) \
			--disable-static \
			--with-gtk=3 \
			$(use_enable introspection ) \
			$(use_enable mono ) \
			$(use_enable test tests ) \
			$(use_enable test mono-test ) || die
	popd
}

src_compile() {
	# Build GTK2 support #
	pushd build-gtk2
		emake || die
	popd

	# Build GTK3 support #
	pushd build-gtk3
		emake || die
	popd
}

src_install() {
	# Install GTK2 support #
	pushd build-gtk2
		emake DESTDIR="${D}" install || die
	popd

	# Install GTK3 support #
	pushd build-gtk3
		make -C src DESTDIR="${D}" install || die
		make -C bindings/vala DESTDIR="${D}" install || die
	popd

	prune_libtool_files --modules
}

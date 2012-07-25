EAPI=3

inherit base autotools eutils virtualx

UURL="http://archive.ubuntu.com/ubuntu/pool/main/libd/${PN}"
UVER="0ubuntu0.1"
URELEASE="precise-updates"
MY_P="${P/-/_}"

DESCRIPTION="Library to pass menu structure across DBus"
HOMEPAGE="https://launchpad.net/dbusmenu"
SRC_URI="${UURL}/${MY_P}.orig.tar.gz
	${UURL}/${MY_P}-${UVER}.diff.gz"

LICENSE="LGPL-3"
SLOT="3"
KEYWORDS="~amd64 ~x86"
IUSE="+introspection +gtk"

RDEPEND="dev-libs/glib:2
	<dev-libs/dbus-glib-0.100
	dev-libs/libxml2:2
	<sys-apps/dbus-1.6.0
	>=x11-libs/gtk+-99.2.24.10
	>=x11-libs/gtk+-99.3.4.2:3"
DEPEND="${RDEPEND}
	introspection? ( >=dev-libs/gobject-introspection-0.6.7
				dev-lang/vala:0.14 )
	dev-util/intltool
	dev-util/pkgconfig"

PATCHES+=( "${WORKDIR}/${MY_P}-${UVER}.diff" )

src_prepare() {
	base_src_prepare
	eautoreconf
	export MAKEOPTS="${MAKEOPTS} -j1"
	use introspection && \
		export VALA_API_GEN=$(type -P vapigen-0.14)
}

src_configure() {
	# Build GTK2 support #
	[[ -d build-gtk2 ]] || mkdir build-gtk2
	pushd build-gtk2
	../configure --prefix=/usr \
		$(use_enable introspection) \
		--disable-static \
		--disable-scrollkeeper \
		--disable-tests \
		--with-gtk=2 || die
	popd

	# Build GTK3 support #
	[[ -d build-gtk3 ]] || mkdir build-gtk3
	pushd build-gtk3
	../configure --prefix=/usr \
		$(use_enable introspection) \
		--disable-static \
		--disable-scrollkeeper \
		--disable-tests \
		--with-gtk=3 || die
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
	# Install GTK3 support #
	pushd build-gtk3
	make -C libdbusmenu-glib DESTDIR="${D}" install || die
	make -C libdbusmenu-gtk DESTDIR="${D}" install || die
	make -C tools DESTDIR="${D}" install || die
	make -C docs/libdbusmenu-glib DESTDIR="${D}" install || die
	make -C po DESTDIR="${D}" install || die
	popd

	# Install GTK2 support #
	pushd build-gtk2
	make -C libdbusmenu-gtk DESTDIR="${D}" install || die
	make -C docs/libdbusmenu-gtk DESTDIR="${D}" install || die
	popd
}

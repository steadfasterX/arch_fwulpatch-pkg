pkgname=fwulpatch
pkgver=2.2
pkgrel=1
pkgdesc="Patching a FWUL major release without the need to re-install/-deploy"
arch=('any')
url="https://github.com/steadfasterX/arch_fwulpatch"
license=('LGPL3')
depends=('sudo' 'pacman')
makedepends=('git')
source=("https://github.com/steadfasterX/arch_$pkgname/archive/v$pkgver.tar.gz")
md5sums=('SKIP')
BINFIX=usr/local/bin
SUDOERS=etc/sudoers.d
SYSD=etc/systemd/system
MANDIR=usr/share/man
MAN5DIR=${MANDIR}/man5
MAN5PAGE=fwulpatch.5
FWULPATCHDIR=opt/fwul/patches
USER=root
GROUP=root
install=${pkgname}.install

package() {
    cd "arch_$pkgname-$pkgver"
    
    # create / ensure required dirs exists
    mkdir -p $pkgdir/${BINFIX} $pkgdir/$SYSD $pkgdir/$MAN5DIR $pkgdir/$FWULPATCHDIR

    # install the patches
    install -d -m 0750 $pkgdir/${FWULPATCHDIR}
    install -o ${USER} -g ${GROUP} -m 0700 patches/* $pkgdir/${FWULPATCHDIR}

    install -m 0644 doc/${MAN5PAGE} $pkgdir/${MAN5DIR}/${MAN5PAGE}

    mkdir -p "$pkgdir/usr/share/licenses/$pkgname"
    install -D -m644 ./LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

}


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
FWULPATCHDIR=opt/fwul/patches
USER=root
GROUP=root
install=${pkgname}.install

package() {
    cd "arch_$pkgname-$pkgver"
    
    # create / ensure required dirs exists
    mkdir -p $pkgdir/$FWULPATCHDIR

    # install the patches
    install -d -m 0750 $pkgdir/${FWULPATCHDIR}
    install -o ${USER} -g ${GROUP} -m 0700 patches/* $pkgdir/${FWULPATCHDIR}

    mkdir -p "$pkgdir/usr/share/licenses/$pkgname"
    install -D -m644 ./LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}


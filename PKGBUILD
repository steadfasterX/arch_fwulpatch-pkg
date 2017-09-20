pkgname=fwulpatch
pkgver=2.2
pkgrel=1
pkgdesc="Patching a FWUL major release without the need to re-install/-deploy"
arch=('any')
url="https://github.com/steadfasterX/arch_fwulpatch"
license=('LGPL3')
depends=('sudo' 'pacman' 'gksu')
makedepends=('git')
source=("https://github.com/steadfasterX/arch_$pkgname/archive/v$pkgver.tar.gz")
md5sums=('SKIP')
BINFIX=usr/local/bin
FWULPATCHDIR=opt/fwul/patches
PFWULLIB=var/lib/fwul
USER=root
GROUP=root
install=${pkgname}.install

package() {
    cd "arch_$pkgname-$pkgver"
    
    # create / ensure required dirs exists
    mkdir -p $pkgdir/$FWULPATCHDIR

    # add patches
    install -d -m 0750 $pkgdir/${FWULPATCHDIR}
    install -d -m 0755 $pkgdir/usr/local/bin $pkgdir/$PFWULLIB
    install -o ${USER} -g ${GROUP} -m 0700 patches/* $pkgdir/${FWULPATCHDIR}

    # inject funcs (should be moved to separate pkg...)
    install -o ${USER} -g ${GROUP} -m 0755 $srcdir/../livepatcher/*.func $pkgdir/$PFWULLIB/
    install -o ${USER} -g ${GROUP} -m 0744 $srcdir/../livepatcher/*.vars $pkgdir/$PFWULLIB/
    install -o ${USER} -g ${GROUP} -m 0755 $srcdir/../livepatcher/*.sh $pkgdir/usr/local/bin/
    
    # add license
    install -d -m 0775 $pkgdir/usr/share/licenses/$pkgname
    install -D -m 644 ./LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}


pkgname=fwulpatch
pkgver=2.2.1
pkgrel=1
pkgdesc="Patching a FWUL major release without the need to re-install/-deploy"
arch=('any')
url="https://github.com/steadfasterX/arch_fwulpatch"
license=('LGPL3')
depends=('sudo' 'pacman' 'gksu')
makedepends=('git')
source=("https://github.com/steadfasterX/arch_$pkgname/archive/$pkgver.tar.gz")
md5sums=('SKIP')
BINFIX=usr/local/bin
FWULDIR=opt/fwul
FWULPATCHDIR=$FWULDIR/patches
PFWULLIB=var/lib/fwul
USER=root
GROUP=root
install=${pkgname}.install

package() {
    cd "arch_$pkgname-$pkgver"
    
    # create / ensure required dirs exists
    mkdir -p $pkgdir/usr/share \
	    $pkgdir/${FWULPATCHDIR} \
    	    $pkgdir/usr/local/bin \
	    $pkgdir/$PFWULLIB \
	    $pkgdir/usr/share/licenses/$pkgname 

    # add patches
    install -d -m 0750 $pkgdir/${FWULPATCHDIR}
    install -o ${USER} -g ${GROUP} -m 0700 patches/* $pkgdir/${FWULPATCHDIR}
    install -o ${USER} -g ${GROUP} -m 0444 $srcdir/../livepatcher/livepatcher.png $pkgdir/${FWULDIR}

    # inject funcs (should be moved to separate pkg...)
    install -o ${USER} -g ${GROUP} -m 0755 $srcdir/../livepatcher/*.func $pkgdir/$PFWULLIB/
    install -o ${USER} -g ${GROUP} -m 0744 $srcdir/../livepatcher/*.vars $pkgdir/$PFWULLIB/
    install -o ${USER} -g ${GROUP} -m 0755 $srcdir/../livepatcher/*.sh $pkgdir/usr/local/bin/
    
    # add license
    install -D -m 644 ./LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    # set perms
    for ref in $(find $pkgdir/* -type d);do
        realpath=${ref/$pkgdir/}
        [ -d "$realpath" ] && chmod -v --reference=$realpath $ref
    done
    echo finished
}


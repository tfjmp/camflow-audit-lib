version=0.4.7
BRANCH?=master

update_commit:
	ruby ./scripts/commit.rb

all: update_commit clean
	cd ./threadpool && $(MAKE) all
	cd ./src && $(MAKE) all

clean:
	cd ./threadpool && $(MAKE) clean
	cd ./src && $(MAKE) clean
	rm -rf output

prepare:
	cd ./threadpool && $(MAKE) prepare
	cd ./uthash && $(MAKE) prepare

install:
	cd ./src && sudo $(MAKE) install
	cd ./include && sudo $(MAKE) install

rpm: all
	mkdir -p ~/rpmbuild/{RPMS,SRPMS,BUILD,SOURCES,SPECS,tmp}
	cp -f ./libprovenance.spec ~/rpmbuild/SPECS/libprovenance.spec
	rpmbuild -bb libprovenance.spec
	mkdir -p output
	cp ~/rpmbuild/RPMS/x86_64/* ./output

deb:
	sudo alien output/libprovenance-$(version)-1.x86_64.rpm
	cp *.deb ./output

travis_checkout_dev:
	git clone https://github.com/CamFlow/camflow-dev.git
	cd camflow-dev && git checkout $(BRANCH)

travis_update_files: travis_checkout_dev
	sed -i -e 's/#include <linux\/provenance.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance.h"/g' ./include/provenance.h
	sed -i -e 's/#include <linux\/provenance_fs.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_fs.h"/g' ./include/provenance.h
	sed -i -e 's/#include <linux\/provenance_utils.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_utils.h"/g' ./include/provenance.h
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./include/provenance.h
	sed -i -e 's/#include <linux\/provenance.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance.h"/g' ./include/provenancefilter.h
	sed -i -e 's/#include <linux\/provenance.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance.h"/g' ./include/provenanceutils.h
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./include/provenancefilter.h
	sed -i -e 's/#include <linux\/camflow.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/camflow.h"/g' ./src/provenanceW3CJSON.c
	sed -i -e 's/#include <linux\/camflow.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/camflow.h"/g' ./src/provenanceSPADEJSON.c
	sed -i -e 's/#include <linux\/xattr.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/xattr.h"/g' ./src/libprovenance.c
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./src/libprovenance.c
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./src/provenanceW3CJSON.c
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./src/provenanceSPADEJSON.c
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./src/provenancefilter.c
	sed -i -e 's/#include <linux\/provenance_types.h>/#include "..\/camflow-dev\/include\/uapi\/linux\/provenance_types.h"/g' ./src/relay.c

travis: travis_update_files prepare all install

publish_rpm:
	cd ./output && package_cloud push camflow/provenance/fedora/27 libprovenance-$(version)-1.x86_64.rpm

publish_deb:
	cd ./output && package_cloud push camflow/provenance/ubuntu/bionic libprovenance_$(version)-2_amd64.deb

publish: publish_rpm publish_deb

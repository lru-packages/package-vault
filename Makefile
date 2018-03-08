NAME=vault
VERSION=0.9.5
ITERATION=1.lru
PREFIX=/usr/local/bin
LICENSE=BSD
VENDOR="Hashicorp"
MAINTAINER="Ryan Parman"
DESCRIPTION="Vault encrypts and provides access to any secrets."
URL=https://vaultproject.io
RHEL=$(shell rpm -q --queryformat '%{VERSION}' centos-release)

define AFTER_INSTALL
id -u vault &>/dev/null || useradd --system --user-group vault
mkdir -p /var/vault /etc/vault
chown -f vault:vault /var/vault /etc/vault
chmod -f 0755 /var/vault /etc/vault
endef

define AFTER_REMOVE
rm -Rf /var/vault /etc/vault
userdel vault
endef

export AFTER_INSTALL
export AFTER_REMOVE

#-------------------------------------------------------------------------------

all: info clean compile package move

#-------------------------------------------------------------------------------

.PHONY: info
info:
	@ echo "NAME:        $(NAME)"
	@ echo "VERSION:     $(VERSION)"
	@ echo "ITERATION:   $(ITERATION)"
	@ echo "PREFIX:      $(PREFIX)"
	@ echo "LICENSE:     $(LICENSE)"
	@ echo "VENDOR:      $(VENDOR)"
	@ echo "MAINTAINER:  $(MAINTAINER)"
	@ echo "DESCRIPTION: $(DESCRIPTION)"
	@ echo "URL:         $(URL)"
	@ echo "RHEL:        $(RHEL)"
	@ echo " "

#-------------------------------------------------------------------------------

.PHONY: clean
clean:
	rm -Rf /tmp/installdir* vault* after*.sh

#-------------------------------------------------------------------------------

.PHONY: compile
compile:
	wget -O vault.zip https://releases.hashicorp.com/vault/$(VERSION)/vault_$(VERSION)_linux_amd64.zip
	unzip vault.zip

	echo "$$AFTER_INSTALL" > after-install.sh
	echo "$$AFTER_REMOVE" > after-remove.sh

#-------------------------------------------------------------------------------

.PHONY: package
package:

	# Main package
	fpm \
		-s dir \
		-t rpm \
		-n $(NAME) \
		-v $(VERSION) \
		-m $(MAINTAINER) \
		--iteration $(ITERATION) \
		--license $(LICENSE) \
		--vendor $(VENDOR) \
		--prefix $(PREFIX) \
		--url $(URL) \
		--description $(DESCRIPTION) \
		--rpm-defattrfile 0755 \
		--rpm-digest md5 \
		--rpm-compression gzip \
		--rpm-os linux \
		--rpm-auto-add-directories \
		--template-scripts \
		--after-install after-install.sh \
		--after-remove after-remove.sh \
		vault \
	;

#-------------------------------------------------------------------------------

.PHONY: move
move:
	mv *.rpm /vagrant/repo/

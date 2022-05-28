.PHONY: help
help:
	@echo 'install:   install   mktap to   /bin'
	@echo 'uninstall: uninstall mktap from /bin'

install:
	@echo Installing mktap...
	@cp mktap /bin/

uninstall:
	@echo Uninstalling mktap...
	@rm -f /bin/mktap
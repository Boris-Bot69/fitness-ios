DB_PATH=/tmp/dev.db

db-diagram: docs/assets/img/db.svg
docs/assets/img/db.svg:
	sqleton -o docs/assets/img/db.svg ${DB_PATH}

.PHONY: docs-iphone docs-ipad docs-ios jazzy 

JAZZY_BINARY := $(shell command -v jazzy 2> /dev/null)

docs-all: site docs-ios

docs-serve: docs
	cd site && python -m http.server 8000

site: docs db-diagram
	mkdocs build

docs-ios: docs-iphone docs-ipad

docs-ipad: jazzy
	cd iPad-App && jazzy \
	--clean \
	--theme fullwidth \
	--min-acl internal \
	--no-hide-documentation-coverage \
	--theme fullwidth \
	--output ../site/jazzy/ipad \
	--xcodebuild-arguments -workspace,DoctorsApp.xcodeproj/project.xcworkspace,-scheme,DoctorsApp

docs-iphone: jazzy
	cd App && jazzy \
	--clean \
	--theme fullwidth \
	--min-acl internal \
	--no-hide-documentation-coverage \
	--theme fullwidth \
	--output ../site/jazzy/iphone \
	--documentation=../docs/*.md \
	--xcodebuild-arguments -workspace,tumsm.xcodeproj/project.xcworkspace,-scheme,tumsm

jazzy:
ifndef JAZZY_BINARY
	gem install jazzy
endif

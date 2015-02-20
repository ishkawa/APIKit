.PHONY: carthage

carthage:
	carthage update --use-submodules

test:
	set -o pipefail && xcodebuild test -scheme APIKit-Mac | xcpretty -c -r junit -o build/test-report.xml

test:
	set -o pipefail && xcodebuild test -scheme APIKit-iOS | xcpretty -c -r junit -o build/test-report.xml

module libMFAAndroid

go 1.15

require (
	github.com/pkg/browser v0.0.0-20210115035449-ce105d075bb4
	golang.org/x/sys v0.0.0-20210320140829-1e4c9ba3b0c4
	libMFA v0.0.0-00010101000000-000000000000
)

replace libMFA => ../../../../../../common/libMFA

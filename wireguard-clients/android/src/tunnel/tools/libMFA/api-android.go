package main

// #cgo LDFLAGS: -llog
// #include <android/log.h>
// #include <stdlib.h>
// #include <sys/types.h>
// static void callOpenBrowser(void *func, const char *msg)
// {
//  ((void(*)(const char *))func)(msg);
// }
import "C"
import (
	"libMFA/api"
	"unsafe"
)

var openBrowserFunc unsafe.Pointer

//export activate
func activate(host *C.char, key *C.char) int {
    C.__android_log_write(C.ANDROID_LOG_ERROR, C.CString("Activation"), C.CString("Starting..."))
	return api.Activate(C.GoString(host), C.GoString(key))
}

//export getActivationData
func getActivationData(host *C.char, key *C.char,  activationScheme *C.char) *C.char {
    C.__android_log_write(C.ANDROID_LOG_ERROR, C.CString("Activation"), C.CString("Get activation data..."))
	err, responseJson, _ := api.GetActivationData(C.GoString(host), C.GoString(key), C.GoString(activationScheme))
	if err != nil {
	C.__android_log_write(C.ANDROID_LOG_ERROR, C.CString("Activation"), C.CString("Failed"))
		return C.CString("")
	}

	if responseJson == nil {
		C.__android_log_write(C.ANDROID_LOG_ERROR, C.CString("Activation"), C.CString("No activation needed"))
		return C.CString("")
	}

	return C.CString(api.BuildWebServerAddressForRedirectUri(responseJson.Data.AuthenticationURL))
}

//export verifyActivationResult
func verifyActivationResult(host *C.char, scheme *C.char,  url *C.char) int {
	return api.VerifyActivationResult(C.GoString(host), C.GoString(scheme), C.GoString(url))
}

func openBrowser(openBrowserFn uintptr, url string) int {
	openBrowserFunc := unsafe.Pointer(openBrowserFn)
	if uintptr(openBrowserFunc) != 0 {
		nativeUrlData := C.CString(url)
		C.callOpenBrowser(openBrowserFunc, nativeUrlData)
		C.free(unsafe.Pointer(nativeUrlData))
	} else {
		return api.CannotOpenBrowser
	}

	return api.NoErrors
}

func main() {}

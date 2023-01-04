#ifndef LIB_MFA_H
#define LIB_MFA_H

#include <jni.h>
#include <stdlib.h>
#include <string.h>
#include <jni.h>
#include <android/log.h>

typedef void(*open_browser_fn_t)(const char *url);
extern int activate(const char *host, const char *key);
extern char* getActivationData(const char *host, const char *key, const char *scheme);
extern int verifyActivationResult(const char *host, const char *scheme, const char *url);

static const char custom_url_scheme[] = "zte";

JNIEXPORT jstring JNICALL Java_com_wireguard_activation_ActivationNative_activate(JNIEnv* env, jobject obj, jstring host,jstring key) {
    const char *nativeHostString = (*env)->GetStringUTFChars(env, host, 0);
    const char *nativeKeyString = (*env)->GetStringUTFChars(env, key, 0);
    const char* url = getActivationData(nativeHostString, nativeKeyString, custom_url_scheme);
    jstring url_jstr = (*env)->NewStringUTF(env, url);
    (*env)->ReleaseStringUTFChars(env, host, nativeHostString);
    (*env)->ReleaseStringUTFChars(env, key, nativeKeyString);
    return url_jstr;
}

JNIEXPORT jint JNICALL Java_com_wireguard_activation_ActivationNative_verifyActivationResult(JNIEnv* env, jobject obj, jstring host, jstring urlData) {
    const char *nativeHostString = (*env)->GetStringUTFChars(env, host, 0);
    const char *nativeUrlDataString = (*env)->GetStringUTFChars(env, urlData, 0);
    const int result = verifyActivationResult(nativeHostString, custom_url_scheme, nativeUrlDataString);
    (*env)->ReleaseStringUTFChars(env, host, nativeHostString);
    (*env)->ReleaseStringUTFChars(env, urlData, nativeUrlDataString);
    return result;
}

#endif //LIB_MFA_H
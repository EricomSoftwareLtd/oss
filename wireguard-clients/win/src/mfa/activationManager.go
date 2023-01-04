package mfa

import (
	"golang.zx2c4.com/wireguard/windows/conf"
	"libMFA/api"
)

func FormatErrorMessage(code int) string {
	return api.FormatErrorMessage(code)
}

func Activate(config conf.Config, result chan<- int) {
	shouldActivate := config.HasActivationConfig()
	if shouldActivate == true {

		go func() {
			activationResult := api.Activate(config.ActivationConfig.Host.String(), config.ActivationConfig.Key.String())
			if activationResult == api.NoActivationNeeded || activationResult == api.NoErrors {
				result <- api.NoErrors
			} else {
				result <- activationResult
			}
		}()
	} else {
		result <- api.NoErrors
	}
}

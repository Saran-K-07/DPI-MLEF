// go build -buildmode=plugin -o evil.so evil.go
package main

import (
	"os"
)

func Run() {
	os.Create("/tmp/pwned")
}
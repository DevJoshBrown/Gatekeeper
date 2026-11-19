package config

import (
	"log/slog"
	"os"
	"strconv"
)

func GetFloatEnv(key string, defaultValue float64) float64 {
	envVar := os.Getenv(key)
	if envVar == "" {
		return defaultValue
	}
	keyFloat, err := strconv.ParseFloat(envVar, 64)
	if err != nil {
		slog.Warn("config value invalid, reverting to default", "warning", err)
		return defaultValue
	}
	return keyFloat
}

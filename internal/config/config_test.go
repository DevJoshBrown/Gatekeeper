package config

import (
	"testing"
)

func TestConfigParse(t *testing.T) {
	t.Setenv("TOKENBUCKET_CAPACITY", "75")
	expected := 75.0

	FloatCapacity := GetFloatEnv("TOKENBUCKET_CAPACITY", 0)
	if FloatCapacity != expected {
		t.Errorf("Failed to parse float, expected: %v, got: %v", expected, FloatCapacity)
	}
}

func TestConfigDefault(t *testing.T) {
	t.Setenv("TOKENBUCKET_CAPACITY", "banana")
	expected := 75.0

	FloatCapacity := GetFloatEnv("TOKENBUCKET_CAPACITY", 75.0)
	if FloatCapacity != expected {
		t.Errorf("Failed to correctly default when given invalid config, expected: %v, got %v", expected, FloatCapacity)
	}
}

func TestConfigNoValue(t *testing.T) {
	expected := 75.0

	FloatCapacity := GetFloatEnv("TOKENBUCKET_CAPACITY", 75.0)
	if FloatCapacity != expected {
		t.Errorf("Failed to correctly default when given no value in config, expected: %v, got %v", expected, FloatCapacity)
	}
}

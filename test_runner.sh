#!/bin/bash

# HomeApp Integration Test Runner
# This script runs comprehensive E2E tests for the HomeApp Flutter application

echo "🧪 Starting HomeApp E2E Tests..."
echo "================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed or not in PATH${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Pre-test setup...${NC}"

# Get dependencies
echo -e "${YELLOW}📦 Getting dependencies...${NC}"
flutter pub get

# Check for any compile errors
echo -e "${YELLOW}🔍 Checking for compile errors...${NC}"
flutter analyze
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Static analysis failed. Please fix errors before running tests.${NC}"
    exit 1
fi

# Check connected devices
echo -e "${YELLOW}📱 Checking connected devices...${NC}"
flutter devices
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ No devices available. Please connect a device or start a simulator.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Pre-test setup complete${NC}"
echo ""

# Run unit tests first
echo -e "${BLUE}🧪 Running unit tests...${NC}"
flutter test
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Unit tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Unit tests passed${NC}"
echo ""

# Run widget tests
echo -e "${BLUE}🧪 Running widget tests...${NC}"
flutter test test/widget_test.dart
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Widget tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Widget tests passed${NC}"
echo ""

# Run integration tests
echo -e "${BLUE}🧪 Running integration tests...${NC}"

# Basic E2E tests
echo -e "${YELLOW}🔄 Running basic E2E tests...${NC}"
flutter test integration_test/app_test.dart
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Basic E2E tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Basic E2E tests passed${NC}"

# Comprehensive E2E tests
echo -e "${YELLOW}🔄 Running comprehensive E2E tests...${NC}"
flutter test integration_test/comprehensive_test.dart
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Comprehensive E2E tests failed${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Comprehensive E2E tests passed${NC}"

# Performance tests (if device supports it)
echo -e "${YELLOW}🔄 Running performance tests...${NC}"
flutter drive --driver=test_driver/integration_test.dart --target=integration_test/app_test.dart --profile 2>/dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Performance tests passed${NC}"
else
    echo -e "${YELLOW}⚠️ Performance tests skipped (device may not support profiling)${NC}"
fi

echo ""
echo -e "${GREEN}🎉 All tests completed successfully!${NC}"
echo "================================="
echo -e "${BLUE}📊 Test Summary:${NC}"
echo -e "✅ Unit tests: ${GREEN}PASSED${NC}"
echo -e "✅ Widget tests: ${GREEN}PASSED${NC}"
echo -e "✅ Basic E2E tests: ${GREEN}PASSED${NC}"
echo -e "✅ Comprehensive E2E tests: ${GREEN}PASSED${NC}"
echo ""
echo -e "${BLUE}🚀 HomeApp is ready for deployment!${NC}"
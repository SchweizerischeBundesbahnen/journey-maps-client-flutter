#!/usr/bin/env node
// CI entry point for validateSupportedSdksConfig. Reads the three files the
// invariants relate, reports any violation, and exits non-zero so the setup
// job in every workflow fails before a stale config can be consumed.
//
// Deliberately dependency-free (no npm install, no Dart/Flutter SDK): this
// runs as the very first step of every workflow, before any toolchain is
// even known, so it must work with nothing but the Node.js already present
// on the runner.

import { readFileSync } from 'node:fs';
import { validateSupportedSdksConfig } from './supported-sdks-validator.mjs';

const configJson = readFileSync('ci/supported-sdks.json', 'utf8');
const pubspecYaml = readFileSync('pubspec.yaml', 'utf8');
const fvmrcJson = readFileSync('.fvmrc', 'utf8');

const result = validateSupportedSdksConfig({ configJson, pubspecYaml, fvmrcJson });

if (!result.isValid) {
  console.error('ci/supported-sdks.json is inconsistent with pubspec.yaml and/or .fvmrc:');
  for (const error of result.errors) {
    console.error(`  - ${error}`);
  }
  process.exit(1);
}

console.log('ci/supported-sdks.json is consistent with pubspec.yaml and .fvmrc.');

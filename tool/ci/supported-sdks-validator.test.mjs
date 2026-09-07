import { describe, test } from 'node:test';
import assert from 'node:assert/strict';

import { validateSupportedSdksConfig } from './supported-sdks-validator.mjs';

const consistentConfig = JSON.stringify({
  window: ['3.38.x', '3.41.x', '3.44.x'],
  canonical: '3.38.10',
});

const consistentPubspec = `
name: sbb_maps_flutter
environment:
  sdk: ">=3.10.0 <4.0.0"
  flutter: ">=3.38.1"
flutter:
  assets:
    - lib/fonts/
`;

const consistentFvmrc = JSON.stringify({ flutter: '3.38.10' });

function sut({ config, pubspec, fvmrc }) {
  return validateSupportedSdksConfig({ configJson: config, pubspecYaml: pubspec, fvmrcJson: fvmrc });
}

describe('Unit Test Supported SDKs Validator', () => {
  test('Should pass for a fully consistent set', () => {
    const result = sut({ config: consistentConfig, pubspec: consistentPubspec, fvmrc: consistentFvmrc });

    assert.equal(result.isValid, true);
    assert.deepEqual(result.errors, []);
  });

  test('Should pass for a window of four entries', () => {
    const config = JSON.stringify({ window: ['3.38.x', '3.41.x', '3.44.x', '3.47.x'], canonical: '3.38.10' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc: consistentFvmrc });

    assert.equal(result.isValid, true);
  });

  test('Should fail when the window floor disagrees with the pubspec floor, naming both values', () => {
    const config = JSON.stringify({ window: ['3.41.x', '3.44.x'], canonical: '3.41.5' });
    const fvmrc = JSON.stringify({ flutter: '3.41.5' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc });

    assert.equal(result.isValid, false);
    assert.equal(result.errors.length, 1);
    assert.match(result.errors[0], /3\.41/);
    assert.match(result.errors[0], /3\.38\.1/);
  });

  test('Should fail when the canonical version falls outside the floor range', () => {
    const config = JSON.stringify({ window: ['3.38.x', '3.41.x'], canonical: '3.41.5' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc: consistentFvmrc });

    assert.equal(result.isValid, false);
    assert.ok(result.errors.some((e) => e.includes('canonical') && e.includes('3.41.5') && e.includes('3.38')));
  });

  test('Should fail when .fvmrc does not equal the canonical version', () => {
    const fvmrc = JSON.stringify({ flutter: '3.38.9' });

    const result = sut({ config: consistentConfig, pubspec: consistentPubspec, fvmrc });

    assert.equal(result.isValid, false);
    assert.ok(result.errors.some((e) => e.includes('.fvmrc') && e.includes('3.38.9') && e.includes('3.38.10')));
  });

  test('Should fail when the window is listed out of order', () => {
    const config = JSON.stringify({ window: ['3.44.x', '3.38.x', '3.41.x'], canonical: '3.38.10' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc: consistentFvmrc });

    assert.equal(result.isValid, false);
    assert.ok(result.errors.some((e) => e.includes('ascending')));
  });

  test('Should fail when the window has fewer than one entry', () => {
    const config = JSON.stringify({ window: [], canonical: '3.38.10' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc: consistentFvmrc });

    assert.equal(result.isValid, false);
    assert.ok(result.errors.some((e) => e.includes('at least one')));
  });

  test('Should report multiple independent violations together', () => {
    const config = JSON.stringify({ window: ['3.41.x', '3.44.x'], canonical: '3.47.5' });
    const fvmrc = JSON.stringify({ flutter: '3.38.10' });

    const result = sut({ config, pubspec: consistentPubspec, fvmrc });

    assert.equal(result.isValid, false);
    assert.ok(result.errors.length >= 2);
  });
});

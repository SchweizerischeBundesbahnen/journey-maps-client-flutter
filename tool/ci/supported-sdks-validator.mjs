// Checks that the declared support window and canonical toolchain version in
// ci/supported-sdks.json agree with the pubspec.yaml environment.flutter
// floor and with .fvmrc, so the config file cannot itself drift from the
// sources it is meant to replace. See [[support-window]] and
// [[canonical-toolchain-version]] in CONTEXT.md.
//
// Pure: takes file contents, not paths, so it can be tested with in-memory
// inputs. verify-supported-sdks.mjs is the thin I/O wrapper that reads the
// real files and reports the process exit code.

const WILDCARD_PATTERN = /^(\d+)\.(\d+)\.x$/;
const EXACT_VERSION_PATTERN = /^(\d+)\.(\d+)\.(\d+)$/;
const PUBSPEC_FLUTTER_FLOOR_PATTERN = /flutter:\s*">=(\d+)\.(\d+)\.(\d+)/;

function majorMinorEquals(a, b) {
  return a.major === b.major && a.minor === b.minor;
}

function majorMinorToString({ major, minor }) {
  return `${major}.${minor}`;
}

export function validateSupportedSdksConfig({ configJson, pubspecYaml, fvmrcJson }) {
  const errors = [];

  const config = JSON.parse(configJson);
  const window = config.window;
  const canonical = config.canonical;

  if (!Array.isArray(window) || window.length === 0) {
    errors.push('ci/supported-sdks.json window must declare at least one supported SDK version.');
    return { isValid: false, errors };
  }

  const parsedWindow = [];
  for (const entry of window) {
    const match = WILDCARD_PATTERN.exec(entry);
    if (!match) {
      errors.push(
        `ci/supported-sdks.json window entry "${entry}" is not a valid patch-level wildcard (expected e.g. "3.38.x").`,
      );
      continue;
    }
    parsedWindow.push({ major: Number(match[1]), minor: Number(match[2]) });
  }
  if (errors.length > 0) return { isValid: false, errors };

  for (let i = 1; i < parsedWindow.length; i++) {
    const previous = parsedWindow[i - 1];
    const current = parsedWindow[i];
    const isStrictlyAscending =
      current.major > previous.major || (current.major === previous.major && current.minor > previous.minor);
    if (!isStrictlyAscending) {
      errors.push(
        `ci/supported-sdks.json window must be listed in strictly ascending order, ` +
          `but ${majorMinorToString(current)} does not come after ${majorMinorToString(previous)}.`,
      );
    }
  }
  if (errors.length > 0) return { isValid: false, errors };

  const floor = parsedWindow[0];

  const pubspecMatch = PUBSPEC_FLUTTER_FLOOR_PATTERN.exec(pubspecYaml);
  if (!pubspecMatch) {
    errors.push('pubspec.yaml does not declare an environment.flutter floor of the form ">=X.Y.Z".');
    return { isValid: false, errors };
  }
  const pubspecFloor = { major: Number(pubspecMatch[1]), minor: Number(pubspecMatch[2]) };
  const pubspecFloorExact = `${pubspecMatch[1]}.${pubspecMatch[2]}.${pubspecMatch[3]}`;

  if (!majorMinorEquals(pubspecFloor, floor)) {
    errors.push(
      `ci/supported-sdks.json window floor is ${majorMinorToString(floor)}.x but pubspec.yaml ` +
        `environment.flutter floor is ${pubspecFloorExact}.`,
    );
  }

  const canonicalMatch = EXACT_VERSION_PATTERN.exec(canonical);
  if (!canonicalMatch) {
    errors.push(
      `ci/supported-sdks.json canonical version "${canonical}" is not an exact version of the form "X.Y.Z".`,
    );
    return { isValid: false, errors };
  }
  const canonicalMajorMinor = { major: Number(canonicalMatch[1]), minor: Number(canonicalMatch[2]) };

  if (!majorMinorEquals(canonicalMajorMinor, floor)) {
    errors.push(
      `ci/supported-sdks.json canonical version ${canonical} is outside the window floor ${majorMinorToString(floor)}.x.`,
    );
  }

  const fvmrc = JSON.parse(fvmrcJson);
  const fvmrcFlutter = fvmrc.flutter;
  if (fvmrcFlutter !== canonical) {
    errors.push(`.fvmrc pins ${fvmrcFlutter} but ci/supported-sdks.json canonical version is ${canonical}.`);
  }

  return { isValid: errors.length === 0, errors };
}

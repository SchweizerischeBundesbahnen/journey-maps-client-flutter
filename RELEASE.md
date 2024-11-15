## Release Process

The releases will be done through [Release Please]. This project uses the [Github Action version].

All configuration files for [Release Please] are found in the `./ci` directory.

### Example App

Merging a release please PR will open another PR with a commit syncing the example app to the
package version and increasing the build number by one.

Upon merging this PR, the example app will be released to the enterprise app stores.

[Release Please]: https://github.com/googleapis/release-please
[Github Action version]: https://github.com/googleapis/release-please-action
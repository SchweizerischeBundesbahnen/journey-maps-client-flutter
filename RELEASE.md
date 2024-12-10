## Release Process

The releases will be done through [Release Please]. This project uses the [Github Action version].

All configuration files for [Release Please] are found in the `./ci` directory.

### Pub Dev

The pub dev release is done by running the `publish_pub_dev` Github action.

### Example App

The example app release process is initiated by running the `example_app_release_pr` Github action. This will
open a PR with a commit syncing the example app to the package version and increasing the build number by one.

Upon merging this PR, the example app will be released to the enterprise app store.

[Release Please]: https://github.com/googleapis/release-please
[Github Action version]: https://github.com/googleapis/release-please-action
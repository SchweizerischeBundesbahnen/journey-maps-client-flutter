## Release Process

The releases will be done through [Release Please]. This project uses the [Github Action version].

For triggering subsequent workflows, we use the *sbb-app-bakery* Github App with a private key stored in the
Github Actions secrets.

All configuration files for [Release Please] are found in the `./ci` directory.

#### Pub Dev

Merging the release please PR will result in the `publish_pub_dev` workflow to be triggered. This workflow
takes care of the release to pub.dev.

#### Example App

The example app release process is initiated by running the `example_app_release_pr` Github action. This will
open a PR with a commit syncing the example app to the package version and increasing the build number by one.

Upon merging this PR, the example app will be released to the enterprise app store.

[Release Please]: https://github.com/googleapis/release-please
[Github Action version]: https://github.com/googleapis/release-please-action
## Release Process

The releases will be done through [Release Please]. This project uses the [Github Action version].

For triggering subsequent workflows, we use the *sbb-app-bakery* Github App with a private key stored in the
Github Actions secrets.

All configuration files for [Release Please] are found in the `./ci` directory.

#### Pub Dev

Merging the release please PR will result in the `publish_pub_dev` workflow to be triggered. This workflow
takes care of the release to pub.dev.

#### Example App

Merging the release please PR will trigger the `example_app_release_pr` Github action. This will
* open a PR with a commit 
  * syncing the example app to the package version
  * increasing the build number by one.

Upon merging this PR, the `example_app_build_and_release` workflow releases the example app to
* the SBB Enterprise Playstore (Android)
* TestFlight (iOS). Only internal testers of the App Store Connect team receive the build.

The Android and the iOS release run independently. If one fails, use *Re-run failed jobs* on the
workflow run. This reruns the failed platform only.

This PR can also be opened manually and will fail silently if no changes are commited. A manually
opened PR increases the build number, so it releases the same package version again on both platforms.

##### iOS signing

The example app is signed in every build of the `example_app_build` workflow and in the release.
Pull requests from forks cannot read secrets and build without signing.

Signing uses team `ZB8B4MY472`, the bundle id `ch.sbb.SBBJourneyMapsFlutter` and the App Store
provisioning profile `JourneyMaps Client Flutter (AppStore)`. The workflows download the profile from
App Store Connect on every run.

The workflows read five Github Actions secrets:

| Secret                                  | Content                                                               |
|-----------------------------------------|-----------------------------------------------------------------------|
| `IOS_DISTRIBUTION_CERTIFICATE_BASE64`   | The distribution certificate with its private key as `.p12`, base64 encoded. |
| `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD` | The password of the `.p12` file.                                      |
| `APPSTORE_CONNECT_KEY_ID`               | The key id of the App Store Connect team API key.                     |
| `APPSTORE_CONNECT_ISSUER_ID`            | The issuer id of the App Store Connect team API key.                  |
| `APPSTORE_CONNECT_PRIVATE_KEY`          | The content of the `.p8` file of the API key, not base64 encoded.     |

The distribution certificate expires one year after its creation. To renew it:
1. Create a new distribution certificate in the Apple developer portal and export it with its private
   key as `.p12` from the keychain.
2. Add the new certificate to the provisioning profile `JourneyMaps Client Flutter (AppStore)`.
3. Update `IOS_DISTRIBUTION_CERTIFICATE_BASE64` and `IOS_DISTRIBUTION_CERTIFICATE_PASSWORD`.

[Release Please]: https://github.com/googleapis/release-please
[Github Action version]: https://github.com/googleapis/release-please-action
fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### before_match

```sh
[bundle exec] fastlane before_match
```

Run specific actions before match

### before_gym

```sh
[bundle exec] fastlane before_gym
```

Run specific actions before gym

### rsb_match_init

```sh
[bundle exec] fastlane rsb_match_init
```

Create all certificates and profiles via match

### rsb_match

```sh
[bundle exec] fastlane rsb_match
```

Download all certificates and profiles via match

### rsb_match_nuke

```sh
[bundle exec] fastlane rsb_match_nuke
```

Remove all certificates and profiles

### rsb_match_use

```sh
[bundle exec] fastlane rsb_match_use
```

Use existing certificates or profiles

### rsb_start_ticket

```sh
[bundle exec] fastlane rsb_start_ticket
```



### rsb_code_review_ticket

```sh
[bundle exec] fastlane rsb_code_review_ticket
```



### rsb_finish_ticket

```sh
[bundle exec] fastlane rsb_finish_ticket
```



### rsb_test

```sh
[bundle exec] fastlane rsb_test
```



----


## iOS

### ios rsb_fabric

```sh
[bundle exec] fastlane ios rsb_fabric
```



### ios rsb_fabric_testflight

```sh
[bundle exec] fastlane ios rsb_fabric_testflight
```



### ios rsb_testflight

```sh
[bundle exec] fastlane ios rsb_testflight
```



### ios rsb_firebase_testflight

```sh
[bundle exec] fastlane ios rsb_firebase_testflight
```



### ios rsb_firebase

```sh
[bundle exec] fastlane ios rsb_firebase
```



### ios rsb_desktop_archive

```sh
[bundle exec] fastlane ios rsb_desktop_archive
```



### ios rsb_upload

```sh
[bundle exec] fastlane ios rsb_upload
```



### ios rsb_add_devices

```sh
[bundle exec] fastlane ios rsb_add_devices
```



### ios rsb_changelog

```sh
[bundle exec] fastlane ios rsb_changelog
```



----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).

# Contributing to TON AppStore

This document describes how to contribute an app to TON AppStore.

**IMPORTANT**: Your PR must be _well tested_ on your own MIROS first. This is the mandatory first step for your submission.

**NOTE**: Do not use `latest` tag for `image`. What's Wrong With The Docker `:latest` Tag?
Why not always use the latest tag?
From our point of view, there are two issues:

Previously, we would download the entire image to compare the hash with the local image, but this process becomes very time-consuming for users with slow internet speeds, making the check and update process inconvenient.

While Docker Hub offers an API that allows us to retrieve the hash of an image without downloading the entire image, such as "sha256:5b54f3fc806150bd122f6e7feb992e307464c12c41e8eb99a72e8ad6d9677e7f", this feature is not universally available across all container registries. This means that there may be images hosted on other platforms or locations where we cannot utilize this method.

Furthermore, in the event of a significant update in an application, such as a transition from version 0.1.2 to 2.0.0, which involves a complete overhaul of the setting structure, it is highly probable that the developers will opt to use the most recent tag for the updated version 2.0.0.

However manifest file from AppStore most likely stay as is, and thus become incompatible with the major change, and sometime cause app to stop working or behave weirdly.

Because of these reasons, we are keeping the tags specific.

## Submit Process

App submission should be done via Pull Request. Fork this repository and prepare the app per guidelines below.

Once the PR is ready, create and assign your PR to anyone from MIR Team or some other contributor you trust.

## Guidelines

### Project Structure

```shell
TON-AppStore
├─ category-list.json   # Configuration file for category list
├─ recommend-list.json  # Configuration file for recommended apps list
├─ featured-apps.json   # TBD
├─ help                 # Help script for old version app store
├─ Apps                 # Apps Store files
├─ build                # Installation script for Apps Store
└─ psd-source           # Icon thumbnail screenshot PSD Templates
```

### A TON Apps typically includes following files

```shell
App-Name
├─ docker-compose.yml   # (Required) A valid Docker Compose file
├─ icon.png             # (Required) App icon
├─ screenshot-1.png     # (Required) At least one screenshot is needed, to demonstrate the app runs on MIROS successfully.
├─ screenshot-2.png     # (Optional) More screenshots to demonstrate different functionalities is highly recommended.
├─ screenshot-3.png     # (Optional) ...
└─ thumbnail.png        # (Optional) A thumbnail file is needed only if you want it to be featured in AppStore front. (see specification at bottom)
```

#### A TON App is a Docker Compose app, or a _compose app_

Each directory under [Apps](Apps) correspond to a TON App. The directory should contain at least a `docker-compose.yml` file:

- It should be a valid [Docker Compose file](https://docs.docker.com/compose/compose-file/). Here are some requirements (but not limited to):

  - `name` must contain only lower case letters, numbers, underscore "`_`" and hyphen "`-`" (in other words, must match `^[a-z0-9][a-z0-9_-]*$`)

- Image tag should be specific, e.g. `:0.1.2`, instead of `:latest`.

- The `name` property is used as the _store App ID_, which should be unique across all apps.

  For example, in the [`docker-compose.yml` of Watchtower](Apps/watchtower/docker-compose.yml#L1), its store App ID is `syncthing`:

  ```yaml
  name: watchtower
  services:
    syncthing:
      image: containrrr/watchtower:<specific version>
  ```

- Language codes are case sensitive and should be in all lower case, e.g. `en_us`, `ru_ru`.

- There are few system wide variables can be used in `environment` and `volumes`:

  ```yaml
  environment:
    PGID: $PGID # Preset Group ID
    PUID: $PUID # Preset User ID
    TZ: $TZ # Current system timezone
  ---
  volumes:
    - type: bind
      source: /DATA/AppData/$AppID/config # $AppID = app name, e.g. syncthing
  ```

- MIROS specific metadata, also called _store info_, are stored under [extension](https://docs.docker.com/compose/compose-file/#extension) property `x-miros` at two positions.

  1. Service level

     A `docker-compose.yml` file can contain one or more `services`. Each [service](https://docs.docker.com/compose/compose-file/#services-top-level-element) can have its own store info.

     For the same example, at the buttom of the `watchtower` service in the [`docker-compose.yml` of Watchtower](Apps/watchtower/docker-compose.yml)

     ```yaml
     x-miros:
         envs:                           # description of each environment variable
             ...
           - container: PUID
             description:
                 en_us: Run Syncthing as specified uid.
         ports:                          # description of each port
           - container: "8384"
             description:
                 en_us: WebUI HTTP Port
             ...
         volumes:                        # description of each volume
             - container: /config
               description:
                   en_us: Syncthing config directory.
             - container: /DATA
               description:
                 en_us: Syncthing Accessible Directory.
     ```

  2. Compose app level

     For the same example, at the bottom of the [`docker-compose.yml` of Syncthing](Apps/Syncthing/docker-compose.yml)

     ```yaml
     x-miros:
       architectures: # a list of architectures that the app supports
         - amd64
         - arm
         - arm64
       main: name App # the name of the main service under `services`
       author: You Team
       category: Backup
       description: # multiple locales are supported
         en_us: name App is a some text
       developer: name App
       icon: link
       tagline: # multiple locales are supported
         en_us: Some text.
       thumbnail: link
       title: # multiple locales are supported
         en_us: Name App
       tips:
         before_install:
           en_us: |
             (some notes for user to read prior to installation, such as preset `username` and `password` - markdown is supported!)
       index: / # the index page for web UI, e.g. index.html
       port_map: "8384" # the port for web UI
     ```

## Requirements for Featured Apps

Once in a while, we pick certain apps as featured apps and display them at the AppStore front. The standard for apps to be featured is a bit higher than rest of the apps:

- Icon image should be a transparent background PNG image with a size of 192x192 pixels.
- Thumbnail image should be 784x442 pixels, with a rounded corner mask. It is recommended to be saved as a PNG image with a transparent background.
- Screenshot image should be 1280x720 pixels and can be saved in either PNG or JPG format. Please try to keep the file size as small as possible.

Please find the prepared [GIMP template files](gimp-source), to quickly create the above images if you need.

# canyoneer
An app built for rendering canyoneering locations within North America

## Setup

### MapBox
This project uses MapBox for map rendering. In order to develop this project you will need to create [a free MapBox account][https://account.mapbox.com/auth/signup].

Then follow [Mapbox's instructions][https://docs.mapbox.com/ios/maps/guides/install/] to configure your secret private token on your computer so you can load the Swift Package Manager dependency for Mapbox's iOS SDK.

In 2023, this looked something like this:

1. Create an account
2. Create a secret token with all public scope permissions and [MAP:READ, OFFLINE:READ, DOWNLOADS:READ] secret scopes
3. Add a .netrc to your home directory (not the project directory)
4. Populate .netrc file with your mapbox token id information:

```
machine api.mapbox.com
login mapbox
password YOUR_SECRET_MAPBOX_ACCESS_TOKEN
```

### Xcode
Xcode is used as the IDE for native development in Swift for iOS. You will need an Apple Developer account and to download Xcode from the OSX App Store or "Software Downloads".

Xcode is used to open Canyoneer.xcodeproj

## Development

### Dependencies
This is primarily a SwiftUI App using modern structured concurency (async-await). All dependencies are managed through Swift Package Manager (SPM)

### API
The Canyoneer app primarily renders cayons originating from [Ropewiki][ropewiki.com] under a Creative Commons license. This app's sister project does all the work of making that wiki-based data structured, accessible and bundled so it can be used to update our app data in real time. The API is documented on [github][https://github.com/CanyoneerApp/api].

### Updating the Bundle
One of the main goals for this project was an offline-first experience to search for and view canyons. Therefore we bundle most canyons with the app and then update from server throughout the app lifetime. The data bundled with the app becomes stale over time so 1-2 times a year, a new app version should be published with updated bundled canyon data for First Time User Experience.


#### Generating new data / server-update
To generate new data, follow the instructions at the [GITHUB PROJECT README][https://github.com/bricepollock/canyoneer-server] to generate new data, validate it and then you can either just update the server-data...or also include the new data in the app. down the zip archive for the current version. 

#### Updating local bundled data
Given the new data, replace the `index.json` file and `CanyonDetails` directory with the newly generated data. Then submit a pull request with @brice-pollock as the reviewer.

Note: When you update the bundled data, you need to also update `UpdateManager.bundledDataUpdatedAt` as this will preference newer, bundled data on update instead of continuing to use the less recently pulled data.
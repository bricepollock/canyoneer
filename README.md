# canyoneer
An app built for rendering canyoneering locations within North America

## Setup

### MapBox

This project uses MapBox. In order to develop this project you will need to create a free MapBox account.

1. Go to <https://account.mapbox.com/auth/signup>. You'll need to provide a credit card, but you will not be charged.
2. Create a secret token with all permissions.
3. Add a .netrc to your home directory (not the project directory)
4. Add the following to the file, replace variable with your token id:
machine api.mapbox.com
login mapbox
password YOUR_SECRET_MAPBOX_ACCESS_TOKEN

### Xcode
1. Install Xcode
2. Open Xcode, and open canyoneer/Canyoneer/Canyoneer.xcodeproj

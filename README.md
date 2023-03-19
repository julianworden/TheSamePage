# The Same Page
The app the local music scene has always needed.

<p align="center">
    <img src="https://github.com/julianworden/TheSamePage/blob/main/READMEImages/01%20-%20Create%20Bands%20And%20Shows.jpeg" width=30% height=30%>
    <img src="https://github.com/julianworden/TheSamePage/blob/main/READMEImages/02%20-%20Get%20Notified.jpeg" width=30% height=30%>
</p>

<p align="center">
    <img src="https://github.com/julianworden/TheSamePage/blob/main/READMEImages/03%20-%20Chats.jpeg" width=30% height=30%>
    <img src="https://github.com/julianworden/TheSamePage/blob/main/READMEImages/04%20-%20Find%20Shows.jpeg" width=30% height=30%>
</p>

## Why I Made The Same Page
<p>
I played in local bands for years, and during that time I also played many unorganized shows. It was usually challenging to gather basic, essential information such as the times each band would be playing, what time everyone needed to arrive at the venue, whether the show had backline (gear that everyone playing the show is permitted to use), contact info for everyone playing, and more.
</p>
​
​<p>
That's where The Same Page comes in!
</p>
​
​<p>
On The Same Page, every show has a group chat, so there's no longer a need to hunt down contact info for someone new. Each show also has backline, time, and location information. A show's location can even be private, making The Same Page perfect for anyone booking house shows. The Same Page is available on the iOS App Store (Android version coming soon) and it's also open source!
</p>

## On The Surface
Here's how The Same Page works: After creating an account, a user can create bands and shows that are publicly visible. From there, a user can invite others to join their bands and play their shows. During the days leading up to a show, show participants can talk to each other and contribute to the show's backline, while the show host can add location and time information to the show.

## Under the Hood
Rep Buddy was built with:

- Swift and SwiftUI
- Javascript
- MVVM architecture
- Thorough Unit Tests
- Core Location
- MapKit
- Firestore for all database management
- Firebase Auth for managing user accounts
- Firebase Cloud Messaging and Firebase Cloud Functions for push notifications
- Firebase Dynamic Links for sharing and deep linking
- The TypeSense iOS SDK for type-as-you-search user, band, and show searching

## How to Run The Same Page in Xcode
<p>
The Same Page is a Firebase app, but downloading and running the code will not give you access to the Firebase backend used for the live app, nor will it allow you to run the app without first performing some setup work.
</p>

<p>
You'll need to create your own Firebase project using Firebase Console and add your own GoogleService-Info.plist file to the TheSamePage folder. You can learn more about how to create a Firebase project [here](https://firebase.google.com/docs/ios/setup).
</p>

<p>
You'll also need to create a TypeSense Cloud cluster and enter your cluster's info in the TheSamePage/Controllers/TypesenseController.swift file. You can learn more about Typesense [here](https://typesense.org).
</p> 

<p>
To fully integrate your Firebase project with Typesense, you'll also need to add the Typesense extension to your Firebase project. You can find more info about how to do this [here](https://firebase.google.com/docs/extensions).
</p>

## Notes
There are Unit Tests included in this repo. However, keep in mind that they are designed to work with [Firebase Emulator](https://firebase.google.com/docs/emulator-suite). They're also designed to work in conjunction with certain example data that you can find in TheSamePageTests/Utilities/TestingConstants.swift. The data in this file will needed to be added to your Firestore Emulator in order for you to run the tests. I recognize that this is tedious, but the point of including these tests was to add one of the only thorough, working examples of Firebase Unit Tests to GitHub. There aren't very many others out there, and I know that just being able to see this code and use it as an example could help people trying to make a Firebase app similar to this one.

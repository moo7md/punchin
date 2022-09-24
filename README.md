# punch_in

Punch In App. Punch in with ease.

## Getting Started

You can clone this repository into your machine and run it using `flutter` to test the applications.

### Clone the application

To clone the application run the following in your desired directory:

`git clone https://github.com/moo7md/punchin.git`

### Run the application

In order to run PunchIn you have to make sure you installed `flutter` into your machine and cloned this repository.
After that go to the project directory and run the following:

`flutter run`

You might be asked to select the device you want to run the application on. For iOS you might need to to do the following:
1. Quit Xcode.
2. Delete Runner.xcworkplace
3. Delete Podfile.lock
4. Deleete Pods folder
5. Run `pod install`

If you are using Xcode 14.1 beta 1 or 2, you might encounter the issue "GameKit module not found", to solve this just comment out the code in `FIRGameCenterAuthProvider.m`

### Run the application by installing APK (For Android Only)

I will include the `.apk` file with this project if you want to install it directory into your Android device.

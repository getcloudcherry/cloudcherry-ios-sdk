# CloudCherry-iOS-SDK

iOS SDK for CloudCherry

## Steps to Install Framework:

- Drag and Drop the framework file (```CloudCherryiOSFramework.framework```) in your Xcode Project

**For Swift Projects**

- Click on File -> New -> File
- Under iOS -> Source, select ’Objective-C File’, as shown below:

![Image of creating Objective-C File]
(http://i.imgur.com/kODUOYk.png)

- Choose 'Empty File' as the File type and save it in your current Xcode project location
- When asked for an option to configure an Objective-C Bridging Header, accept and create, as shown below:

![Image of configuring and creating Objective-C File]
(http://i.imgur.com/qJyAdiw.png)

- The Bridging Header will be created under the name ```<Your Project Name>-Bridging-Header.h```
- Copy and paste ```#import <CloudCherryiOSFramework/CloudCherryiOSFramework.h>``` in your Bridging Header
- Open ```Build Settings``` of your Project Target
- Search for 'Enable Bitcode'
- Set it to 'No' as shown below:

![Image of disabling Bitcode in Project]
(http://i.imgur.com/7WrAR7l.png)

- To initialize the SDK, configure it using either by generating and using a Static Token from CloudCherry Dashboard or by using Username/Password combination (Dynamic Token):

**Static Token Initialization**

```Swift
CloudCherrySDK().setStaticToken("STATIC TOKEN HERE")
```

*OR*

**Username/Password (Dynamic Token) Initialization**

```Swift
CloudCherrySDK().setCredentials("CloudCherry Username", iPassword: "CloudCherry Password")
```

**Setting up pre-fills in SDK**

User can set up their Email ID and Mobile Number as pre-fills, which will be sent along with the survey responses

```Swift
CloudCherrySDK().setPrefill("abc@gmail.com", iMobileNumber: "9900990099")
```

**Adding Config options**

User can set up the number of valid uses and location tag

```Swift
CloudCherrySDK().setConfig(Number of valid uses, iLocation: "Mobile Number String")
```

- If you want to configure SDK to capture partial response and create a single use token then pass validUses = 1

- If you want to create SurveyToken for unlimited usage then pass validUses = -1

- If configuration parameters are not set, then the default value for validUses = -1 and location = null.

**Note:**

- Enabling partial response ensures that the user response is collected after each question and does not wait until the user hits submit button at the end of the survey. This is ideal for mobile app users, as the users may be interrupted by phone calls.
- Creating unlimited use token is not recommended. This creates junk tokens in your account.

**Setting Custom assets for Star Rating questions**

User can set custom assets for Star Rating questions

```Swift
let anUnselectedStarImage = UIImage(named: "StarOff")! // Image shown when star is unselected
let aSelectedStarImage = UIImage(named: "StarOn")! // Image shown when star is selected

CloudCherrySDK().setCustomStarRatingAssets(anUnselectedStarImage, iStarSelectedAsset: aSelectedStarImage)
```

**Setting Custom assets for Smiley questions**

User can set custom assets for Smiley questions.

```Swift
var anUnselectedSmileyImages = [UIImage]() // Image shown when smiley button is unselected
var aSelectedSmileyImages = [UIImage]() // Image shown when smiley button is selected

// Append your smiley images to above arrays in 'Sad' to 'Happy' order
            
CloudCherrySDK().setCustomSmileyRatingAssets(anUnselectedSmileyImages, iSmileySelectedAssets: aSelectedSmileyImages)
```

**Note:** 

- If any of the arrays does not contain 5 images, the SDK will switch to default asset (Emoji)

- If not mentioned, SDK will use default asset (Emoji).

**Triggering Survey**

- Finally start the survey by using the underlying syntax (Note: Here 'self' is the controller on which you wish to present the survey):

```Swift
CloudCherrySDK().showSurveyInController(self)
```

**Demo App**

The above features have been implemented in a Swift Sample app:

https://github.com/vishaluae/CloudCherry-iOS-Sample-App

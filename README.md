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
- Click on your project -> Choose the Project Target

![Image of selecting Project Target]
(http://i.imgur.com/WwdXfTC.png)

- Click on 'General' Tab
- Click the '+' button on 'Embedded Binaries'

![Image of Embedded Binaries Section]
(http://i.imgur.com/nJBS9Z6.png)

- Choose 'CloudCherryiOSFramework.framework' from the drop-down list

![Image of selecting framework]
(http://i.imgur.com/B8LPn13.png)

- Open ```Build Settings``` of your Project Target
- Search for 'Enable Bitcode'
- Set it to 'No' as shown below:

![Image of disabling Bitcode in Project]
(http://i.imgur.com/7WrAR7l.png)

- To initialize the SDK, configure it using either by generating and using a Static Token from CloudCherry Dashboard or by using Username/Password combination (Dynamic Token):

**Static Token Initialization**

```Swift
SurveyCC().setStaticToken("STATIC TOKEN HERE")
```

*OR*

**Username/Password (Dynamic Token) Initialization**

```Swift
SurveyCC().setCredentials("CloudCherry Username", iPassword: "CloudCherry Password")
```

**Triggering Survey**

- Finally start the survey by using the underlying syntax (Note: Here 'self' is the controller on which you wish to present the survey):

```Swift
SurveyCC().showSurveyInController(self)
```

**Demo App**

The above features have been implemented in a Swift Sample app:

https://github.com/vishaluae/CloudCherry-iOS-Sample-App

**Manual**

The detailed manual for iOS SDK can be found here:
https://contentcdn.azureedge.net/assets/CloudCherryDoc%20iOS%20SDK%20Manual.pdf

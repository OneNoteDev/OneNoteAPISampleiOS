## OneNote API iOS Sample README

Created by Microsoft Corporation, 2014. Provided As-is without warranty. Trademarks mentioned here are the property of their owners.

### API functionality demonstrated in this sample

The following aspects of the API are covered in this sample. You can 
find additional documentation at the links below.

* [Log-in the user using the Live SDK](http://msdn.microsoft.com/EN-US/library/office/dn575435.aspx)
* [POST simple HTML to a new OneNote QuickNotes page](http://msdn.microsoft.com/EN-US/library/office/dn575428.aspx)
* [POST multi-part message with image data included in the request](http://msdn.microsoft.com/EN-US/library/office/dn575432.aspx)
* [POST page with a URL rendered as an image](http://msdn.microsoft.com/EN-US/library/office/dn575431.aspx)
* [POST page with a PDF file attachment](http://msdn.microsoft.com/en-us/library/office/dn655137.aspx)
* [Extract the returned oneNoteClientURL and oneNoteWebURL links](http://msdn.microsoft.com/EN-US/library/office/dn575433.aspx)

### Prerequisites

**Tools and Libraries** you will need to download, install, and configure for your development environment. 

Be sure to verify the prerequisites for these too.

* [Apple XCode](https://developer.apple.com/xcode/) and the iOS SDKs.
* [Microsoft Live Connect SDK for iOS](https://github.com/liveservices/LiveSDK-for-iOS)

**Included with the sample**

We've included these packages in the ThirdPary folder, for your convenience 
using the sample. We didn't write them, and they have their own license information. 
You won't need to download them to use the sample, but below are links if you want 
to learn more.

* [AFNetworking](http://afnetworking.com/) provides networking utility classes
* [ISO8601 Date Formatter](http://boredzo.org/iso8601dateformatter/) is used to translate date/time for use with the API
  
**Accounts**

* As the developer, you'll need to [have a Microsoft account and get a client ID string](http://msdn.microsoft.com/EN-US/library/office/dn575426.aspx) 
so your app can authenticate with the Microsoft Live connect SDK.
* If you need other stuff for your iOS app development, visit the [Apple developer site](http://developer.apple.com/) to get an apple developer account. 

### Using the sample

After you've setup your development tools, and installed the prerequisites listed above,....

1. Download the repo as a ZIP file to your local Mac, and extract the files. Or, clone the repository into a local copy of Git.
2. Open the project in XCode.
3. Get a client ID string and copy it into ONSCPSCreateExamples.m (~line 28).
4. Check that the Live Connect SDK binaries are properly linked to your project 
in the Build Phases tab of the XCode Project Navigator. If they are not, use Add Other...
to add them. Also, drag and drop the LiveSDK.framework from the Project Navigator into
the Copy Bundle Resources on the Build Phases tab.
5. Build and run the app.
6. Log in using the running app, using your Microsoft account.
7. Allow the app to create new pages in OneNote.

### Version Info

This is the initial public release for this code sample.
  
### Learning More

* Visit the [dev.onenote.com](http://dev.onenote.com) Dev Center
* Contact us on [StackOverflow (tagged OneNote)](http://go.microsoft.com/fwlink/?LinkID=390182)
* Follow us on [Twitter @onenotedev](http://www.twitter.com/onenotedev)
* Read our [OneNote Developer blog](http://go.microsoft.com/fwlink/?LinkID=390183)
* Explore the API using the [apigee.com interactive console](http://go.microsoft.com/fwlink/?LinkID=392871).
Also, see the [short overview/tutorial](http://go.microsoft.com/fwlink/?LinkID=390179). 
* [API Reference](http://msdn.microsoft.com/en-us/library/office/dn575437.aspx) documentation
* [Debugging / Troubleshooting](http://msdn.microsoft.com/EN-US/library/office/dn575430.aspx)
* [Getting Started](http://go.microsoft.com/fwlink/?LinkID=331026) with the OneNote service API

  

//*********************************************************
// Copyright (c) Microsoft Corporation
// All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the ""License"");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// THIS CODE IS PROVIDED ON AN  *AS IS* BASIS, WITHOUT
// WARRANTIES OR CONDITIONS OF ANY KIND, EITHER EXPRESS
// OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED
// WARRANTIES OR CONDITIONS OF TITLE, FITNESS FOR A PARTICULAR
// PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT.
//
// See the Apache Version 2.0 License for specific language
// governing permissions and limitations under the License.
//*********************************************************

// The endpoint for the OneNote service
extern NSString* const PagesEndPoint;

// Scopes to request permissions for from Live Connect
extern NSString* const ScopeStrings;

//The buffer in number of seconds added to the current time when checking if the access token expired
extern NSInteger const TokenExpirationBuffer;

//The refresh token endpoint to be contacted when obtaining a new access token using the refresh token
extern NSString* const RefreshTokenEndpoint;

//The content type of a refresh token request
extern NSString* const RequestContentType;

//The refresh token request redirect URL
extern NSString* const RefreshTokenRedirectURL;
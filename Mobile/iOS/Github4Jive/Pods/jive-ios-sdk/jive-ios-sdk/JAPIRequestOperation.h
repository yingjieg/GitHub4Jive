//
//  JAPIRequestOperation.h
//  jive-ios-sdk
//
//  Created by Rob Derstadt on 9/28/12.
//
//    Copyright 2013 Jive Software Inc.
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//    http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//

#import "AFJSONRequestOperation.h"

@interface JAPIRequestOperation : AFJSONRequestOperation

+ (JAPIRequestOperation *)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
                                                  success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                  failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
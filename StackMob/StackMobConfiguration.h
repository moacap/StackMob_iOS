// Copyright 2011 StackMob, Inc
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@protocol STMDataProviderProtocol;

@interface StackMobConfiguration : NSObject 
@property (nonatomic, retain) NSString *publicKey;
@property (nonatomic, retain) NSString *privateKey;
@property (nonatomic, retain) NSString *appName;
@property (nonatomic, retain) NSString *subdomain;
@property (nonatomic, retain) NSString *domain;
@property (nonatomic, retain) NSString *userObjectName;
@property (nonatomic, retain) NSNumber *apiVersion;
@property (nonatomic, retain) id dataProvider;

@end
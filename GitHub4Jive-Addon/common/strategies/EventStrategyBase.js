/*
 * Copyright 2014 Jive Software
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

var jive = require("jive-sdk");
var gitHubFacade = require("../GitHubFacade");
var q = require("q");

exports.name = "BASE_THIS_SHOULD_BE_REPLACED";

/*
 * When overriding this function IT MUST return a promise.
 */
exports.setup = function(setupOptions) {
    return q(function () {
        return "SOME_TOKEN";
    }).call();
}

/*
 * When overriding this function(And you normally wouldn't) IT MUST return a promise.
 */
exports.teardown = function(teardownOptions){
    var token = teardownOptions.eventToken;
    var auth = gitHubFacade.createOauthObject(teardownOptions.gitHubToken);
    return gitHubFacade.unSubscribeFromRepoEvent(token,auth);
};
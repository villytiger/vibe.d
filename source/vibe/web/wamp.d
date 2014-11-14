/**
	WAMP router and client implementation

	Copyright: © 2014 Ilya Lyubimov
	License: Subject to the terms of the MIT license, as written in the included LICENSE.txt file.
	Authors: Ilya Lyubimov
*/
module vibe.web.rest;

//import std.algorithm;

//import vibe.vibe;

import vibe.data.json: Json;
import vibe.data.serialization;

private struct Features {
	bool callee_blackwhite_listing;
	bool caller_exclusion;
	bool caller_identification;
	bool call_trustlevels;
	bool pattern_based_registration;
	bool partitioned_rpc;
	bool call_timeout;
	bool call_canceling;
	bool progressive_call_results;
	bool subscriber_blackwhite_listing;
	bool publisher_exclusion;
	bool publisher_identification;
	bool publication_trustlevels;
	bool pattern_based_subscription;
	bool partitioned_pubsub;
	bool subscriber_metaevents;
	bool subscriber_list;
	bool event_history;

	Json toJson() const {
		Json[string] ret;
		foreach (m; __traits(allMembers, Features)) {
			static if (isRWField!(Features, m)) {
				auto mv = __traits(getMember, this, m);
				if (mv) ret[m] = mv;
			}
		}
		return Json(ret);
	}

	static Features fromJson(Json json) {
		Features r;
		foreach (m; __traits(allMembers, Features)) {
			static if (isRWField!(Features, m)) {
				if (m in json) __traits(getMember, r, m) = json[m].to!bool;
			}
		}
		return r;
	}
}

private struct Role {
	Features features;
}

private mixin template MessageJsonFunctions() {
	Json toJson() {
		auto r = [Json(messageType)];
		foreach (ref f; this.tupleof) {
			r ~= serializeToJson(f);
		}
		return Json(r);

	}

	static typeof(this) fromJson(Json json) {
		std.stdio.writeln("fromJson: ", json);
		if (Json.Type.Array != json.type) throw new Exception("Wrong message format");
		if (1 + typeof(this).tupleof.length != json.length) throw new Exception("Wrong message format");
		if (messageType != json[0].to!uint) throw new Exception("Wrong message format");

		typeof(this) r;
		foreach (i, ref f; r.tupleof) {
			if (i + 1 == json.length) {
				static if ("(@property OptionalAttribute())" ==  typeof(__traits(getAttributes, Publish.tupleof[i])).stringof) {
					break;
				} else throw new Exception("Wrong message format");
			}
			f = deserializeJson!(typeof(f))(json[i + 1]);
		}

		return r;
	}
}

private struct Hello {
	static struct Roles {
		@optional Role publisher;
		@optional Role subscriber;
		@optional Role caller;
		@optional Role callee;
	}

	static struct Details{
		Roles roles;
	}

	static immutable uint messageType = 1;

	string realm;
	Details details;

	mixin MessageJsonFunctions!();
}

private struct Welcome {
	static struct Roles {
		@optional Role broker;
		@optional Role dealer;
	}

	static struct Details{
		Roles roles;
	}

	static immutable uint messageType = 2;

	ulong session;
	Details details;

	mixin MessageJsonFunctions!();
}

private struct Abort {
	static immutable uint messageType = 3;

	Json[string] details;
	string reason;

	mixin MessageJsonFunctions!();
}

private struct Goodbye {
	static immutable uint messageType = 6;

	Json[string] details;
	string reason;

	mixin MessageJsonFunctions!();
}

private struct Error {
	static immutable uint messageType = 8;

	ulong request;
	Json[string] details;
	string error;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Publish {
	static immutable uint messageType = 16;

	ulong request;
	Json[string] options;
	string topic;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Published {
	static immutable uint messageType = 17;

	ulong request;
	ulong publication;

	mixin MessageJsonFunctions!();
}

private struct Subscribe {
	static immutable uint messageType = 32;

	ulong request;
	Json[string] options;
	string topic;

	mixin MessageJsonFunctions!();
}

private struct Subscribed {
	static immutable uint messageType = 33;

	ulong request;
	ulong subscription;

	mixin MessageJsonFunctions!();
}

private struct Unsubscribe {
	static immutable uint messageType = 34;

	ulong request;
	ulong subscription;

	mixin MessageJsonFunctions!();
}

private struct Unsubscribed {
	static immutable uint messageType = 35;

	ulong request;

	mixin MessageJsonFunctions!();
}

private struct Event {
	static immutable uint messageType = 36;

	ulong subscription;
	ulong publication;
	Json[string] details;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Call {
	static immutable uint messageType = 48;

	ulong request;
	Json[string] options;
	string procedure;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Result {
	static immutable uint messageType = 50;

	ulong request;
	Json[string] details;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Register {
	static immutable uint messageType = 64;

	ulong request;
	Json[string] options;
	string procedure;

	mixin MessageJsonFunctions!();
}

private struct Registered {
	static immutable uint messageType =65;

	ulong request;
	ulong registration;

	mixin MessageJsonFunctions!();
}

private struct Unregister {
	static immutable uint messageType = 66;

	ulong request;
	ulong registration;

	mixin MessageJsonFunctions!();
}

private struct Unregistered {
	static immutable uint messageType = 67;

	ulong request;

	mixin MessageJsonFunctions!();
}

private struct Invocation {
	static immutable uint messageType = 68;

	ulong request;
	string registration;
	Json[string] details;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

private struct Yield {
	static immutable uint messageType = 70;

	ulong request;
	Json[string] options;
	@optional Json[] arguments;
	@optional Json[string] argumentsKw;

	mixin MessageJsonFunctions!();
}

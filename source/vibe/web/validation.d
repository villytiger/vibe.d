module vibe.web.validation;

import std.typecons : Nullable;
import vibe.utils.validation;


/**
	Validated e-mail parameter type.

	See_also: $(D vibe.utils.validation.validateEmail)
*/
struct ValidEmail {
	private string m_value;

	string toString() const pure nothrow @safe { return m_value; }
	alias toString this;

	static Nullable!ValidEmail fromStringValidate(string str, string* error)
	{
		Nullable!ValidEmail ret;
		try { // TODO: refactor internally to work witout exceptions
			validateEmail(str);
			ret = ValidEmail(str);
		} catch (Exception e) *error = e.msg;
		return ret;
	}
}

///
unittest {
	class WebService {
		void setEmail(ValidEmail email)
		{
			// email is enforced to be valid here
		}

		void updateProfileInfo(Nullable!ValidEmail email, Nullable!string full_name)
		{
			// email is optional, but always valid
			// full_name is optional and not validated
		}
	}
}


/**
	Validated user name parameter type.

	See_also: $(D vibe.utils.validation.validateUsername)
*/
struct ValidUsername {
	private string m_value;

	string toString() const pure nothrow @safe { return m_value; }
	alias toString this;

	static Nullable!ValidUsername fromStringValidate(string str, string* error)
	{
		Nullable!ValidUsername ret;
		try { // TODO: refactor internally to work witout exceptions
			validateUserName(str);
			ret = ValidUsername(str);
		} catch (Exception e) *error = e.msg;
		return ret;
	}
}

///
unittest {
	class WebService {
		void setUsername(ValidUsername username)
		{
			// username is enforced to be valid here
		}

		void updateProfileInfo(Nullable!ValidUsername username, Nullable!string full_name)
		{
			// username is optional, but always valid
			// full_name is optional and not validated
		}
	}
}


/**
	Validated password parameter.

	See_also: $(D vibe.utils.validation.validatePassword)
*/
struct ValidPassword {
	private string m_value;

	string toString() const pure nothrow @safe { return m_value; }
	alias toString this;

	static Nullable!ValidPassword fromStringValidate(string str, string* error)
	{
		Nullable!ValidPassword ret;
		try { // TODO: refactor internally to work witout exceptions
			validatePassword(str, str);
			ret = ValidPassword(str);
		} catch (Exception e) *error = e.msg;
		return ret;
	}
}


/**
	Ensures that the parameter value matches that of another parameter.
*/
struct Confirm(string CONFIRMED_PARAM)
{
	enum confirmedParameter = CONFIRMED_PARAM;

	private string m_value;

	string toString() const pure nothrow @safe { return m_value; }
	alias toString this;

	static Confirm fromString(string str) { return Confirm(str); }
}

///
unittest {
	class WebService {
		void setPassword(ValidPassword password, Confirm!"password" password_confirmation)
		{
			// password is valid and guaranteed to equal password_confirmation
		}

		void setProfileInfo(string full_name, Nullable!ValidPassword password, Nullable!(Confirm!"password") password_confirmation)
		{
			// Password is valid and guaranteed to equal password_confirmation
			// It is allowed for both, password and password_confirmation
			// to be absent at the same time, but not for only one of them.
		}
	}
}


/// Little wrapper for Nullable!T to enable more comfortable initialization.
struct NullableW(T) {
	Nullable!T storage;
	alias storage this;

	this(typeof(null)) {}
	this(T val) { storage = val; }
}

template isNullable(T) {
	import std.traits;
	enum isNullable = isInstanceOf!(Nullable, T) || isInstanceOf!(NullableW, T);
}

static assert(isNullable!(Nullable!int));
static assert(isNullable!(NullableW!int));

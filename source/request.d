module tord.request;

import etc.c.curl: CurlProxy;
import std.net.curl: HTTP, CurlOption;
import std.conv;

/++
Request stucture that wraps around curl to make requests
+/
struct Request
{
private:
	string host = "socks://127.0.0.1";
	ushort port = 9050;
	CurlProxy proxytype = CurlProxy.socks5;

	string cookiefile = "";
	string[string] responseHeaders = string[string].init;

	string resolveProxyUrl()
	{
		import std.conv: to;
		return host ~ ":" ~ to!(string)(port);
	}

public:
	void setTorProxy(string host = "socks://127.0.0.1", ushort port = 9050)
	{
		this.host = host;
		this.port = port;
	}

	void setCookieJar(string cookiefile)
	{
		this.cookiefile = cookiefile;
	}

	/++
	Send GET request to a URL
	Params:
		url - URL to get resource from
		extraHeaders - Add additional headers to the request
	Returns:
		HTTP response
	+/
	auto get(string url, string[string] extraHeaders = string[string].init)
	{
		auto client = HTTP();
		client.proxy = resolveProxyUrl();
		client.proxyType = proxytype;

		foreach(i, ele; extraHeaders)
			client.addRequestHeader(i, ele);

		if(cookiefile.length > 0)
		{
			client.handle.set(CurlOption.cookiefile, cookiefile);
			client.handle.set(CurlOption.cookiejar, cookiefile);
		}

		import std.net.curl: get;
		auto reponse = get(url, client);
		responseHeaders = client.responseHeaders();

		return reponse;
	}
}

unittest
{
	auto tr = Request();
	auto tresponse = tr.get("https://api.ipify.org");
	//import std.stdio: writeln;
	//writeln(tresponse);

	import std.net.curl: get;
	auto response = get("https://api.ipify.org");
	assert(tresponse != response);
}
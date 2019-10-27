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

    void setControlPort(ushort port = 9050)
    {
        this.port = port;
    }

    bool checkTor()
    {
        string[6] paths = [
            "/usr/local/etc/tor/torrc",
            "/tor/etc/tor/torrc",
            "/etc/tor/torrc",
            "/lib/etc/tor/torrc",
            "~/.torrc",
            "~/Library/Application Support/TorBrowser-Data/torrc"
        ];

        foreach(i; paths)
        {
            import std.file: exists;
            if(i.exists)
                return true;
            string withSuffix = i ~ ".sample";
            if(withSuffix.exists)
                    return true;
        }

        return false;
    }

	void setCookieJar(string cookiefile)
	{
		this.cookiefile = cookiefile;
	}

	/++
	Send GET request to a URL over Tor proxy
	Params:
		url - URL to get resource from
		extraHeaders - Add additional headers to the request
	Returns:
		HTTP response
	+/
	auto get(string url, string[string] extraHeaders = string[string].init)
	{
        if(!checkTor())
        {
            return (char[]).init;
        }

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

	/++
	Send POST request to a URL over Tor proxy
	Params:
		url - URL to get resource from
		postData - Data to POST to the specified URL
		extraHeaders - Add additional headers to the request
	Returns:
		HTTP response
	+/
	auto post(PostUnit)(string url, const(PostUnit)[] postData, string[string] extraHeaders = string[string].init)
	{
        if(!checkTor())
        {
            return (char[]).init;
        }

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

		import std.net.curl: post;
		auto reponse = post(url, postData, client);
		responseHeaders = client.responseHeaders();

		return reponse;
	}

	/++
	Send PUT request to a URL over Tor proxy
	Params:
		url - URL to get resource from
		putData - Data to PUT to the specified URL
		extraHeaders - Add additional headers to the request
	Returns:
		HTTP response
	+/
	auto put(PutUnit)(string url, const(PutUnit)[] putData, string[string] extraHeaders = string[string].init)
	{
        if(!checkTor())
        {
            return (char[]).init;
        }

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

		import std.net.curl: put;
		auto reponse = put(url, putData, client);
		responseHeaders = client.responseHeaders();

		return reponse;
	}

	/++
	Send DEL request to a URL over Tor proxy
	Params:
		url - URL to get resource from
		extraHeaders - Add additional headers to the request
	+/
	void del(string url, string[string] extraHeaders = string[string].init)
	{
        if(!checkTor())
        {
            return;
        }

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

		import std.net.curl: del;
		del(url, client);
		responseHeaders = client.responseHeaders();
	}

    /++
    Clears the response headers
    +/
    void clearResponseHeaders()
    {
        responseHeaders = string[string].init;
    }
}

// Check if Tor is installed
unittest
{
    auto tr = Request();
    assert(tr.checkTor() == true);
}

// Check if Proxy kicks in
unittest
{
	auto tr = Request();
	const auto tresponse = tr.get("https://api.ipify.org");
	//import std.stdio: writeln;
	//writeln(tresponse);

	import std.net.curl: get;
	const auto response = get("https://api.ipify.org");
	assert(tresponse != response);
}

// Check if results are consistent.
unittest
{
	auto tr = Request();
	const auto tresponse1 = tr.get("https://api.jikan.moe/v3/character/1/pictures");
	const auto tresponse2 = tr.get("https://api.jikan.moe/v3/character/1/pictures");

    import std.algorithm: countUntil;
    assert(tresponse1[countUntil(tresponse1, "\"pictures\"") .. $], tresponse2[countUntil(tresponse2, "\"pictures\"") .. $]);
}

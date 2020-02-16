#if defined _ProxyService_included_
#endinput
#endif
#define _ProxyService_included_

methodmap ProxyService < JSON_Object
{
	public ProxyService()
	{
		return view_as<ProxyService>(new JSON_Object());
	}

	public void SetUrl(char[] url)
	{
		this.SetString("url", url);
	}

	public void GetUrl(char[] buffer, int maxlength)
	{
		this.GetString("url", buffer, maxlength);
	}

	public void SetName(char[] name)
	{
		this.SetString("name", name);
	}

	public void GetName(char[] buffer, int maxlength)
	{
		this.GetString("name", buffer, maxlength);
	}

	public void SetToken(char[] token)
	{
		this.SetString("token", token);
	}

	public void GetToken(char[] buffer, int maxlength)
	{
		this.GetString("token", buffer, maxlength);
	}

	public void SetTokenValue(char[] tokenValue)
	{
		this.SetString("token_value", tokenValue);
	}

	public void GetTokenValue(char[] buffer, int maxlength)
	{
		this.GetString("token_value", buffer, maxlength);
	}

	property ProxyServiceParams Params
	{
		public get() { return view_as<ProxyServiceParams>(this.GetObject("params")); }
		public set(ProxyServiceParams params) { this.SetObject("params", view_as<ProxyServiceParams>(params)); }
	}
}
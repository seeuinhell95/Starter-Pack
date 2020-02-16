void FireOnClientMute(int client, bool muteState)
{
 	static Handle hForward;
	
	if(hForward == null)
	{
		hForward = CreateGlobalForward("BaseComm_OnClientMute", ET_Ignore, Param_Cell, Param_Cell);
	}
	
	Call_StartForward(hForward);
	Call_PushCell(client);
	Call_PushCell(muteState);
	Call_Finish();
}
 
void FireOnClientGag(int client, bool gagState)
{
 	static Handle hForward;
	
	if(hForward == null)
	{
		hForward = CreateGlobalForward("BaseComm_OnClientGag", ET_Ignore, Param_Cell, Param_Cell);
	}
	
	Call_StartForward(hForward);
	Call_PushCell(client);
	Call_PushCell(gagState);
	Call_Finish();
}
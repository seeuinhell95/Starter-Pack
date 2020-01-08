#if defined _socket_included
  #endinput
#endif
#define _socket_included
#include <core>

enum SocketType
{
	SOCKET_TCP = 1,
	SOCKET_UDP,
	SOCKET_RAW
}

#define EMPTY_HOST 1
#define NO_HOST 2
#define CONNECT_ERROR 3
#define SEND_ERROR 4
#define BIND_ERROR 5
#define RECV_ERROR 6
#define LISTEN_ERROR 7

enum SocketOption
{
	ConcatenateCallbacks = 1,
	ForceFrameLock,
	CallbacksPerFrame,
	SocketBroadcast,
	SocketReuseAddr,
	SocketKeepAlive,
	SocketLinger,
	SocketOOBInline,
	SocketSendBuffer,
	SocketReceiveBuffer,
	SocketDontRoute,
	SocketReceiveLowWatermark,
	SocketReceiveTimeout,
	SocketSendLowWatermark,
	SocketSendTimeout,
 	DebugMode
}

funcenum SocketConnectCB
{
    public(Handle:socket, any:arg)
};

funcenum SocketIncomingCB
{
    public(Handle:socket, Handle:newSocket, const String:remoteIP[], remotePort, any:arg)
};

funcenum SocketReceiveCB
{
    public(Handle:socket, const String:receiveData[], const dataSize, any:arg)
};

funcenum SocketSendqueueEmptyCB
{
    public(Handle:socket, any:arg)
};

funcenum SocketDisconnectCB
{
    public(Handle:socket, any:arg)
};

funcenum SocketErrorCB
{
    public(Handle:socket, const errorType, const errorNum, any:arg)
};

native bool:SocketIsConnected(Handle:socket);

native Handle:SocketCreate(SocketType:protocol=SOCKET_TCP, SocketErrorCB:efunc);

native bool:SocketBind(Handle:socket, const String:hostname[], port);

native SocketConnect(Handle:socket, SocketConnectCB:cfunc, SocketReceiveCB:rfunc, SocketDisconnectCB:dfunc, const String:hostname[], port);

native bool:SocketDisconnect(Handle:socket);

native bool:SocketListen(Handle:socket, SocketIncomingCB:ifunc);

native SocketSend(Handle:socket, const String:data[], size=-1);

native SocketSendTo(Handle:socket, const String:data[], size=-1, const String:hostname[], port);

native SocketSetOption(Handle:socket, SocketOption:option, value);

native SocketSetReceiveCallback(Handle:socket, SocketReceiveCB:rfunc);

native SocketSetSendqueueEmptyCallback(Handle:socket, SocketSendqueueEmptyCB:sfunc);

native SocketSetDisconnectCallback(Handle:socket, SocketDisconnectCB:dfunc);

native SocketSetErrorCallback(Handle:socket, SocketErrorCB:efunc);

native SocketSetArg(Handle:socket, any:arg);

native SocketGetHostName(String:dest[], destLen);

public Extension:__ext_smsock =
{
	name = "Socket",
	file = "socket.ext",

#if defined AUTOLOAD_EXTENSIONS
	autoload = 1,
#else
	autoload = 0,
#endif
#if defined REQUIRE_EXTENSIONS
	required = 1,
#else
	required = 0,
#endif
};
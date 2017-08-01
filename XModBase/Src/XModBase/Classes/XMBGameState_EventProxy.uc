//---------------------------------------------------------------------------------------
//  FILE:    XMBGameState_EventProxy.uc
//  AUTHOR:  xylthixlm
//
//  USAGE
//
//  EXAMPLES
//
//  The following examples in Examples.uc use this class:
//
//  INSTALLATION
//
//  Install the XModBase core as described in readme.txt. Copy this file, and any files 
//  listed as dependencies, into your mod's Classes/ folder. You may edit this file.
//
//  DEPENDENCIES
//
//  None.
//---------------------------------------------------------------------------------------
class XMBGameState_EventProxy extends XComGameState_BaseObject;

var StateObjectReference SourceRef;
var delegate<ProxyOnEventDelegate> OnEvent;
var bool bTriggerOnceOnly;

delegate EventListenerReturn ProxyOnEventDelegate(XComGameState_BaseObject SourceState, Object EventData, Object EventSource, XComGameState GameState, Name EventID);

function EventListenerReturn EventHandler(Object EventData, Object EventSource, XComGameState GameState, Name EventID)
{
	local X2EventManager EventMgr;
	local XComGameState_BaseObject SourceState;
	local object ListenerObj;

	EventMgr = `XEVENTMGR;
	ListenerObj = self;

	SourceState = GameState.GetGameStateForObjectID(SourceRef.ObjectID);
	if (SourceState == none)
		SourceState = `XCOMHISTORY.GetGameStateForObjectID(SourceRef.ObjectID);

	if (bTriggerOnceOnly)
		EventMgr.UnRegisterFromEvent(ListenerObj, EventID);

	return OnEvent(SourceState, EventData, EventSource, GameState, EventID);
}

static function XMBGameState_EventProxy CreateProxy(XComGameState_BaseObject SourceState, XComGameState NewGameState)
{
	local XComGameState_BaseObject NewSourceState;
	local XMBGameState_EventProxy Proxy;

	Proxy = XMBGameState_EventProxy(NewGameState.CreateStateObject(class'XMBGameState_EventProxy'));
	NewSourceState = NewGameState.CreateStateObject(SourceState.class, SourceState.ObjectID);

	NewSourceState.AddComponentObject(Proxy);

	NewGameState.AddStateObject(NewSourceState);
	NewGameState.AddStateObject(Proxy);
	
	Proxy.SourceRef = NewSourceState.GetReference();

	return Proxy;
}
native float TickRate_GetCurrentTick();

native float TickRate_GetDefaultTick();

native void TickRate_SetTickRate(float fTick, bool bForceRetry = false);

forward void TickRate_OnTickRateChanged(float fOld, float fNew);
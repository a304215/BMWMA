public with sharing class ClearWaveSourcehandler 
{
	public static void doClearWaveSource(list<WaveKPISource__c> inputWKPIS_L)
	{
		delete inputWKPIS_L;
	}
}
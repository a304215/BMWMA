/* =======================================================================================================================
 * 轉換加密的function。
 * AESXXX CBC-PKCS5 padding
 * AES128:16key,16IV; 
 * AES192:24key,16IV; 
 * AES256:32key,16IV
 * CryptoFunction.decryptedData('AES128','PGMXSFDCPGMXSFDC','sfdcxpgmsfdcxpgm','18A7CA8FD67D8BD5D688934BCB79945C');
 * ======================================================================================================================= */


public with sharing class CryptoFunction 
{
    public static string decryptedData(string inputMethod, string inputKey, string inputIV, string inputData)
    {
    	string returnString = '';
    	try
    	{
    		Blob CryptoKey = blob.valueof(inputKey);
			Blob CryptoIV = blob.valueof(inputIV);
			Blob EncryptedData;
			Blob DecryptedData;
			EncryptedData = EncodingUtil.convertFromHex(inputData);
			DecryptedData = Crypto.decrypt(inputMethod, CryptoKey, CryptoIV, EncryptedData);
			returnString = DecryptedData.tostring();
    	}
    	catch (exception ex)
    	{
            system.debug(ex.getMessage());
    		returnString = 'DecryptError';
    	}
		
		return returnString;
    }
    
    public static string encryptedData(string inputMethod, string inputKey, string inputIV, string inputData)
    {
    	string returnString = '';
    	try
    	{
    		Blob CryptoKey = blob.valueof(inputKey);
			Blob CryptoIV = blob.valueof(inputIV);
			Blob ClearData = blob.valueOf(inputData);
			Blob EncryptedData;
			EncryptedData = Crypto.encrypt(inputMethod, CryptoKey, CryptoIV, ClearData);
			returnString = EncodingUtil.convertToHex(EncryptedData);
    	}
    	catch (exception ex)
    	{
            system.debug(ex.getMessage());
    		returnString = 'EncryptError';
    	}
		
		return returnString;
    }
}
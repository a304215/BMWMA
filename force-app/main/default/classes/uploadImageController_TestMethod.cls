/******** 
 * uploadImageController 的TestMethod。
 * uploadImageController、
 * 
 *
 *********/
@isTest 
public with sharing class uploadImageController_TestMethod 
{
    static testmethod void upload()
    {
    	
    	task myTask = new task();
    	insert myTask;
    	
    	
    	ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        
    	//publicLinkStart(string inputDocumentId, string inputId, string inputObject, string inputField)
    	uploadImageController.publicLinkStart(documents[0].id, myTask.id, 'task', 'description' );
    	
    }
}
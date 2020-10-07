({
	LinkStart : function(component, event){
        var uploadedFile = event.getParam("files")[0];
        var documentId = uploadedFile.documentId;
        
        var action = component.get('c.publicLinkStartGCP');
        // Set up the callback
        action.setParams({
            'inputDocumentId' : documentId,
            'inputType' : component.get('v.TheContent.theMessage.MessageType__c'),
            'inputGCP' : component.get('v.GCPSettingName'),
            'inputBucket' : component.get('v.GCPBucket'),
            'inputFolder' : component.get('v.GCPFolder')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set('v.isSpinner', true);
                var choseMME = component.get('v.TheContent.theMessage.MessageType__c');
				component.set('v.TheContent.theMessage.ImageURL__c', '');
				component.set('v.TheContent.theMessage.ImageContentURL__c', '');
				component.set('v.TheContent.theMessage.VideoURL__c', '');

                setTimeout(
	                function(){
	                	if(choseMME === "圖片")
		                {
		                    component.set('v.TheContent.theMessage.ImageURL__c', response.getReturnValue());
		                }
		                if(choseMME === "圖文")
		                {
		                    component.set('v.TheContent.theMessage.ImageContentURL__c', response.getReturnValue());
		                }
		                if(choseMME === "影片")
		                {
		                    component.set('v.TheContent.theMessage.VideoURL__c', response.getReturnValue());
		                }
		                component.set('v.isSpinner', false);
	                }
                , 3000);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
            
        });
        $A.enqueueAction(action);
	},
	LinkStart2 : function(component, event){
        var uploadedFile = event.getParam("files")[0];
        var documentId = uploadedFile.documentId;
        
        var action = component.get('c.publicLinkStartGCP');
        // Set up the callback
        action.setParams({
            'inputDocumentId' : documentId,
            'inputType' : '圖片',
            'inputGCP' : component.get('v.GCPSettingName'),
            'inputBucket' : component.get('v.GCPBucket'),
            'inputFolder' : component.get('v.GCPFolder')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set('v.isSpinner', true);
                var choseMME = '圖片';
				component.set('v.TheContent.theMessage.VideoImageURL__c', '');

                setTimeout(
	                function(){
						component.set('v.TheContent.theMessage.VideoImageURL__c', response.getReturnValue());
						component.set('v.isSpinner', false);
	                }
                , 3000);
            }
            else if (state === "INCOMPLETE") {
                // do something
            }
			else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
            
        });
        $A.enqueueAction(action);
	},
	newMessageContent : function(component, event) {
		var myAction = component.get("c.apexNewMessageContent");
        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
				var returnRecord = response.getReturnValue();
				var currentList  = component.get('v.TheContentList');
				currentList.push(returnRecord);
				//lookup欄位要加工1。
				var myCount=0;
				for(var i=0; i<currentList.length;i++)
				{
					if(currentList[i].isDeleted__c===false)
					{
						myCount++;
						currentList[i].Index__c = myCount;
					}
				}
				component.set('v.contentCount', myCount);
				component.set('v.TheContentList', currentList);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type":"success",
					"title": "Success!",
					"message": "已新增一個輪播圖卡。"
				});
				toastEvent.fire();
            } else if (state === "INCOMPLETE") {
                // do something
            } else if (state === "ERROR") {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " + errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
            }
        });
        
        $A.enqueueAction(myAction);
	},
})
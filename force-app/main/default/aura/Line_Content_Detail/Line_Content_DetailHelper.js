({
	LinkStart : function(component, event){
        var uploadedFile = event.getParam("files")[0];
        var documentId = uploadedFile.documentId;
        
        var action = component.get('c.publicLinkStart');
        // Set up the callback
        action.setParams({
            'inputDocumentId' : documentId,
            'inputType' : component.get('v.TheContent.MessageType__c')
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set('v.isSpinner', true);
                var choseMME = component.get('v.TheContent.MessageType__c');
				component.set('v.TheContent.ImageURL__c', '');
				component.set('v.TheContent.ImageContentURL__c', '');
				component.set('v.TheContent.VideoURL__c', '');

                setTimeout(
	                function(){
	                	if(choseMME === "圖片")
		                {
		                    component.set('v.TheContent.ImageURL__c', response.getReturnValue());
		                }
		                if(choseMME === "圖文")
		                {
		                    component.set('v.TheContent.ImageContentURL__c', response.getReturnValue());
		                }
		                if(choseMME === "影片")
		                {
		                    component.set('v.TheContent.VideoURL__c', response.getReturnValue());
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
        
        var action = component.get('c.publicLinkStart');
        // Set up the callback
        action.setParams({
            'inputDocumentId' : documentId,
            'inputType' : '圖片'
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            	component.set('v.isSpinner', true);
                var choseMME = '圖片';
				component.set('v.TheContent.VideoImageURL__c', '');

                setTimeout(
	                function(){
						component.set('v.TheContent.VideoImageURL__c', response.getReturnValue());
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
})
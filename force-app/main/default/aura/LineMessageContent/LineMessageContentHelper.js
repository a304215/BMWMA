({
    LinkStart : function(component, event){
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
                var choseMME = "圖片";
				component.set('v.TheContent.ImageURL__c', '');

                setTimeout(
	                function(){
                        component.set('v.TheContent.ImageURL__c', response.getReturnValue());
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
({
    doInit: function(component, event, helper){
        // Add callback behavior for when response is received
        helper.GetRecord(component);
    },
	// doInit: function(component, event, helper) {
    //     component.set("v.ContentID", component.get("v.recordId"));
    //     component.set("v.TheUserID", $A.get("$SObjectType.CurrentUser.Id"));
    //     helper.CheckRecord(component);
    //     helper.getHelpText(component);
    // },
	onChange: function (cmp, evt, helper) {
		cmp.set("v.PushType", cmp.find('select').get('v.value'));
    },
    handleUploadFinished: function (component, event, helper) {
        helper.LinkStart(component, event);
    },
    clearIMG: function (component, event, helper) {
        component.set('v.ImageURL', '');
    },
    cloneMe: function (component, event, helper) {
        component.set("v.ContentID", "");
        let oldPushNO = component.get("v.PushNO");
        let oldName = component.get("v.PushTitle");
        if(oldName.length < 76)
        {
            component.set("v.PushNO", oldPushNO+"_copy");
        	component.set("v.PushTitle", oldName+"_copy");
        	alert('已複製');
        }
        else
        {
        	alert('標題過長，請修正。');
        }
    },
    saveWorld: function (component, event, helper) {
        component.set('v.goNextDisable', true);
        helper.saveTheWorld(component, event);
    },
    backToTheFuture: function (component, event, helper) {
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/lightning/o/PushContent__c/list?"
        });
        urlEvent.fire();
    },
    previewMe: function(component, event, helper) {
        let pushTitle = component.get('v.PushTitle');
        let pushContent = component.get('v.PushContent');
        if(!pushTitle || !pushContent) {
            alert('推播標題及本文請勿為空');
            return;
        }
        helper.generatePreview(component, event);
    },
    hidePreviewMe: function(component, event, helper) {
        component.set('v.showPreview', '不要顯示');
    },
    GoNext : function(component, event, helper) {
        component.set('v.goNextDisable', true);
        helper.saveBeforeNext(component, event);
        helper.getReports(component);
    },
    goBackward : function(component, event, helper) {
        component.set('v.goNextDisable', false);
        component.set('v.isNext', false);
    },
    saveCompleted : function(component, event, helper) {
        let draft = component.get('v.reportCount');
        alert(draft);
        alert("go");
        helper.GetReportData(component,'data');
        // helper.Send_Mail(component);
        // component.set('v.isTest', false);
        // helper.saveTheCompletedRecord(component);
    },
    onSingleSelectChange : function(component, event, helper) {
        component.set('v.reportId', component.find("InputSelectSingle").get("v.value"));
        console.log(component.find("InputSelectSingle").get("v.value"));
        // helper.countTheReport(component);
    },
    handleUploadCSV : function(component, event, helper) {
        helper.uploadCSV(component, event, helper);
        
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type" : "success",
            "message": "file has been updated successfully!"
        });
        toastEvent.fire();
    },
    clearCSV : function(component, event, helper) {
        component.set('v.contentVersionId', '');
        //component.set('v.csvCounts', 0);
    },
    sendTest : function(component, event, helper) {
        component.set('v.isTest', true);
        helper.saveTheCompletedRecord(component);
    },
})
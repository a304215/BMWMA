({
    doInit : function(component, event, helper) {
        helper.getOpportunities(component, event);
        helper.getLabels(component, event);
        helper.getChooseOppt(component, event);
    },
    chooseIt : function(component, event, helper){
        var res = event.target.id;
        var cmpTarget = component.find('aaa');
        //$A.util.toggleClass(cmpTarget, 'slds-button_success');
        $A.util.addClass(cmpTarget, 'slds-button_success');

    },
    openActionWindow : function(component, event, helper) {
        var testDriveId = component.get('v.recordId');
        var opportunityId = component.get('v.opportunityId');
        var worklogId = component.get('v.worklogId');
        var surveyId = "a070l000001M02wAAC";
		window.open("https://pangerman--sur--c.cs58.visual.force.com/apex/takesurvey?id="+surveyId+
                    "&testDriveId="+testDriveId+
                    "&opportunityId="+opportunityId+
                    "&worklogId="+worklogId);
	}
})
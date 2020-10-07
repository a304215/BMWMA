({
	getResult : function(component, event, helper) {
        var myURL = component.get('v.iframeUrl');
        var mySurveyId = component.get('v.surveyId');
        var myOpptyid = event.getParam("PassOpportunity");
        var myRId = event.getParam("PassReservation");
        
        var returnURL = myURL+"?id="+mySurveyId;
        if(myOpptyid != '')
        {
            returnURL += "&opptyid="+myOpptyid;
        }
        if(myRId != '')
        {
            returnURL += "&rId="+myRId;
        }

        component.set('v.totalURL', returnURL);
    }
})
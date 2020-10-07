({
    GetReportData:function(component,data){
        console.log("let go");
        let report_name = component.get('v.reportId');
        let action = component.get("c.getRecordDetail");
        console.log(component.get('v.reportId'))
        action.setParams({ reportId : component.get('v.reportId') });
        var report_line_user = [];
        action.setCallback(this,function(response){
            var state = response.getState();
            var record = [];
            if (state === "SUCCESS") {
                console.log(response.getReturnValue().length);
                for(var i = 0 ; i < response.getReturnValue().length;i++){
                    record.push(response.getReturnValue()[i]);
                }
                console.log(record);
                component.set("v.line_user",record);
                console.log("finish");
                // this.SendMail(component);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
    SendMail:function(component){
        console.log("in sendMail");
        let action = component.get('c.getRecordDetail');
        action.setParams({line_user_record : component.get("v.line_user") });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                console.log("success");
            }
            else{
                console.log("error");
            }
        });
        $A.enqueueAction(action);
    },
    GetRecord:function(component){
        let action = component.get("c.getRecord");
        action.setCallback(this,function(response){
            var state = response.getState();
            var record = [];
            if (state === "SUCCESS") {
                console.log(response.getReturnValue().length);
                for(var i = 0 ; i < response.getReturnValue().length;i++){
                    // console.log(response.getReturnValue()[i]);
                    record.push(response.getReturnValue()[i]);
                }
                component.set("v.reportList",record);
            }
            else {
                console.log("Failed with state: " + state);
            }
        });
        $A.enqueueAction(action);
    },
	// /*CheckRecord : function(component) {
	// 	var action = component.get("c.checkRecord");
    //     action.setParams({
    //         'inputID': component.get("v.ContentID")
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var MyContent = response.getReturnValue();
    //             component.set('v.PushNO', MyContent.CampaignID__c);
    //             component.set('v.PushTitle', MyContent.Name);
    //             var mySel = component.find('select');
    //             if(MyContent.Type__c === undefined)
    //             {
    //             	mySel.set("v.value","");
    //             	component.set('v.PushType', "");
    //             }
    //             else
    //             {
    //             	mySel.set("v.value",MyContent.Type__c);
    //             	component.set('v.PushType', MyContent.Type__c);
    //             }
    //             component.set('v.ClickURL', MyContent.CTAUrl__c);
    //             component.set('v.ClickText', MyContent.CTATitle__c);
    //             component.set('v.PushContent', MyContent.Message__c);
    //             if(MyContent.ImageURL__c === undefined)
    //             {
    //             }
    //             else
    //             {
    //             	component.set('v.ImageURL', MyContent.ImageURL__c);
    //             }
    //             if(MyContent.CampaignID__c != '') {
    //                 if(MyContent.UploadMemberWaySchedule__c == 'report') {
    //                     component.set('v.reportId', MyContent.MemberSourceIdSchedule__c);
    //                     this.countTheReport(component);
    //                 }else if(MyContent.UploadMemberWaySchedule__c == 'csv') {
    //                     component.set('v.contentVersionId', MyContent.MemberSourceIdSchedule__c);
    //                     //this.countCSV(component);
    //                 }
    //                 component.set('v.pushCycleKind', MyContent.PushCycleKindSchedule__c);
    //                 component.set('v.pushImmediately', MyContent.PushImmediatelySchedule__c);
    //                 component.set('v.pushPeriod', MyContent.PushPeriodSchedule__c);
    //                 component.set('v.scheduleEndDate', MyContent.ScheduleEndDateSchedule__c);
    //                 component.set('v.scheduleStartDate', MyContent.ScheduleStartDateSchedule__c);
    //                 if(MyContent.ScheduleStartTimeSchedule__c) {
    //                     let d = new Date(null);
    //                     d.setTime(MyContent.ScheduleStartTimeSchedule__c);
    //                     component.set('v.scheduleStartTime', d.toISOString().split('T')[1].split('Z')[0]);
    //                 }
    //                 component.set('v.setDatetime', MyContent.SetDatetimeSchedule__c);
    //                 component.set('v.uploadMemberWay', MyContent.UploadMemberWaySchedule__c);
    //                 component.set('v.useJourneyBuilder', MyContent.UseJourneyBuilderSchedule__c);
    //             }
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    // 	$A.enqueueAction(action);
	// },
	// getHelpText : function(component) {
	// 	var action = component.get("c.allHelpText");
    //     action.setParams({
    //         'inputObject': 'PushContent__c'
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             var MyText = response.getReturnValue();
    //             component.set('v.fieldHelpText', MyText);
                
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    // 	$A.enqueueAction(action);
    // },
    // getReports : function(component) {
    //     var action = component.get("c.getReportDatas");
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             component.set('v.reportList', response.getReturnValue());
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    // 	$A.enqueueAction(action);
    // },
	// LinkStart : function(component, event){
    //     var uploadedFile = event.getParam("files")[0];
    //     var documentId = uploadedFile.documentId;
        
    //     var action = component.get('c.publicLinkStart');
    //     // Set up the callback
    //     action.setParams({
    //         'inputDocumentId' : documentId
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //         	component.set('v.isSpinner', true);
            	
    //             setTimeout(
	//                 function(){
	//                 	component.set("v.isIMGBlank", false);
	//                 	component.set('v.isSpinner', false);
	//                 	component.set('v.ImageURL', response.getReturnValue());
	//                 }
    //             , 3000);
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }
    //         else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
            
    //     });
    //     $A.enqueueAction(action);
    // },
    // saveTheWorld : function(component, event){
    // 	var isAllClear = true;
    // 	component.set("v.isPushNOBlank", false);
    // 	component.set("v.isPushTitleBlank", false);
    // 	component.set("v.isPushTypeBlank", false);
    // 	component.set("v.isClickURLBlank", false);
    // 	component.set("v.isClickTextBlank", false);
    // 	component.set("v.isPushContentBlank", false);
    // 	component.set("v.isIMGBlank", false);
    	
    // 	//PushNo
    //     var pushnoVal = component.get("v.PushNO");
    //     if (pushnoVal === undefined || pushnoVal === "") {
    //         component.set("v.isPushNOBlank", true);
    //         isAllClear = false;
    //     }
    //     //pushtitle
    //     var pushtitleVal = component.get("v.PushTitle");
    //     if (pushtitleVal === undefined || pushtitleVal === "") {
    //         component.set("v.isPushTitleBlank", true);
    //         isAllClear = false;
    //     }
    //     //pushtype
    //     var pushtypeVal = component.get("v.PushType");
    //     if (pushtypeVal === undefined || pushtypeVal === "") {
    //     	component.set("v.isPushTypeBlank", true);
    //         isAllClear = false;
    //     } else {
    //     	if(pushtypeVal === "open")
    //     	{
    //     		//clickurl
	// 	        var clickurlVal = component.get("v.ClickURL");
	// 	        if (clickurlVal === undefined || clickurlVal === "") {
	// 	            component.set("v.isClickURLBlank", true);
	// 	            isAllClear = false;
	// 	        } 
	// 	        //clicktext
	// 	        var clicktextVal = component.get("v.ClickText");
	// 	        if (clicktextVal === undefined || clicktextVal === "") {
	// 	            component.set("v.isClickTextBlank", true);
	// 	            isAllClear = false;
	// 	        }
    //     	}
    //     }
    //     /*
	// 	//imageurl
    //     var imageurlVal = component.get("v.ImageURL");
    //     if (imageurlVal === undefined || imageurlVal === "") {
    //     	component.set("v.isIMGBlank", true);
    //         isAllClear = false;
    //     }
    // 	*/
    //     //pushcontent
    //     var pushcontentVal = component.get('v.PushContent');
    //     if (pushcontentVal === undefined || pushcontentVal === "") {
    //        component.set("v.isPushContentBlank", true);
    //         isAllClear = false;
    //     }
    	
    //     if(isAllClear)
    //     {
    //     	var action = component.get('c.saveRecord');
	//         // Set up the callback
	//         action.setParams({
	//         	'inputID' : component.get('v.ContentID'), 
	//             'inputNo' : component.get('v.PushNO'), 
	//             'inputTitle' : component.get('v.PushTitle'), 
	//             'inputType' : component.get('v.PushType'), 
	//             'inputClickURL' : component.get('v.ClickURL'), 
	//             'inputClickText' : component.get('v.ClickText'), 
	//             'inputContent' : component.get('v.PushContent'), 
	//             'inputIamgeURL' : component.get('v.ImageURL')
	//         });
	//         action.setCallback(this, function(response) {
	//             var state = response.getState();
	//             if (state === "SUCCESS") {
    //                 alert('已更新');
	//             	var urlEvent = $A.get("e.force:navigateToURL");
	// 		        urlEvent.setParams({
	// 		            "url": "/lightning/o/PushContent__c/list?"
	// 		        });
    //                 urlEvent.fire();
	//             }
	//             else if (state === "INCOMPLETE") {
	//                 // do something
	//             }
	//             else if (state === "ERROR") {
	//                 var errors = response.getError();
	//                 if (errors) {
	//                     if (errors[0] && errors[0].message) {
	//                         console.log("Error message: " + errors[0].message);
	//                     }
	//                 } else {
	//                     console.log("Unknown error");
	//                 }
	//             }
	            
	//         });
	//         $A.enqueueAction(action);
    //     }
    //     else
    //     {
    //     	alert('請填寫紅框內容');
    //         component.set('v.goNextDisable', false);
    //     }
    // },
    // generatePreview : function(component, event){
    //     component.set('v.showPreview', 'YES');

    //     let pushTitle = component.get('v.PushTitle');
    //     if(pushTitle === undefined) {
    //         pushTitle = '';
    //     }

    //     let pushContent = component.get('v.PushContent');
    //     if(pushContent === undefined) {
    //         pushContent = '';
    //     }

    //     let imageURL = component.get('v.ImageURL');
    //     let hiddenImageStyle;
    //     if(!imageURL) {
    //         hiddenImageStyle = 'style="display: none;"';
    //     }else {
    //         hiddenImageStyle = '';
    //     }

    //     let pushContentConverted = '';
    //     pushContent.split('\n').forEach(element => {
    //         pushContentConverted += element + '<br/>';
    //     });

    //     let today = new Date();
    //     let displayDate = (today.getFullYear()) + '/' + (today.getMonth()+1) + '/' + (today.getDate()); 

    //     let returnText= '<div style="text-align:center;"><span style="font-weight:900;">鎖屏預覽</span></div>' + 
    //                     '<div class="lockContainer">' + 
    //                         '<img class="logoImg" src="' + $A.get('$Resource.CosmedAppLogo') + '"/>' + 
    //                         '<div class="titlePosition">' + 
    //                             '<span style="font-weight:900;">' + 
    //                                 '康是美' +
    //                             '</span>' + 
    //                         '</div>' + 
    //                         '<div class="pushTime">1 分 鐘 前</div>' + 
    //                         '<div class="textPosition">' + 
    //                             '<span style="font-weight:900;">' + 
    //                                 pushTitle + '<br />' +
    //                                 pushContentConverted + 
    //                             '</span>' + 
    //                         '</div>' + 
    //                         '<div class="imgPosition">' + 
    //                             '<img class="pushImg" src="' + component.get("v.ImageURL") + '" ' + hiddenImageStyle + ' />' + 
    //                         '</div>' + 
    //                     '</div>' + 

    //                     '<br />' + 
    //                     '<br />' + 

    //                     '<div style="text-align:center;"><span style="font-weight:900;">App內預覽</span></div>' + 
    //                     '<div class="innerContainer">' + 
    //                         '<img src="' + $A.get('$Resource.appPushScreenPreview') + '"/>' + 
    //                         '<div class="titlePosition">' + 
    //                             '<span>' + 
    //                                 displayDate + 
    //                                 '<ul><li><span style="width: 80%; display: inline-block;">' + pushContentConverted +  '</span></li></ul>' + 
    //                             '</span>' + 
    //                         '</div>' + 
    //                         '<div class="textPosition">' + 
    //                             '<span class="textPosition">' + 
                                    
    //                             '</span>' + 
    //                         '</div>' + 
    //                     '</div>';
    //     component.set('v.previewText', returnText);
    // },
    // saveBeforeNext : function(component, event){
    // 	var isAllClear = true;
    // 	component.set("v.isPushNOBlank", false);
    // 	component.set("v.isPushTitleBlank", false);
    // 	component.set("v.isPushTypeBlank", false);
    // 	component.set("v.isClickURLBlank", false);
    // 	component.set("v.isClickTextBlank", false);
    // 	component.set("v.isPushContentBlank", false);
    // 	component.set("v.isIMGBlank", false);
    	
    // 	//PushNo
    //     var pushnoVal = component.get("v.PushNO");
    //     if (pushnoVal === undefined || pushnoVal === "") {
    //         component.set("v.isPushNOBlank", true);
    //         isAllClear = false;
    //     }
    //     //pushtitle
    //     var pushtitleVal = component.get("v.PushTitle");
    //     if (pushtitleVal === undefined || pushtitleVal === "") {
    //         component.set("v.isPushTitleBlank", true);
    //         isAllClear = false;
    //     }
    //     //pushtype
    //     var pushtypeVal = component.get("v.PushType");
    //     if (pushtypeVal === undefined || pushtypeVal === "") {
    //     	component.set("v.isPushTypeBlank", true);
    //         isAllClear = false;
    //     } else {
    //     	if(pushtypeVal === "open")
    //     	{
    //     		//clickurl
	// 	        var clickurlVal = component.get("v.ClickURL");
	// 	        if (clickurlVal === undefined || clickurlVal === "") {
	// 	            component.set("v.isClickURLBlank", true);
	// 	            isAllClear = false;
	// 	        } 
	// 	        //clicktext
	// 	        var clicktextVal = component.get("v.ClickText");
	// 	        if (clicktextVal === undefined || clicktextVal === "") {
	// 	            component.set("v.isClickTextBlank", true);
	// 	            isAllClear = false;
	// 	        }
    //     	}
    //     }
    //     /*
	// 	//imageurl
    //     var imageurlVal = component.get("v.ImageURL");
    //     if (imageurlVal === undefined || imageurlVal === "") {
    //     	component.set("v.isIMGBlank", true);
    //         isAllClear = false;
    //     }
    // 	*/
    //     //pushcontent
    //     var pushcontentVal = component.get('v.PushContent');
    //     if (pushcontentVal === undefined || pushcontentVal === "") {
    //        component.set("v.isPushContentBlank", true);
    //         isAllClear = false;
    //     }
    	
    //     if(isAllClear)
    //     {
    //     	var action = component.get('c.saveRecord');
	//         // Set up the callback
	//         action.setParams({
	//         	'inputID' : component.get('v.ContentID'), 
	//             'inputNo' : component.get('v.PushNO'), 
	//             'inputTitle' : component.get('v.PushTitle'), 
	//             'inputType' : component.get('v.PushType'), 
	//             'inputClickURL' : component.get('v.ClickURL'), 
	//             'inputClickText' : component.get('v.ClickText'), 
	//             'inputContent' : component.get('v.PushContent'), 
	//             'inputIamgeURL' : component.get('v.ImageURL')
	//         });
	//         action.setCallback(this, function(response) {
    //             var state = response.getState();
    //             var id = response.getReturnValue();
	//             if (state === "SUCCESS") {
    //                 alert('已更新');
    //                 component.set('v.isNext', true);
    //                 component.set('v.ContentID', id);
	//             }
	//             else if (state === "INCOMPLETE") {
	//                 // do something
	//             }
	//             else if (state === "ERROR") {
	//                 var errors = response.getError();
	//                 if (errors) {
	//                     if (errors[0] && errors[0].message) {
	//                         console.log("Error message: " + errors[0].message);
	//                     }
	//                 } else {
	//                     console.log("Unknown error");
	//                 }
	//             }
    //         });
    //         $A.enqueueAction(action);
    //     }
    //     else
    //     {
    //     	alert('請填寫紅框內容');
    //         component.set('v.goNextDisable', false);
    //     }
    // },
    // saveTheCompletedRecord : function(component) {
    //     let useJourneyBuilder = component.get("v.useJourneyBuilder");
    //     let uploadMemberWay = component.get("v.uploadMemberWay");
    //     let memberSourceId;
    //     let pushPeriod = component.get("v.pushPeriod")
    //     let pushCycleKind = component.get("v.pushCycleKind");
    //     let setDatetime =  component.get("v.setDatetime");
    //     let pushImmediately =  component.get("v.pushImmediately");
    //     let scheduleStartDate = component.get("v.scheduleStartDate");
    //     let scheduleEndDate = component.get("v.scheduleEndDate");
    //     let scheduleStartTime = component.get("v.scheduleStartTime");
    //     let contentID = component.get("v.ContentID");
    //     let isTest = component.get("v.isTest");

    //     if(uploadMemberWay == 'report') {
    //         memberSourceId = component.find("InputSelectSingle").get("v.value");
    //     }else if(uploadMemberWay == 'csv') {
    //         memberSourceId = component.get("v.contentVersionId");
    //     }

    //     if(  (isTest && !memberSourceId && !useJourneyBuilder) || (pushCycleKind == 'once' && pushImmediately && !memberSourceId && !useJourneyBuilder) ) {
    //         alert('測試發送前請選擇發送人員');
    //         return;
    //     }
        
    //     if(
    //         !useJourneyBuilder && 
    //         pushCycleKind == 'cycle' && 
    //         (
    //             (scheduleStartDate && (new Date(scheduleStartDate) == 'Invalid Date')) || 
    //             (scheduleEndDate && (new Date(scheduleEndDate) == 'Invalid Date'))
    //         )
    //     ) {
    //         alert('日期格式請依照(yyyy/MM/dd)輸入');
    //         return;
    //     }else if(!useJourneyBuilder && pushCycleKind == 'cycle' && scheduleStartDate && scheduleEndDate && (new Date(scheduleStartDate) > new Date(scheduleEndDate))) {
    //         alert('排程起日請勿晚於排程訖日');
    //         return;
    //     }else if(!useJourneyBuilder && pushCycleKind == 'cycle' && scheduleStartTime) {
    //         var index = scheduleStartTime.split(':');
    //         var convertScheduleStartTime = (+index[0]) * 60 * 60 * 1000 + (+index[1]) * 60  * 1000 + (+index[2].split('.')[0]) * 1000 + (+index[2].split('.')[1]);
    //     }

    //     if(!useJourneyBuilder && pushCycleKind == 'cycle' && scheduleStartDate && scheduleEndDate) {
    //         let threeYearsLaterStartDate = new Date(scheduleStartDate);
    //         threeYearsLaterStartDate.setFullYear(threeYearsLaterStartDate.getFullYear() + 3);
    //         if(threeYearsLaterStartDate < new Date(scheduleEndDate)) {
    //             alert('循環發送起訖區間請限定在3年內');
    //             return;
    //         }
    //     }

    //     // execute schedule
    //     let action = component.get("c.saveTheCompleted");
    //     action.setParams({
    //         'useJourneyBuilder': useJourneyBuilder,
    //         'uploadMemberWay': uploadMemberWay,
    //         'memberSourceId': memberSourceId,
    //         'pushCycleKind': pushCycleKind,
    //         'frequency': pushPeriod,
    //         'setDatetime': setDatetime,
    //         'pushImmediately': pushImmediately,
    //         'scheduleStartDate': scheduleStartDate,
    //         'scheduleEndDate': scheduleEndDate,
    //         'scheduleStartTime': convertScheduleStartTime,
    //         'pushContentId': contentID,
    //         'isTest': isTest
    //     });
    //     alert('儲存中');
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         var returnStatus = response.getReturnValue();
    //         if(state === "SUCCESS" && isTest) {
    //             alert('已排程');
    //         }else if(state === "SUCCESS" && returnStatus == 'Scheduled') {
    //             alert('已排程');
    //             var urlEvent = $A.get("e.force:navigateToURL");
    //             urlEvent.setParams({
    //                 "url": "/lightning/o/PushContent__c/list?"
    //             });
    //             urlEvent.fire();
    //         }else if(state === "SUCCESS" && returnStatus == 'save Push Content') {
    //             alert('已儲存');
    //             var urlEvent = $A.get("e.force:navigateToURL");
    //             urlEvent.setParams({
    //                 "url": "/lightning/o/PushContent__c/list?"
    //             });
    //             urlEvent.fire();
    //         }else if (state === "INCOMPLETE") {
    //             // do something
    //         }else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     alert("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 alert("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    // countTheReport : function(component) {
    //     var action = component.get("c.showReportCount");
    //     action.setParams({
    //         'inputReportId': component.get("v.reportId")
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             component.set('v.reportCount', response.getReturnValue());
    //         }else if (state === "INCOMPLETE") {
    //             // do something
    //         }else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    // 	$A.enqueueAction(action);
    // },
    // countCSV : function(component, event, helper) {
    //     var action = component.get('c.countCSVController');
    //     // Set up the callback
    //     action.setParams({
    //         'contentVersionId' : component.get('v.contentVersionId')
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             //component.set('v.csvCounts', response.getReturnValue());
    //         }
    //         else if (state === "INCOMPLETE") {
    //             // do something
    //         }else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             } else {
    //                 console.log("Unknown error");
    //             }
    //         }
    //     });
    //     $A.enqueueAction(action);
    // },
    // uploadCSV : function(component, event, helper) {
    //     var uploadedFile = event.getParam("files")[0];
    //     var documentId = uploadedFile.documentId;

    //     var action = component.get('c.uploadCSVController');
    //     // Set up the callback
    //     action.setParams({
    //         'inputDocumentId' : documentId,
    //         'inputId' : component.get('v.recordId')
    //     });
    //     action.setCallback(this, function(response) {
    //         var state = response.getState();
    //         if (state === "SUCCESS") {
    //             component.set('v.contentVersionId', response.getReturnValue().contentVersionId);
    //             //component.set('v.csvCounts', response.getReturnValue().csvCounts);
    //         }else if (state === "INCOMPLETE") {
    //             alert("INCOMPLETE");
    //             // do something
    //         }else if (state === "ERROR") {
    //             var errors = response.getError();
    //             if (errors) {
    //                 if (errors[0] && errors[0].message) {
    //                     alert("Error message: " + errors[0].message);
    //                     console.log("Error message: " + errors[0].message);
    //                 }
    //             }else {
    //                 alert("Unknown error");
    //                 console.log("Unknown error");
    //             }
    //         }
            
    //     });
    //     $A.enqueueAction(action);
    // },
})
({
	initial : function(component, event, helper) {
		var myAction = component.get("c.initial");

		//傳入event id。
		myAction.setParams({
			inputContentId : component.get("v.LineContentID")
		});

        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
                var returnRecord = response.getReturnValue();
				component.set('v.TheContent', returnRecord);
				
				this.showReportList(component, event);
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
	lineAccountList : function(component, event) {
		var myAction = component.get("c.lineAccountList");

        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
                var returnRecord = response.getReturnValue();
                component.set('v.lineAccountList', returnRecord);
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
	showReportList : function(component, event) {
		var myAction = component.get("c.checkReportList");
		console.log(component.get("v.TheContent.Line_Account__c"));
		//傳入event id。
		myAction.setParams({
			inputStringName : component.get("v.TheContent.Line_Account__c")
		});

        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
                var returnRecord = response.getReturnValue();
                component.set('v.reportList', returnRecord);
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
	initialD2 : function(component, event) {
		var myAction = component.get("c.initialD2");

		//傳入event id。
		myAction.setParams({
			inputContentId : component.get("v.LineContentID")
		});

        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
                var returnList = response.getReturnValue();
				component.set('v.TheMessageList2', returnList);
				var myCount=0;
				for(var i=0; i<returnList.length;i++)
				{
					if(returnList[i].theMessage.isDeleted__c===false)
					{
						myCount++;
					}
				}
				component.set('v.messageCount', myCount);
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
	newMessage : function(component, event) {
		var myAction = component.get("c.apexNewMessage2");
        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
				var returnRecord = response.getReturnValue();
				var currentList  = component.get('v.TheMessageList2');
				currentList.push(returnRecord);
				//lookup欄位要加工1。
				var myCount=0;
				for(var i=0; i<currentList.length;i++)
				{
					if(currentList[i].theMessage.isDeleted__c===false)
					{
						myCount++;
					}
				}
				component.set('v.messageCount', myCount);
				component.set('v.TheMessageList2', currentList);
				var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type":"success",
					"title": "Success!",
					"message": "已新增一個訊息。"
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
	defaultIMOJI : function(component, event){
    	var imojilist = [
    		'8C','8D','8E','8F','90','91','92','93','94','95',
    		'96','97','98','99','9A','9B','9C','9D','9E','9F',
    		'A0','A1','A2','A3','A4','A5','A6','A7','A8','A9',
    		'AA','AB','AC','AD','AE','AF','B0','B1','B2','B3',
    		'B4','B5','B6','B7','B8','B9','78','79','7A','7B',
    		'7C','7D','7E','7F','80','81','82','83','84','85',
    		'86','87','88','89','8A','8B','01','02','03','04',
    		'05','06','07','08','09','0A','0B','0C','0D','0E',
    		'0F','10','11','12','13','15','16','17','18','19',
    		'1A','AB','1C','1D','1E','1F','20','21','22','23',
    		'24','26','27','29','2A','2B','2C','2D','2E','2F',
    		'30','31','32','33','35','36','37','38','39','3A',
    		'3B','3C','3D','40','41','42','43','44','45','47',
    		'49','4A','4B','4C','4D','4E','4F','50','51','53',
    		'54','55','56','57','58','59','5B','5C','5D','5E',
    		'5F','60','61','62','64','65','66','67','68','69',
    		'6A','6B','6C','6D','6E','6F','70','71','72','73',
    		'74','75','76','77'
    	];
    	
    	component.set('v.IMOJIlist', imojilist);
	},
	defaultSticker : function(component, event){
    	var StickerList11537 = [
			'34','35','36','37','38',
			'39','40','41','42','43',
			'44','45','46','47','48',
			'49','50','51','52','53',
			'54','55','56','57','58',
			'59','60','61','62','63',
			'64','65','66','67','68',
			'69','70','71','72','73'
    	];
    	
		component.set('v.StickerList11537', StickerList11537);
		
		var StickerList11538 = [
			'494','495','496','497','498',
			'499','500','501','502','503',
			'504','505','506','507','508',
			'509','510','511','512','513',
			'514','515','516','517','518',
			'519','520','521','522','523',
			'524','525','526','527','528',
			'529','530','531','532','533'
    	];
    	
		component.set('v.StickerList11538', StickerList11538);
		
		var StickerList11539 = [
			'10','11','12','13','14',
			'15','16','17','18','19',
			'20','21','22','23','24',
			'25','26','27','28','29',
			'30','31','32','33','34',
			'35','36','37','38','39',
			'40','41','42','43','44',
			'45','46','47','48','49'
    	];
    	
		component.set('v.StickerList11539', StickerList11539);
		
	},
	saveContent : function(component, event, helper) {
		var myContent = component.get('v.TheContent');
		
		var contentList = component.get('v.TheMessageList2');
		var JSONString = "{"
		JSONString += '"theContent":';
		JSONString += JSON.stringify(myContent);
		JSONString += ',';
		JSONString += '"theList":';
		JSONString += "[";
		for(var i=0; i<contentList.length; i++)
		{
			contentList[i].theMessage.LineMessageContent__r = undefined;
			console.log(contentList[i]);
			JSONString += '{"theMessage":';
			JSONString += JSON.stringify(contentList[i].theMessage);
			JSONString += ",";
			JSONString += '"theContentList":';
			JSONString += "[";
			if(contentList[i].theContentList.length >0)
			{
				for(var j=0; j<contentList[i].theContentList.length; j++)
				{
					JSONString += JSON.stringify(contentList[i].theContentList[j]);
					if(j+1<contentList[i].theContentList.length)
					{
						JSONString += ",";
					}
				}
			}
			JSONString += "]}";
			if(i+1<contentList.length)
			{
				JSONString += ",";
			}
		}
		JSONString += "]}";
		console.log(JSONString);
		var myAction = component.get("c.apexSaveMessage");
		//傳入event id。
		myAction.setParams({
			inputString : JSONString
		});
		
        //傳入id。
        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
				var returnRecord = response.getReturnValue();
				component.set("v.LineContentID", returnRecord);
				component.set("v.TheContent.Id", returnRecord);
				//component.set('v.TheContentList', null);
				//this.initial(component, event, helper);
				//this.initialD(component, event);
				var toastEvent = $A.get("e.force:showToast");
					toastEvent.setParams({
						"type":"success",
						"title": "Success!",
						"message": "已暫存"
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
	completeContent : function(component, event) {
		var myContent = component.get('v.TheContent');
		
		var contentList = component.get('v.TheMessageList2');
		var JSONString = "{"
		JSONString += '"theContent":';
		JSONString += JSON.stringify(myContent);
		JSONString += ',';
		JSONString += '"theList":';
		JSONString += "[";
		for(var i=0; i<contentList.length; i++)
		{
			contentList[i].theMessage.LineMessageContent__r = undefined;
			console.log(contentList[i]);
			JSONString += '{"theMessage":';
			JSONString += JSON.stringify(contentList[i].theMessage);
			JSONString += ",";
			JSONString += '"theContentList":';
			JSONString += "[";
			if(contentList[i].theContentList.length >0)
			{
				for(var j=0; j<contentList[i].theContentList.length; j++)
				{
					JSONString += JSON.stringify(contentList[i].theContentList[j]);
					if(j+1<contentList[i].theContentList.length)
					{
						JSONString += ",";
					}
				}
			}
			JSONString += "]}";
			if(i+1<contentList.length)
			{
				JSONString += ",";
			}
		}
		JSONString += "]}";
		console.log(JSONString);
		var myAction = component.get("c.apexCompleteContent");
		//傳入event id。
		myAction.setParams({
			inputString : JSONString
		});
		
        //傳入id。
        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
				var returnRecord = response.getReturnValue();
				var urlEvent = $A.get("e.force:navigateToURL");
				urlEvent.setParams({
					"url": "/lightning/o/Line_Content__c/list"
				});
				urlEvent.fire();
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
	checkMyContent : function(component, event) {
		var errorMSG = "";
		var contentList = component.get('v.TheMessageList2');

		var contenetName = component.get('v.TheContent.Name');
		if(contenetName === undefined || contenetName ==="")
		{
			errorMSG += "請設定文案名稱\n";
		}
		var lineAcc = component.get('v.TheContent.Line_Account__c');
		if(lineAcc === undefined || lineAcc ==="")
		{
			errorMSG += "請選擇Line Account\n";
		}

		for(var j=0; j<contentList.length; j++)
		{
			var myType = contentList[j].theMessage.MessageType__c;

			if(contentList[j].theMessage.isDeleted__c === false)
			{
				if(myType === "文字")
				{
					var text = contentList[j].theMessage.Text__c;
					if(text === undefined || text === "")
					{
						errorMSG += "請填寫文字\n";
					}
				}
				if(myType === "貼圖")
				{			
					if(contentList[j].theMessage.PackageID__c === undefined || contentList[j].theMessage.PackageID__c === "")
					{
						errorMSG += "請選擇貼圖\n";
					}
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].theMessage.ImageURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}
				}
				if(myType === "圖文")
				{
					var text =  contentList[j].theMessage.ImageContentURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}

					var imgTxtType = contentList[j].theMessage.PicTextType__c;
					if(imgTxtType === undefined || imgTxtType === "")
					{
						errorMSG += "請選擇圖文版型\n";
					}

					if(imgTxtType === "type1")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type2" || imgTxtType === "type3")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type4" || imgTxtType === "type6" || imgTxtType === "type7")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type5")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeD__c === undefined || contentList[j].theMessage.PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeD__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeD__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagD__c === undefined || contentList[j].theMessage.PicTextTrackingTagD__c === "")
								{
									errorMSG += "請選擇D區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type8")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeD__c === undefined || contentList[j].theMessage.PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeD__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeD__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagD__c === undefined || contentList[j].theMessage.PicTextTrackingTagD__c === "")
								{
									errorMSG += "請選擇D區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeE__c === undefined || contentList[j].theMessage.PicTextTypeE__c === "")
						{
							errorMSG += "請選擇E區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeE__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleE__c === undefined || contentList[j].theMessage.PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextE__c === undefined || contentList[j].theMessage.PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeE__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleE__c === undefined || contentList[j].theMessage.PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagE__c === undefined || contentList[j].theMessage.PicTextTrackingTagE__c === "")
								{
									errorMSG += "請選擇E區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextE__c === undefined || contentList[j].theMessage.PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeF__c === undefined || contentList[j].theMessage.PicTextTypeF__c === "")
						{
							errorMSG += "請選擇F區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeF__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleF__c === undefined || contentList[j].theMessage.PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextF__c === undefined || contentList[j].theMessage.PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeF__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleF__c === undefined || contentList[j].theMessage.PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagF__c === undefined || contentList[j].theMessage.PicTextTrackingTagF__c === "")
								{
									errorMSG += "請選擇F區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextF__c === undefined || contentList[j].theMessage.PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文文字\n";
								}
							}
						}
					}
				}
				if(myType === "影片")
				{
					var text =  contentList[j].theMessage.VideoImageURL__c;
					var text2 =  contentList[j].theMessage.VideoURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳影片縮圖圖片\n";
					}
					if(text2 === undefined)
					{
						errorMSG += "請上傳影片\n";
					}
				}
				if(myType === "確認")
				{
					var text =  contentList[j].theMessage.ConfirmText__c;
					if(text === undefined || text ==="")
					{
						errorMSG += "請輸入文字\n";
					}
					if(contentList[j].theMessage.ConfirmActionTypeA__c === undefined || contentList[j].theMessage.ConfirmActionTypeA__c === "")
					{
						errorMSG += "請選擇確認按鈕1類型：類型\n";
					}
					else if(contentList[j].theMessage.ConfirmActionTypeA__c === "TrackingTag")
					{
						if(contentList[j].theMessage.ConfirmActionLabelA__c === undefined || contentList[j].theMessage.ConfirmActionLabelA__c === "")
						{
							errorMSG += "請選擇確認按鈕1標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTrackingTagA__c === undefined || contentList[j].theMessage.ConfirmActionTrackingTagA__c === "")
						{
							errorMSG += "請選擇確認按鈕1TrackingTag\n";
						}
					}
					else
					{
						if(contentList[j].theMessage.ConfirmActionLabelA__c === undefined || contentList[j].theMessage.ConfirmActionLabelA__c === "")
						{
							errorMSG += "請選擇確認按鈕1標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTextA__c === undefined || contentList[j].theMessage.ConfirmActionTextA__c === "")
						{
							errorMSG += "請選擇確認按鈕1文字、網址\n";
						}
					}
					if(contentList[j].theMessage.ConfirmActionTypeB__c === undefined || contentList[j].theMessage.ConfirmActionTypeB__c === "")
					{
						errorMSG += "請選擇確認按鈕2類型：類型\n";
					}
					else if(contentList[j].theMessage.ConfirmActionTypeB__c === "TrackingTag")
					{
						if(contentList[j].theMessage.ConfirmActionLabelB__c === undefined || contentList[j].theMessage.ConfirmActionLabelB__c === "")
						{
							errorMSG += "請選擇確認按鈕2標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTrackingTagA__c === undefined || contentList[j].theMessage.ConfirmActionTrackingTagA__c === "")
						{
							errorMSG += "請選擇確認按鈕2TrackingTag\n";
						}
					}
					else
					{
						if(contentList[j].theMessage.ConfirmActionLabelB__c === undefined || contentList[j].theMessage.ConfirmActionLabelB__c === "")
						{
							errorMSG += "請選擇確認按鈕2標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTextB__c === undefined || contentList[j].theMessage.ConfirmActionTextB__c === "")
						{
							errorMSG += "請選擇確認按鈕2文字、網址\n";
						}
					}
				}
				if(myType === "輪播")
				{
					for(var k=0; k<contentList[j].theContentList.length; k++)
					{
						if(contentList[j].theContentList[k].isDeleted__c === false)
						{
							if(contentList[j].theContentList[k].Title__c === undefined || contentList[j].theContentList[k].Title__c === "" )
							{
								errorMSG += "請輸入輪播標題\n";
							}
							if(contentList[j].theContentList[k].Content__c === undefined || contentList[j].theContentList[k].Content__c === "" )
							{
								errorMSG += "請輸入輪播文字\n";
							}
							if(contentList[j].theContentList[k].ActionTypeA__c === undefined || contentList[j].theContentList[k].ActionTypeA__c === "" )
							{
								errorMSG += "請輸入1類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeA__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelA__c === undefined || contentList[j].theContentList[k].ActionLabelA__c === "")
								{
									errorMSG += "請輸入1標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagA__c === undefined || contentList[j].theContentList[k].TrackingTagA__c === "")
								{
									errorMSG += "請輸入1TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelA__c === undefined || contentList[j].theContentList[k].ActionLabelA__c === "")
								{
									errorMSG += "請輸入1標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataA__c === undefined || contentList[j].theContentList[k].ActionDataA__c === "")
								{
									errorMSG += "請輸入1文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeB__c === undefined || contentList[j].theContentList[k].ActionTypeB__c === "" )
							{
								//errorMSG += "請輸入2類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeB__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelB__c === undefined || contentList[j].theContentList[k].ActionLabelB__c === "")
								{
									errorMSG += "請輸入2標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagB__c === undefined || contentList[j].theContentList[k].TrackingTagB__c === "")
								{
									errorMSG += "請輸入2TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelB__c === undefined || contentList[j].theContentList[k].ActionLabelB__c === "")
								{
									errorMSG += "請輸入2標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataB__c === undefined || contentList[j].theContentList[k].ActionDataB__c === "")
								{
									errorMSG += "請輸入2文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeC__c === undefined || contentList[j].theContentList[k].ActionTypeC__c === "" )
							{
								//errorMSG += "請輸入3類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeC__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelC__c === undefined || contentList[j].theContentList[k].ActionLabelC__c === "")
								{
									errorMSG += "請輸入3標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagC__c === undefined || contentList[j].theContentList[k].TrackingTagC__c === "")
								{
									errorMSG += "請輸入3TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelC__c === undefined || contentList[j].theContentList[k].ActionLabelC__c === "")
								{
									errorMSG += "請輸入3標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataC__c === undefined || contentList[j].theContentList[k].ActionDataC__c === "")
								{
									errorMSG += "請輸入3文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeD__c === undefined || contentList[j].theContentList[k].ActionTypeD__c === "" )
							{
								//errorMSG += "請輸入4類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeD__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelD__c === undefined || contentList[j].theContentList[k].ActionLabelD__c === "")
								{
									errorMSG += "請輸入ˋ標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagD__c === undefined || contentList[j].theContentList[k].TrackingTagD__c === "")
								{
									errorMSG += "請輸入4TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelD__c === undefined || contentList[j].theContentList[k].ActionLabelD__c === "")
								{
									errorMSG += "請輸入4標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataD__c === undefined || contentList[j].theContentList[k].ActionDataD__c === "")
								{
									errorMSG += "請輸入4文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeE__c === undefined || contentList[j].theContentList[k].ActionTypeE__c === "" )
							{
								//errorMSG += "請輸入5類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeE__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelE__c === undefined || contentList[j].theContentList[k].ActionLabelE__c === "")
								{
									errorMSG += "請輸入5標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagE__c === undefined || contentList[j].theContentList[k].TrackingTagE__c === "")
								{
									errorMSG += "請輸入5TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelE__c === undefined || contentList[j].theContentList[k].ActionLabelE__c === "")
								{
									errorMSG += "請輸入5標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataE__c === undefined || contentList[j].theContentList[k].ActionDataE__c === "")
								{
									errorMSG += "請輸入5文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeF__c === undefined || contentList[j].theContentList[k].ActionTypeF__c === "" )
							{
								//errorMSG += "請輸入6類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeF__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelF__c === undefined || contentList[j].theContentList[k].ActionLabelF__c === "")
								{
									errorMSG += "請輸入6標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagF__c === undefined || contentList[j].theContentList[k].TrackingTagF__c === "")
								{
									errorMSG += "請輸入6TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelF__c === undefined || contentList[j].theContentList[k].ActionLabelF__c === "")
								{
									errorMSG += "請輸入6標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataF__c === undefined || contentList[j].theContentList[k].ActionDataF__c === "")
								{
									errorMSG += "請輸入6文字、網址\n";
								}
							}
						}
					}
				}
			}
		}

		if(errorMSG != "")
		{
			alert(errorMSG);
			component.set("v.errMSG", errorMSG);
		}
		else
		{
			component.set("v.errMSG", "");
		}
	},
	checkMyCompleteContent : function(component, event) {
		var errorMSG = "";
		var contentList = component.get('v.TheMessageList2');

		var contenetName = component.get('v.TheContent.Name');
		if(contenetName === undefined || contenetName ==="")
		{
			errorMSG += "請設定文案名稱\n";
		}
		var lineAcc = component.get('v.TheContent.Line_Account__c');
		if(lineAcc === undefined || lineAcc ==="")
		{
			errorMSG += "請選擇Line Account\n";
		}
		var sendNow = component.get('v.TheContent.SendNow__c');
		if(sendNow === undefined || sendNow ==="" || sendNow ===false)
		{
			var sendTime = component.get('v.TheContent.ScheduleTime__c');
			if(sendTime === undefined || sendTime ==="")
			{
				errorMSG += "請設定發送時間\n";
			}
		}
		
		for(var j=0; j<contentList.length; j++)
		{
			var myType = contentList[j].theMessage.MessageType__c;

			if(contentList[j].theMessage.isDeleted__c === false)
			{
				if(myType === "文字")
				{
					var text = contentList[j].theMessage.Text__c;
					if(text === undefined || text === "")
					{
						errorMSG += "請填寫文字\n";
					}
				}
				if(myType === "貼圖")
				{			
					if(contentList[j].theMessage.PackageID__c === undefined || contentList[j].theMessage.PackageID__c === "")
					{
						errorMSG += "請選擇貼圖\n";
					}
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].theMessage.ImageURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}
				}
				if(myType === "圖文")
				{
					var text =  contentList[j].theMessage.ImageContentURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}

					var imgTxtType = contentList[j].theMessage.PicTextType__c;
					if(imgTxtType === undefined || imgTxtType === "")
					{
						errorMSG += "請選擇圖文版型\n";
					}

					if(imgTxtType === "type1")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type2" || imgTxtType === "type3")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type4" || imgTxtType === "type6" || imgTxtType === "type7")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type5")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeD__c === undefined || contentList[j].theMessage.PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeD__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeD__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagD__c === undefined || contentList[j].theMessage.PicTextTrackingTagD__c === "")
								{
									errorMSG += "請選擇D區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type8")
					{
						if(contentList[j].theMessage.PicTextTypeA__c === undefined || contentList[j].theMessage.PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeA__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeA__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleA__c === undefined || contentList[j].theMessage.PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagA__c === undefined || contentList[j].theMessage.PicTextTrackingTagA__c === "")
								{
									errorMSG += "請選擇A區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextA__c === undefined || contentList[j].theMessage.PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeB__c === undefined || contentList[j].theMessage.PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeB__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeB__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleB__c === undefined || contentList[j].theMessage.PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagB__c === undefined || contentList[j].theMessage.PicTextTrackingTagB__c === "")
								{
									errorMSG += "請選擇B區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextB__c === undefined || contentList[j].theMessage.PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeC__c === undefined || contentList[j].theMessage.PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeC__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeC__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleC__c === undefined || contentList[j].theMessage.PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagC__c === undefined || contentList[j].theMessage.PicTextTrackingTagC__c === "")
								{
									errorMSG += "請選擇C區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextC__c === undefined || contentList[j].theMessage.PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeD__c === undefined || contentList[j].theMessage.PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeD__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeD__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleD__c === undefined || contentList[j].theMessage.PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagD__c === undefined || contentList[j].theMessage.PicTextTrackingTagD__c === "")
								{
									errorMSG += "請選擇D區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextD__c === undefined || contentList[j].theMessage.PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeE__c === undefined || contentList[j].theMessage.PicTextTypeE__c === "")
						{
							errorMSG += "請選擇E區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeE__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleE__c === undefined || contentList[j].theMessage.PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextE__c === undefined || contentList[j].theMessage.PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeE__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleE__c === undefined || contentList[j].theMessage.PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagE__c === undefined || contentList[j].theMessage.PicTextTrackingTagE__c === "")
								{
									errorMSG += "請選擇E區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextE__c === undefined || contentList[j].theMessage.PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文文字\n";
								}
							}
						}

						if(contentList[j].theMessage.PicTextTypeF__c === undefined || contentList[j].theMessage.PicTextTypeF__c === "")
						{
							errorMSG += "請選擇F區類型\n";
						}
						else
						{
							if(contentList[j].theMessage.PicTextTypeF__c === "網址")
							{
								if(contentList[j].theMessage.PicTextTitleF__c === undefined || contentList[j].theMessage.PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextMTextF__c === undefined || contentList[j].theMessage.PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文網址\n";
								}
							}
							else if(contentList[j].theMessage.PicTextTypeF__c === "TrackingTag")
							{
								if(contentList[j].theMessage.PicTextTitleF__c === undefined || contentList[j].theMessage.PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].theMessage.PicTextTrackingTagF__c === undefined || contentList[j].theMessage.PicTextTrackingTagF__c === "")
								{
									errorMSG += "請選擇F區TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theMessage.PicTextMTextF__c === undefined || contentList[j].theMessage.PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文文字\n";
								}
							}
						}
					}
				}
				if(myType === "影片")
				{
					var text =  contentList[j].theMessage.VideoImageURL__c;
					var text2 =  contentList[j].theMessage.VideoURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳影片縮圖圖片\n";
					}
					if(text2 === undefined)
					{
						errorMSG += "請上傳影片\n";
					}
				}
				if(myType === "確認")
				{
					var text =  contentList[j].theMessage.ConfirmText__c;
					if(text === undefined || text ==="")
					{
						errorMSG += "請輸入文字\n";
					}
					if(contentList[j].theMessage.ConfirmActionTypeA__c === undefined || contentList[j].theMessage.ConfirmActionTypeA__c === "")
					{
						errorMSG += "請選擇確認按鈕1類型：類型\n";
					}
					else if(contentList[j].theMessage.ConfirmActionTypeA__c === "TrackingTag")
					{
						if(contentList[j].theMessage.ConfirmActionLabelA__c === undefined || contentList[j].theMessage.ConfirmActionLabelA__c === "")
						{
							errorMSG += "請選擇確認按鈕1標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTrackingTagA__c === undefined || contentList[j].theMessage.ConfirmActionTrackingTagA__c === "")
						{
							errorMSG += "請選擇確認按鈕1TrackingTag\n";
						}
					}
					else
					{
						if(contentList[j].theMessage.ConfirmActionLabelA__c === undefined || contentList[j].theMessage.ConfirmActionLabelA__c === "")
						{
							errorMSG += "請選擇確認按鈕1標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTextA__c === undefined || contentList[j].theMessage.ConfirmActionTextA__c === "")
						{
							errorMSG += "請選擇確認按鈕1文字、網址\n";
						}
					}
					if(contentList[j].theMessage.ConfirmActionTypeB__c === undefined || contentList[j].theMessage.ConfirmActionTypeB__c === "")
					{
						errorMSG += "請選擇確認按鈕2類型：類型\n";
					}
					else if(contentList[j].theMessage.ConfirmActionTypeB__c === "TrackingTag")
					{
						if(contentList[j].theMessage.ConfirmActionLabelB__c === undefined || contentList[j].theMessage.ConfirmActionLabelB__c === "")
						{
							errorMSG += "請選擇確認按鈕2標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTrackingTagA__c === undefined || contentList[j].theMessage.ConfirmActionTrackingTagA__c === "")
						{
							errorMSG += "請選擇確認按鈕2TrackingTag\n";
						}
					}
					else
					{
						if(contentList[j].theMessage.ConfirmActionLabelB__c === undefined || contentList[j].theMessage.ConfirmActionLabelB__c === "")
						{
							errorMSG += "請選擇確認按鈕2標籤\n";
						}
						if(contentList[j].theMessage.ConfirmActionTextB__c === undefined || contentList[j].theMessage.ConfirmActionTextB__c === "")
						{
							errorMSG += "請選擇確認按鈕2文字、網址\n";
						}
					}
				}
				if(myType === "輪播")
				{
					for(var k=0; k<contentList[j].theContentList.length; k++)
					{
						if(contentList[j].theContentList[k].isDeleted__c === false)
						{
							if(contentList[j].theContentList[k].Title__c === undefined || contentList[j].theContentList[k].Title__c === "" )
							{
								errorMSG += "請輸入輪播標題\n";
							}
							if(contentList[j].theContentList[k].Content__c === undefined || contentList[j].theContentList[k].Content__c === "" )
							{
								errorMSG += "請輸入輪播文字\n";
							}
							if(contentList[j].theContentList[k].ActionTypeA__c === undefined || contentList[j].theContentList[k].ActionTypeA__c === "" )
							{
								errorMSG += "請輸入1類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeA__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelA__c === undefined || contentList[j].theContentList[k].ActionLabelA__c === "")
								{
									errorMSG += "請輸入1標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagA__c === undefined || contentList[j].theContentList[k].TrackingTagA__c === "")
								{
									errorMSG += "請輸入1TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelA__c === undefined || contentList[j].theContentList[k].ActionLabelA__c === "")
								{
									errorMSG += "請輸入1標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataA__c === undefined || contentList[j].theContentList[k].ActionDataA__c === "")
								{
									errorMSG += "請輸入1文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeB__c === undefined || contentList[j].theContentList[k].ActionTypeB__c === "" )
							{
								//errorMSG += "請輸入2類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeB__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelB__c === undefined || contentList[j].theContentList[k].ActionLabelB__c === "")
								{
									errorMSG += "請輸入2標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagB__c === undefined || contentList[j].theContentList[k].TrackingTagB__c === "")
								{
									errorMSG += "請輸入2TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelB__c === undefined || contentList[j].theContentList[k].ActionLabelB__c === "")
								{
									errorMSG += "請輸入2標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataB__c === undefined || contentList[j].theContentList[k].ActionDataB__c === "")
								{
									errorMSG += "請輸入2文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeC__c === undefined || contentList[j].theContentList[k].ActionTypeC__c === "" )
							{
								//errorMSG += "請輸入3類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeC__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelC__c === undefined || contentList[j].theContentList[k].ActionLabelC__c === "")
								{
									errorMSG += "請輸入3標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagC__c === undefined || contentList[j].theContentList[k].TrackingTagC__c === "")
								{
									errorMSG += "請輸入3TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelC__c === undefined || contentList[j].theContentList[k].ActionLabelC__c === "")
								{
									errorMSG += "請輸入3標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataC__c === undefined || contentList[j].theContentList[k].ActionDataC__c === "")
								{
									errorMSG += "請輸入3文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeD__c === undefined || contentList[j].theContentList[k].ActionTypeD__c === "" )
							{
								//errorMSG += "請輸入4類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeD__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelD__c === undefined || contentList[j].theContentList[k].ActionLabelD__c === "")
								{
									errorMSG += "請輸入ˋ標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagD__c === undefined || contentList[j].theContentList[k].TrackingTagD__c === "")
								{
									errorMSG += "請輸入4TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelD__c === undefined || contentList[j].theContentList[k].ActionLabelD__c === "")
								{
									errorMSG += "請輸入4標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataD__c === undefined || contentList[j].theContentList[k].ActionDataD__c === "")
								{
									errorMSG += "請輸入4文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeE__c === undefined || contentList[j].theContentList[k].ActionTypeE__c === "" )
							{
								//errorMSG += "請輸入5類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeE__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelE__c === undefined || contentList[j].theContentList[k].ActionLabelE__c === "")
								{
									errorMSG += "請輸入5標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagE__c === undefined || contentList[j].theContentList[k].TrackingTagE__c === "")
								{
									errorMSG += "請輸入5TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelE__c === undefined || contentList[j].theContentList[k].ActionLabelE__c === "")
								{
									errorMSG += "請輸入5標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataE__c === undefined || contentList[j].theContentList[k].ActionDataE__c === "")
								{
									errorMSG += "請輸入5文字、網址\n";
								}
							}

							if(contentList[j].theContentList[k].ActionTypeF__c === undefined || contentList[j].theContentList[k].ActionTypeF__c === "" )
							{
								//errorMSG += "請輸入6類型\n";
							}
							else if(contentList[j].theContentList[k].ActionTypeF__c === "TrackingTag")
							{
								if(contentList[j].theContentList[k].ActionLabelF__c === undefined || contentList[j].theContentList[k].ActionLabelF__c === "")
								{
									errorMSG += "請輸入6標籤\n";
								}
								if(contentList[j].theContentList[k].TrackingTagF__c === undefined || contentList[j].theContentList[k].TrackingTagF__c === "")
								{
									errorMSG += "請輸入6TrackingTag\n";
								}
							}
							else
							{
								if(contentList[j].theContentList[k].ActionLabelF__c === undefined || contentList[j].theContentList[k].ActionLabelF__c === "")
								{
									errorMSG += "請輸入6標籤\n";
								}
								if(contentList[j].theContentList[k].ActionDataF__c === undefined || contentList[j].theContentList[k].ActionDataF__c === "")
								{
									errorMSG += "請輸入6文字、網址\n";
								}
							}
						}
					}
				}
			}
		}

		if(errorMSG != "")
		{
			alert(errorMSG);
			component.set("v.errMSG", errorMSG);
		}
		else
		{
			component.set("v.errMSG", "");
		}
    },
    generateReview : function(component, event) {
		var contentList = component.get('v.TheMessageList2');
		var currentT = new Date();
		var yyyy = currentT.getFullYear();
		var mm = currentT.getMonth() < 9 ? "0" + (currentT.getMonth() + 1) : (currentT.getMonth() + 1); // getMonth() is zero-based
		var dd  = currentT.getDate() < 10 ? "0" + currentT.getDate() : currentT.getDate();
		var hh = currentT.getHours() < 10 ? "0" + currentT.getHours() : currentT.getHours();
		var min = currentT.getMinutes() < 10 ? "0" + currentT.getMinutes() : currentT.getMinutes();
		var ss = currentT.getSeconds() < 10 ? "0" + currentT.getSeconds() : currentT.getSeconds();
		var timeString = yyyy+'-'+mm+'-'+dd+'<br/>'+hh+':'+min+':'+ss;

		var currentDetail = 0;
		component.set('v.previewText1', '');
		component.set('v.previewText2', '');
		component.set('v.previewText3', '');
		component.set('v.previewText4', '');
		component.set('v.previewText5', '');

		for(var j=0; j<contentList.length; j++)
		{
			if(contentList[j].theMessage.isDeleted__c === false)
			{
				var myType = contentList[j].theMessage.MessageType__c;
                var returnText = '<div class="message-box-outside"><div class="message-box-user"><img style="vertical-align:top;padding:3px;" src="'+$A.get('$Resource.LineLogo_p')+'" width="35"/><div class="message-text-user">';

				if(myType === "文字")
				{
					var text = contentList[j].theMessage.Text__c;
					if(text === undefined)
					{
						text = "";
					}
					
					var allBR = text.split('\n');
					
					for(var i=0; i< allBR.length; i++)
					{
						returnText += allBR[i] + '<br/>';
					}
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
					if(returnText.indexOf('0x1000') !== -1)
					{
						var returnText2 = '';
						var allIMG = returnText.split('0x1000');
						
						for(var i=0; i< allIMG.length; i++)
						{
							if( i < (allIMG.length -1))
							{
								var picNo = allIMG[i+1].substring(0,2);
								if(i === 0)
								{
									returnText2 += allIMG[i] + '<img src="'+$A.get('$Resource.LineEMOJI_p')+'/'+picNo+'.png"/>';
								}
								else
								{
									returnText2 += allIMG[i].substring(2,allIMG[i].length) + '<img src="'+$A.get('$Resource.LineEMOJI_p')+'/'+picNo+'.png"/>';
								}
								
							}
							else
							{
								returnText2 += allIMG[i].substring(2,allIMG[i].length);
							}
						}
						
						returnText = returnText2;
					}
				}
				if(myType === "貼圖")
				{				
					var stickerUrl = $A.get('$Resource.LineSticker_p')+'/'+contentList[j].theMessage.PackageID__c+
						'/'+contentList[j].theMessage.StickerID__c+'.png';
					returnText += '<img src="'+stickerUrl+'" width="150"/>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].theMessage.ImageURL__c;
					if(text === undefined)
					{
						text = "";
					}
					returnText += '<img src="'+text+'" width="300"/>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
				}
				if(myType === "圖文")
				{
					component.set('v.showPreview', 'YES');
					var text =  contentList[j].theMessage.ImageContentURL__c;
					if(text === undefined)
					{
						text = "";
					}
					returnText += '<img src="'+text+'" width="300"/>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
					
				}
				if(myType === "影片")
				{
					component.set('v.showPreview', 'YES');
					var text =  contentList[j].theMessage.VideoImageURL__c;
					var text2 =  contentList[j].theMessage.VideoURL__c;
					if(text === undefined)
					{
						text = "";
					}
					if(text2 === undefined)
					{
						text2 = "";
					}
					returnText += '<a class="ng-scope" href="'+text2+'"><img src="'+text+'" width="300"/></a>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';	
				}
				if(myType === "確認")
				{
					var text = contentList[j].theMessage.ConfirmText__c;
					if(text === undefined)
					{
						text = "";
					}
					
					var allBR = text.split('\n');
					
					for(var i=0; i< allBR.length; i++)
					{
						returnText += allBR[i] + '<br/>';
					}
					returnText += '<div style="min-width:180px;background-color:black;border-top:1px solid black;"><div style="text-align:center; float:left; width:50%; border-right:1px solid black;"><a href="#">'+contentList[j].theMessage.ConfirmActionLabelA__c+'</a></div><div style="text-align:center;float:right; width:50%;"><a href="#">'+contentList[j].theMessage.ConfirmActionLabelB__c+'</a></div></div>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
				}
				if(myType === "輪播")
				{	
					returnText = '<div class="message-box-outside"><div class="message-box-user"><img style="vertical-align:top;padding:3px;" src="'+$A.get('$Resource.LineLogo_p')+'" width="35"/><div class="message-text-user2">';
					var txtHTML = '<div class="container"><div class="innerContainer">';
					var divWidth = '150px;';
					for(var k=0; k<contentList[j].theContentList.length; k++)
					{
						txtHTML += '<div style="float:left;width:'+divWidth+';padding:5px;border:1px solid black; min-height:420px;">';
						if(contentList[j].theContentList[k].ImageURL__c === undefined || contentList[j].theContentList[k].ImageURL__c === "")
						{

						}
						else
						{
							txtHTML += '<img style="width:138px;height:180px;" src="'+contentList[j].theContentList[k].ImageURL__c+'"/>'+'<br/>' ;
						}
						txtHTML += '<span style="font-weight:bold;font-size:18px;">'+contentList[j].theContentList[k].Title__c +'</span><br/>' ;
						var allBR = contentList[j].theContentList[k].Content__c.split('\n');
						for(var i=0; i< allBR.length; i++)
						{
							txtHTML += allBR[i] + '<br/>';
						}
						if(contentList[j].theContentList[k].ActionLabelA__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelA__c +'</a></div>' ;
						}
						if(contentList[j].theContentList[k].ActionLabelB__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelB__c +'</a></div>' ;
						}
						if(contentList[j].theContentList[k].ActionLabelC__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelC__c +'</a></div>' ;
						}
						if(contentList[j].theContentList[k].ActionLabelD__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelD__c +'</a></div>' ;
						}
						if(contentList[j].theContentList[k].ActionLabelE__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelE__c +'</a></div>' ;
						}
						if(contentList[j].theContentList[k].ActionLabelF__c != undefined)
						{
							txtHTML += '<div style="text-align:center;"><a href="#">'+contentList[j].theContentList[k].ActionLabelF__c +'</a></div>' ;
						}
						txtHTML += '</div><div style="float:left;width:5px;min-height:420px;">&nbsp;</div>';
					}
					
					txtHTML += '</div></div>';
					returnText += txtHTML + '</div></div></div>';
				}
				if(currentDetail===0)
				{
					component.set('v.previewText1', returnText);
				}
				if(currentDetail===1)
				{
					component.set('v.previewText2', returnText);
				}
				if(currentDetail===2)
				{
					component.set('v.previewText3', returnText);
				}
				if(currentDetail===3)
				{
					component.set('v.previewText4', returnText);
				}
				if(currentDetail===4)
				{
					component.set('v.previewText5', returnText);
				}
				currentDetail++;
			}
		}
    }
})
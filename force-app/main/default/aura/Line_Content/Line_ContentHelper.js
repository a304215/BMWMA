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
	initialD : function(component, event) {
		var myAction = component.get("c.initialD");

		//傳入event id。
		myAction.setParams({
			inputContentId : component.get("v.LineContentID")
		});

        myAction.setCallback(this, function(response) {
			var state = response.getState();
			
            if (state === "SUCCESS") {
                var returnList = response.getReturnValue();
				component.set('v.TheContentList', returnList);
				var myCount=0;
				for(var i=0; i<returnList.length;i++)
				{
					if(returnList[i].isDeleted__c===false)
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
	newContent : function(component, event) {
		var myAction = component.get("c.apexNewContent");
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
					}
				}
				component.set('v.messageCount', myCount);
				component.set('v.TheContentList', currentList);
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
		
		var contentList = component.get('v.TheContentList');
		var JSONString = "{"
		JSONString += '"theContent":';
		JSONString += JSON.stringify(myContent);
		JSONString += ',';
		JSONString += '"theList":';
		JSONString += "[";
		for(var i=0; i<contentList.length; i++)
		{
			console.log(contentList[i]);
			JSONString += JSON.stringify(contentList[i]);
			if(i+1<contentList.length)
			{
				JSONString += ",";
			}
		}
		JSONString += "]}";
		console.log(JSONString);
		var myAction = component.get("c.apexSaveContent");
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
		
		var contentList = component.get('v.TheContentList');
		var JSONString = "{"
		JSONString += '"theContent":';
		JSONString += JSON.stringify(myContent);
		JSONString += ',';
		JSONString += '"theList":';
		JSONString += "[";
		for(var i=0; i<contentList.length; i++)
		{
			console.log(contentList[i]);
			JSONString += JSON.stringify(contentList[i]);
			if(i+1<contentList.length)
			{
				JSONString += ",";
			}
		}
		JSONString += "]}";
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
		var contentList = component.get('v.TheContentList');

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
			var myType = contentList[j].MessageType__c;

			if(contentList[j].isDeleted__c === false)
			{
				if(myType === "文字")
				{
					var text = contentList[j].Text1__c;
					if(text === undefined || text === "")
					{
						errorMSG += "請填寫文字\n";
					}
				}
				if(myType === "貼圖")
				{			
					if(contentList[j].PackageID__c === undefined || contentList[j].PackageID__c === "")
					{
						errorMSG += "請選擇貼圖\n";
					}
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].ImageURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}
				}
				if(myType === "圖文")
				{
					var text =  contentList[j].ImageContentURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}

					var imgTxtType = contentList[j].PicTextType__c;
					if(imgTxtType === undefined || imgTxtType === "")
					{
						errorMSG += "請選擇圖文版型\n";
					}

					if(imgTxtType === "type1")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type2" || imgTxtType === "type3")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type4" || imgTxtType === "type6" || imgTxtType === "type7")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type5")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeD__c === undefined || contentList[j].PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeD__c === "網址")
							{
								if(contentList[j].PicTextTitleD__c === undefined || contentList[j].PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type8")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeD__c === undefined || contentList[j].PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeD__c === "網址")
							{
								if(contentList[j].PicTextTitleD__c === undefined || contentList[j].PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeE__c === undefined || contentList[j].PicTextTypeE__c === "")
						{
							errorMSG += "請選擇E區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeE__c === "網址")
							{
								if(contentList[j].PicTextTitleE__c === undefined || contentList[j].PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextE__c === undefined || contentList[j].PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextE__c === undefined || contentList[j].PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeF__c === undefined || contentList[j].PicTextTypeF__c === "")
						{
							errorMSG += "請選擇F區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeF__c === "網址")
							{
								if(contentList[j].PicTextTitleF__c === undefined || contentList[j].PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextF__c === undefined || contentList[j].PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextF__c === undefined || contentList[j].PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文文字\n";
								}
							}
						}
					}
				}
				if(myType === "影片")
				{
					var text =  contentList[j].VideoImageURL__c;
					var text2 =  contentList[j].VideoURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳影片縮圖圖片\n";
					}
					if(text2 === undefined)
					{
						errorMSG += "請上傳影片\n";
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
		var contentList = component.get('v.TheContentList');

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
			var myType = contentList[j].MessageType__c;

			if(contentList[j].isDeleted__c === false)
			{
				if(myType === "文字")
				{
					var text = contentList[j].Text1__c;
					if(text === undefined || text === "")
					{
						errorMSG += "請填寫文字\n";
					}
				}
				if(myType === "貼圖")
				{			
					if(contentList[j].PackageID__c === undefined || contentList[j].PackageID__c === "")
					{
						errorMSG += "請選擇貼圖\n";
					}
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].ImageURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}
				}
				if(myType === "圖文")
				{
					var text =  contentList[j].ImageContentURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳圖片\n";
					}

					var imgTxtType = contentList[j].PicTextType__c;
					if(imgTxtType === undefined || imgTxtType === "")
					{
						errorMSG += "請選擇圖文版型\n";
					}

					if(imgTxtType === "type1")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type2" || imgTxtType === "type3")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type4" || imgTxtType === "type6" || imgTxtType === "type7")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type5")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeD__c === undefined || contentList[j].PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeD__c === "網址")
							{
								if(contentList[j].PicTextTitleD__c === undefined || contentList[j].PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}
					}

					if(imgTxtType === "type8")
					{
						if(contentList[j].PicTextTypeA__c === undefined || contentList[j].PicTextTypeA__c === "")
						{
							errorMSG += "請選擇A區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeA__c === "網址")
							{
								if(contentList[j].PicTextTitleA__c === undefined || contentList[j].PicTextTitleA__c === "")
								{
									errorMSG += "請選擇A區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextA__c === undefined || contentList[j].PicTextMTextA__c === "")
								{
									errorMSG += "請選擇A區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeB__c === undefined || contentList[j].PicTextTypeB__c === "")
						{
							errorMSG += "請選擇B區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeB__c === "網址")
							{
								if(contentList[j].PicTextTitleB__c === undefined || contentList[j].PicTextTitleB__c === "")
								{
									errorMSG += "請選擇B區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextB__c === undefined || contentList[j].PicTextMTextB__c === "")
								{
									errorMSG += "請選擇B區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeC__c === undefined || contentList[j].PicTextTypeC__c === "")
						{
							errorMSG += "請選擇C區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeC__c === "網址")
							{
								if(contentList[j].PicTextTitleC__c === undefined || contentList[j].PicTextTitleC__c === "")
								{
									errorMSG += "請選擇C區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextC__c === undefined || contentList[j].PicTextMTextC__c === "")
								{
									errorMSG += "請選擇C區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeD__c === undefined || contentList[j].PicTextTypeD__c === "")
						{
							errorMSG += "請選擇D區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeD__c === "網址")
							{
								if(contentList[j].PicTextTitleD__c === undefined || contentList[j].PicTextTitleD__c === "")
								{
									errorMSG += "請選擇D區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextD__c === undefined || contentList[j].PicTextMTextD__c === "")
								{
									errorMSG += "請選擇D區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeE__c === undefined || contentList[j].PicTextTypeE__c === "")
						{
							errorMSG += "請選擇E區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeE__c === "網址")
							{
								if(contentList[j].PicTextTitleE__c === undefined || contentList[j].PicTextTitleE__c === "")
								{
									errorMSG += "請選擇E區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextE__c === undefined || contentList[j].PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextE__c === undefined || contentList[j].PicTextMTextE__c === "")
								{
									errorMSG += "請選擇E區圖文文字\n";
								}
							}
						}

						if(contentList[j].PicTextTypeF__c === undefined || contentList[j].PicTextTypeF__c === "")
						{
							errorMSG += "請選擇F區類型\n";
						}
						else
						{
							if(contentList[j].PicTextTypeF__c === "網址")
							{
								if(contentList[j].PicTextTitleF__c === undefined || contentList[j].PicTextTitleF__c === "")
								{
									errorMSG += "請選擇F區圖文標籤\n";
								}
								if(contentList[j].PicTextMTextF__c === undefined || contentList[j].PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文網址\n";
								}
							}
							else
							{
								if(contentList[j].PicTextMTextF__c === undefined || contentList[j].PicTextMTextF__c === "")
								{
									errorMSG += "請選擇F區圖文文字\n";
								}
							}
						}
					}
				}
				if(myType === "影片")
				{
					var text =  contentList[j].VideoImageURL__c;
					var text2 =  contentList[j].VideoURL__c;
					if(text === undefined)
					{
						errorMSG += "請上傳影片縮圖圖片\n";
					}
					if(text2 === undefined)
					{
						errorMSG += "請上傳影片\n";
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
		var contentList = component.get('v.TheContentList');
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
			if(contentList[j].isDeleted__c === false)
			{
				var myType = contentList[j].MessageType__c;
                var returnText = '<div class="message-box-outside"><div class="message-box-user"><img style="vertical-align:top;padding:3px;" src="'+$A.get('$Resource.LineLogo_p')+'" width="35"/><div class="message-text-user">';

				if(myType === "文字")
				{
					var text = contentList[j].Text1__c;
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
					var stickerUrl = $A.get('$Resource.LineSticker_p')+'/'+contentList[j].PackageID__c+
						'/'+contentList[j].StickerID__c+'.png';
					returnText += '<img src="'+stickerUrl+'" width="150"/>';
					returnText += '</div><div class="message-time-user un-select">'+timeString+'</div></div></div>';
				}
				if(myType === "圖片")
				{				
					var text = contentList[j].ImageURL__c;
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
					var text =  contentList[j].ImageContentURL__c;
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
					var text =  contentList[j].VideoImageURL__c;
					var text2 =  contentList[j].VideoURL__c;
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
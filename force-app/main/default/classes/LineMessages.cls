/*==============================================================
 * Line Messages 使用，太多地方用到了，就獨立出來。QQ
 *
 *
 *==============================================================*/
public class LineMessages 
{
    public string type {get; set;}
    public string text {get; set;}
    public string originalContentUrl {get; set;}
    public string previewImageUrl {get; set;}
    public string packageId {get; set;}
    public string stickerId {get; set;}
    public string baseUrl {get; set;}
    public list<imageAction> actions {get; set;}
    public templateData template {get; set;}
    public string altText {get; set;}
    public senderData sender {get; set;}
    public singleContentData contents {get; set;}
    public quickReplyData quickReply {get; set;}
    public videoData video {get; set;}
    public areaData baseSize {get; set;}
    
    public LineMessages()
    {
        type = '';
        text = '';
        originalContentUrl = '';
        previewImageUrl = '';
        packageId = '';
        stickerId = '';
        baseUrl = '';
        actions = new list<imageAction>();
        template = new templateData();
    }

    public JSONGenerator toJSON(JSONGenerator g)
    {
        //JSONGenerator g = JSON.createGenerator(true);
        g.writeStartObject();
        g.writeStringField('type', type);
        if(type == 'text')
        {
            g.writeStringField('text', changeToUTF32(text));
            if(sender!=null)
            {
                g.writeFieldName('sender');
                g.writeStartObject();
                g.writeStringField('name', sender.name);
                g.writeStringField('iconUrl', sender.iconUrl);
                g.writeEndObject();
            }
            if(quickReply!=null)
            {
                g.writeFieldName('quickReply');
                g.writeStartObject();
                g.writeFieldName('items');
                g.writeStartArray();
                for(itemsData loopItems: quickReply.items)
                {
                    g.writeStartObject();
                    g.writeStringField('type', loopItems.type);
                    if(loopItems.imageUrl != null)
                    {
                        g.writeStringField('imageUrl', loopItems.imageUrl);
                    }
                    g.writeFieldName('action');
                    g.writeStartObject();
                    g.writeStringField('type', loopItems.action.type);
                    g.writeStringField('label', loopItems.action.label);
                    //g.writeStringField('text', loopItems.action.text);
                    g.writeEndObject();
                    g.writeEndObject();
                }
                g.writeEndArray();
                g.writeEndObject();
            }
        }
        if(type == 'image' || type == 'video')
        {
            g.writeStringField('originalContentUrl', originalContentUrl);
            g.writeStringField('previewImageUrl', previewImageUrl);
        }
        if(type == 'sticker')
        {
            g.writeStringField('packageId', packageId);
            g.writeStringField('stickerId', stickerId);
        }
        if(type == 'imagemap')
        {
            g.writeStringField('baseUrl', baseUrl+'&_ignored=');
            g.writeStringField('altText', altText);
            g.writeFieldName('baseSize');
            g.writeStartObject();
            if(baseSize == null)
            {
                g.writeNumberField('height', 1040);
                g.writeNumberField('width', 1040);
            }
            else {
                g.writeNumberField('height', baseSize.height);
                g.writeNumberField('width', baseSize.width);
            }
            
            g.writeEndObject();
            if(video != null)
            {
                g.writeFieldName('video');
                g.writeStartObject();
                g.writeStringField('originalContentUrl', video.originalContentUrl);
                g.writeStringField('previewImageUrl', video.previewImageUrl);
                g.writeFieldName('area');
                g.writeStartObject();
                g.writeNumberField('x', video.area.x);
                g.writeNumberField('y', video.area.y);
                g.writeNumberField('width', video.area.width);
                g.writeNumberField('height', video.area.height);
                g.writeEndObject();
                if(video.externalLink!=null)
                {
                    g.writeFieldName('externalLink');
                    g.writeStartObject();
                    g.writeStringField('linkUri', video.externalLink.linkUri);
                    g.writeStringField('label', video.externalLink.label);
                    g.writeEndObject();
                }
                g.writeEndObject();
            }
            g.writeFieldName('actions');
            g.writeStartArray();
            for(imageAction loopAction: actions)
            {
                g.writeStartObject();
                g.writeStringField('type', loopAction.type);
                if(loopAction.type == 'uri')
                {
                    g.writeStringField('linkUri', loopAction.linkUri);
                    g.writeStringField('label', loopAction.label);
                }
                if(loopAction.type == 'message')
                {
                    g.writeStringField('text', loopAction.text);
                }
                g.writeFieldName('area');
                g.writeStartObject();
                g.writeNumberField('x', loopAction.area.x);
                g.writeNumberField('y', loopAction.area.y);
                g.writeNumberField('width', loopAction.area.width);
                g.writeNumberField('height', loopAction.area.height);
                g.writeEndObject();
                g.writeEndObject();
            }
            g.writeEndArray();
        }
        if(type == 'template')
        {
            g.writeStringField('altText', altText);
            g.writeFieldName('template');
            g.writeStartObject();
            if(template.type == 'buttons')
            {
                g.writeStringField('type', template.type);
                g.writeStringField('thumbnailImageUrl', template.thumbnailImageUrl);
                g.writeStringField('imageAspectRatio', template.imageAspectRatio);
                g.writeStringField('imageSize', template.imageSize);
                g.writeStringField('imageBackgroundColor', template.imageBackgroundColor);
                g.writeStringField('title', template.title);
                g.writeStringField('text', template.text);
                if(template.defaultAction != null)
                {
                    g.writeFieldName('defaultAction');
                    g.writeStartObject();
                    if(template.defaultAction.type == 'uri')
                    {
                        g.writeStringField('label', template.defaultAction.label);
                        g.writeStringField('uri', template.defaultAction.uri);
                    }
                    if(template.defaultAction.type == 'postback')
                    {
                        g.writeStringField('label', template.defaultAction.label);
                        g.writeStringField('data', template.defaultAction.data);
                    }
                    if(template.defaultAction.type == 'message')
                    {
                        g.writeStringField('label', template.defaultAction.label);
                        g.writeStringField('text', template.defaultAction.text);
                    }
                    g.writeEndObject();
                }

                g.writeFieldName('actions');
                g.writeStartArray();
                for(actionData loopAction: template.actions)
                {
                    g.writeStartObject();
                    g.writeStringField('type', loopAction.type);
                    if(loopAction.type == 'uri')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('uri', loopAction.uri);
                    }
                    if(loopAction.type == 'postback')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('data', loopAction.data);
                    }
                    if(loopAction.type == 'message')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('text', loopAction.text);
                    }
                    if(loopAction.type == 'cameraRoll')
                    {
                        g.writeStringField('label', loopAction.label);
                    }
                    if(loopAction.type == 'camera')
                    {
                        g.writeStringField('label', loopAction.label);
                    }
                    g.writeEndObject();
                }
                g.writeEndArray();
            }
            if(template.type == 'confirm')
            {
                g.writeStringField('type', template.type);
                g.writeStringField('text', template.text);
                g.writeFieldName('actions');
                g.writeStartArray();
                for(actionData loopAction: template.actions)
                {
                    g.writeStartObject();
                    g.writeStringField('type', loopAction.type);
                    if(loopAction.type == 'uri')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('uri', loopAction.uri);
                    }
                    if(loopAction.type == 'postback')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('data', loopAction.data);
                    }
                    if(loopAction.type == 'message')
                    {
                        g.writeStringField('label', loopAction.label);
                        g.writeStringField('text', loopAction.text);
                    }
                    if(loopAction.type == 'cameraRoll')
                    {
                        g.writeStringField('label', loopAction.label);
                    }
                    if(loopAction.type == 'camera')
                    {
                        g.writeStringField('label', loopAction.label);
                    }
                    g.writeEndObject();
                }
                g.writeEndArray();
            }
            if(template.type == 'carousel')
            {
                g.writeStringField('type', template.type);
                g.writeFieldName('columns');
                g.writeStartArray();
                for(columnData loopColumn: template.columns)
                {
                    g.writeStartObject();
                    g.writeStringField('thumbnailImageUrl', loopColumn.thumbnailImageUrl);
                    g.writeStringField('imageBackgroundColor', loopColumn.imageBackgroundColor);
                    g.writeStringField('title', loopColumn.title);
                    g.writeStringField('text', loopColumn.text);
                    if(loopColumn.defaultAction != null)
                    {
                        g.writeFieldName('defaultAction');
                        g.writeStartObject();
                        if(loopColumn.defaultAction.type == 'uri')
                        {
                            g.writeStringField('label', loopColumn.defaultAction.label);
                            g.writeStringField('uri', loopColumn.defaultAction.uri);
                        }
                        if(loopColumn.defaultAction.type == 'postback')
                        {
                            g.writeStringField('label', loopColumn.defaultAction.label);
                            g.writeStringField('data', loopColumn.defaultAction.data);
                        }
                        if(loopColumn.defaultAction.type == 'message')
                        {
                            g.writeStringField('label', loopColumn.defaultAction.label);
                            g.writeStringField('text', loopColumn.defaultAction.text);
                        }
                        g.writeEndObject();
                    }
                    g.writeFieldName('actions');
                    g.writeStartArray();
                    for(actionData loopAction: loopColumn.actions)
                    {
                        g.writeStartObject();
                        g.writeStringField('type', loopAction.type);
                        if(loopAction.type == 'uri')
                        {
                            g.writeStringField('label', loopAction.label);
                            g.writeStringField('uri', loopAction.uri);
                        }
                        if(loopAction.type == 'postback')
                        {
                            g.writeStringField('label', loopAction.label);
                            g.writeStringField('data', loopAction.data);
                        }
                        if(loopAction.type == 'message')
                        {
                            g.writeStringField('label', loopAction.label);
                            g.writeStringField('text', loopAction.text);
                        }
                        g.writeEndObject();
                    }
                    g.writeEndArray();
                    g.writeEndObject();
                }
                g.writeEndArray();
                //g.writeStringField('imageAspectRatio', template.imageAspectRatio);
                //g.writeStringField('imageSize', template.imageSize);
            }
            if(template.type == 'image_carousel')
            {
                g.writeStringField('type', template.type);
                g.writeFieldName('columns');
                g.writeStartArray();
                for(columnData loopColumn: template.columns)
                {
                    g.writeStartObject();
                    g.writeStringField('imageUrl', loopColumn.imageUrl);
                    g.writeFieldName('action');
                    g.writeStartObject();
                    g.writeStringField('type', loopColumn.action.type);
                    if(loopColumn.action.type == 'uri')
                    {
                        g.writeStringField('label', loopColumn.action.label);
                        g.writeStringField('uri', loopColumn.action.uri);
                    }
                    if(loopColumn.action.type == 'postback')
                    {
                        g.writeStringField('label', loopColumn.action.label);
                        g.writeStringField('data', loopColumn.action.data);
                    }
                    if(loopColumn.action.type == 'message')
                    {
                        g.writeStringField('label', loopColumn.action.label);
                        g.writeStringField('text', loopColumn.action.text);
                    }
                    g.writeEndObject();
                    g.writeEndObject();
                }
                g.writeEndArray();
            }
            g.writeEndObject();
        }
        if(type == 'flex')
        {                   
            g.writeStringField('altText', altText);
            g.writeFieldName('contents');
            g.writeStartObject();
            g.writeStringField('type', contents.type);
            if(contents.type == 'bubble') //Hotel Social
            {
                if(contents.size !=null)
                {
                    g.writeStringField('size', contents.size);
                }
                if(contents.header !=null)
                {
                    g.writeFieldName('header');
                    g.writeStartObject();
                    g.writeStringField('type', contents.header.type);
                    g.writeStringField('layout', contents.header.layout);
                    g.writeFieldName('contents');
                    g.writeStartArray();
                    for(contentsData headerContent: contents.header.contents)
                    {
                        g.writeStartObject();
                        g.writeStringField('type', headerContent.type);
                        g.writeStringField('layout', headerContent.layout);
                        g.writeFieldName('contents');
                        g.writeStartArray();
                        for(contentsData headboxContent: headerContent.contents)
                        {
                            g.writeStartObject();
                            g.writeStringField('type', headboxContent.type);
                            if(headboxContent.type=='text')
                            {
                                g.writeStringField('text', headboxContent.text);
                                g.writeStringField('color', headboxContent.color);
                                g.writeStringField('size', headboxContent.size);
                                if(headboxContent.flex!=null)
                                {
                                    g.writeNumberField('flex', headboxContent.flex);
                                    g.writeStringField('weight', headboxContent.weight);
                                }
                            }                         
                            g.writeEndObject();
                        }
                        g.writeEndArray();
                        g.writeEndObject();
                    }
                    g.writeEndArray();
                    g.writeStringField('paddingAll', contents.header.paddingAll);
                    g.writeStringField('backgroundColor', contents.header.backgroundColor);
                    g.writeStringField('spacing', contents.header.spacing);
                    g.writeStringField('height', contents.header.height);
                    g.writeStringField('paddingTop', contents.header.paddingTop);
                    g.writeEndObject();
                }
                if(contents.hero != null)
                {
                    g.writeFieldName('hero');
                    g.writeStartObject();           
                    g.writeStringField('type', contents.hero.type);         
                    g.writeStringField('url', contents.hero.url);
                    g.writeStringField('size', contents.hero.size);
                    g.writeStringField('aspectMode', contents.hero.aspectMode);
                    g.writeStringField('aspectRatio', contents.hero.aspectRatio);
                    /* no need to click。
                    g.writeFieldName('action');
                    g.writeStartObject();
                    g.writeStringField('type', contents.hero.action.type); 
                    g.writeStringField('uri', contents.hero.action.uri); 
                    g.writeEndObject();
                    */
                    g.writeEndObject();
                }
                if(contents.body != null)
                {
                    g.writeFieldName('body');
                    g.writeStartObject();
                    g.writeStringField('type', contents.body.type);      //box
                    g.writeStringField('layout', contents.body.layout);
                    if(contents.body.spacing!=null)
                    {
                        g.writeStringField('spacing', contents.body.spacing);
                    }
                    if(contents.body.action!=null)
                    {
                        g.writeFieldName('action');
                        g.writeStartObject();
                        g.writeStringField('type', contents.body.action.type); 
                        g.writeStringField('uri', contents.body.action.uri); 
                        g.writeEndObject();
                    }
                    g.writeFieldName('contents');
                    g.writeStartArray();
                    for(contentsData loopContent: contents.body.contents)
                    {
                        g.writeStartObject();
                        g.writeStringField('type', loopContent.type);
                        if(loopContent.type == 'text')
                        {
                            g.writeStringField('text', loopContent.text);
                            if(loopContent.color!=null)
                            {
                                g.writeStringField('color', loopContent.color);
                            }
                            if(loopContent.size!=null)
                            {
                                g.writeStringField('size', loopContent.size);
                            }
                            if(loopContent.weight!=null)
                            {
                                g.writeStringField('weight', loopContent.weight);
                            }
                            if(loopContent.margin!=null)
                            {
                                g.writeStringField('margin', loopContent.margin);
                            }
                            if(loopContent.wrap!=null)
                            {
                                g.writeBooleanField('wrap', loopContent.wrap);
                            }
                            if(loopContent.gravity!=null)
                            {
                                g.writeStringField('gravity', loopContent.gravity);
                            }
                        }
                        if(loopContent.type == 'separator')
                        {
                            g.writeStringField('margin', loopContent.margin);
                        }
                        if(loopContent.url != null)
                        {
                            g.writeStringField('url', loopContent.url);
                        }
                        if(loopContent.type == 'image')
                        {
                            g.writeStringField('size', loopContent.size);
                            g.writeStringField('aspectMode', loopContent.aspectMode);
                            g.writeStringField('aspectRatio', loopContent.aspectRatio);
                            if(loopContent.position!=null)
                            {
                                g.writeStringField('position', loopContent.position);
                            }                           
                            if(loopContent.offsetTop!=null)
                            {
                                g.writeStringField('offsetTop', loopContent.offsetTop);
                                g.writeStringField('offsetBottom', loopContent.offsetBottom);
                                g.writeStringField('offsetStart', loopContent.offsetStart);
                                g.writeStringField('offsetEnd', loopContent.offsetEnd);
                            }                    
                            if(loopContent.gravity!=null)
                            {
                                g.writeStringField('gravity', loopContent.gravity);
                            }           
                        }
                        if(loopContent.type == 'box') //box-box
                        {                          
                            g.writeStringField('layout', loopContent.layout);     //horizontal vertical baseline
                            g.writeFieldName('contents');
                            g.writeStartArray();
                            for(contentsData moreloopContent: loopContent.contents)
                            {
                                g.writeStartObject();
                                g.writeStringField('type', moreloopContent.type);                             
                                if(moreloopContent.type=='image')
                                {                                  
                                    g.writeStringField('url', moreloopContent.url); 
                                    g.writeStringField('size', moreloopContent.size);
                                    g.writeStringField('aspectMode', moreloopContent.aspectMode);
                                    if(moreloopContent.aspectRatio!=null)
                                    {
                                        g.writeStringField('aspectRatio', moreloopContent.aspectRatio);
                                        g.writeStringField('gravity', moreloopContent.gravity);
                                        g.writeNumberField('flex',moreloopContent.flex);
                                    }
                                }
                                if(moreloopContent.type=='icon')
                                {
                                    g.writeStringField('url', moreloopContent.url);
                                    g.writeStringField('size', moreloopContent.size);
                                }
                                if(moreloopContent.type=='separator')
                                {
                                    g.writeStringField('margin', moreloopContent.margin);
                                }
                                if(moreloopContent.type=='text')
                                {
                                    g.writeStringField('text', moreloopContent.text);
                                    g.writeStringField('size', moreloopContent.size);
                                    if(moreloopContent.gravity!=null)
                                    {
                                        g.writeStringField('gravity', moreloopContent.gravity);
                                    }
                                    if(moreloopContent.wrap!=null)
                                    {
                                        g.writeBooleanField('wrap', moreloopContent.wrap);
                                    }
                                    if(moreloopContent.flex!=null)
                                    {
                                        g.writeNumberField('flex', moreloopContent.flex);
                                    }
                                    if(moreloopContent.color!=null)
                                    {
                                        g.writeStringField('color', moreloopContent.color);
                                    }
                                    if(moreloopContent.align!=null)
                                    {
                                        g.writeStringField('align', moreloopContent.align);
                                    }
                                    if(moreloopContent.offsetTop!=null)
                                    {                              
                                        g.writeStringField('offsetTop', moreloopContent.offsetTop);
                                    }
                                    if(moreloopContent.margin!=null)
                                    {
                                        g.writeStringField('margin', moreloopContent.margin);
                                    }
                                }
                                if(moreloopContent.type=='box') //box-box-box
                                {
                                    g.writeStringField('layout', moreloopContent.layout);
                                    if(moreloopContent.layout=='horizontal')
                                    {
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData loopAction: moreloopContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', loopAction.type);
                                            g.writeStringField('text', loopAction.text);
                                            g.writeStringField('size', loopAction.size);
                                            if(loopAction.gravity!=null)
                                            {
                                                g.writeStringField('gravity', loopAction.gravity);
                                            }
                                            if(loopAction.color!=null)
                                            {
                                                g.writeStringField('color', loopAction.color);
                                            }
                                            if(loopAction.flex!=null)
                                            {
                                                g.writeNumberField('flex', loopAction.flex);
                                            }
                                            if(loopAction.align!=null)
                                            {
                                                g.writeStringField('align', loopAction.align);
                                            }
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                        if(moreloopContent.flex!=null)
                                        {
                                            g.writeNumberField('flex', moreloopContent.flex);
                                        }
                                    }
                                    if(moreloopContent.layout=='baseline')
                                    {
                                        if(moreloopContent.spacing!=null)
                                        {
                                            g.writeStringField('spacing', moreloopContent.spacing);
                                        }
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData loopAction: moreloopContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', loopAction.type);
                                            if(loopAction.url!=null)
                                            {
                                                g.writeStringField('url', loopAction.url);
                                            }
                                            if(loopAction.type=='text')
                                            {
                                                g.writeStringField('text', loopAction.text);                                              
                                            }
                                            if(loopAction.weight!=null)
                                            {
                                                g.writeStringField('weight', loopAction.weight);
                                            }
                                            if(loopAction.margin!=null)
                                            {
                                                g.writeStringField('margin', loopAction.margin);
                                            }
                                            if(loopAction.flex!=null)
                                            {
                                                g.writeNumberField('flex', loopAction.flex);
                                            }
                                            if(loopAction.size!=null)
                                            {
                                                g.writeStringField('size', loopAction.size);
                                            }
                                            if(loopAction.align!=null)
                                            {
                                                g.writeStringField('align', loopAction.align);
                                            }
                                            if(loopAction.color!=null)
                                            {
                                                g.writeStringField('color', loopAction.color);
                                            }
                                            if(loopAction.wrap!=null)
                                            {
                                                g.writeBooleanField('wrap', loopAction.wrap);
                                            }
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                        if(moreloopContent.flex!=null)
                                        {
                                            g.writeNumberField('flex', moreloopContent.flex);
                                        }                                       
                                    }
                                    if(moreloopContent.layout=='vertical')
                                    {
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData loopAction: moreloopContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', loopAction.type);
                                            if(loopAction.type=='image')
                                            {
                                                g.writeStringField('url', loopAction.url);
                                                g.writeStringField('size', loopAction.size);
                                                g.writeStringField('aspectMode', loopAction.aspectMode);
                                                if(loopAction.aspectRatio!=null)
                                                {
                                                    g.writeStringField('aspectRatio', loopAction.aspectRatio);
                                                    g.writeStringField('gravity', loopAction.gravity);
                                                }                                              
                                            }
                                            if(loopAction.type=='text')
                                            {
                                                g.writeFieldName('contents');
                                                g.writeStartArray();
                                                for(contentsData looptext: loopAction.contents)
                                                {
                                                    g.writeStartObject();
                                                    g.writeStringField('type', looptext.type);
                                                    if(looptext.type=='span')
                                                    {
                                                        g.writeStringField('text', looptext.text);                                                                                                        
                                                        if(looptext.weight!=null)
                                                        {
                                                            g.writeStringField('weight', looptext.weight);
                                                            g.writeStringField('color', looptext.color);
                                                        }
                                                    }
                                                    g.writeEndObject();
                                                }
                                                g.writeEndArray();
                                                g.writeStringField('size', loopAction.size);
                                                g.writeBooleanField('wrap', loopAction.wrap);
                                            }
                                            if(loopAction.type=='box')
                                            {
                                                g.writeStringField('layout', loopAction.layout);
                                                if(loopAction.layout == 'horizontal')
                                                {
                                                    g.writeFieldName('contents');
                                                    g.writeStartArray();
                                                    for(contentsData loopbox: loopAction.contents)
                                                    {
                                                        g.writeStartObject();
                                                        g.writeStringField('type', loopbox.type);
                                                        if(loopbox.type=='text')
                                                        {
                                                            g.writeStringField('text', loopbox.text);
                                                            g.writeStringField('color', loopbox.color);
                                                            g.writeStringField('size', loopbox.size);
                                                        }
                                                        if(loopbox.type=='box')
                                                        {
                                                            g.writeStringField('layout', loopbox.layout);
                                                            g.writeFieldName('contents');
                                                            g.writeStartArray();
                                                            for(contentsData loopboxtwo: loopbox.contents)
                                                            {
                                                                g.writeStartObject();
                                                                g.writeStringField('type', loopboxtwo.type);
                                                                if(loopboxtwo.type=='text')
                                                                {
                                                                    g.writeStringField('text', loopboxtwo.text);
                                                                    g.writeStringField('color', loopboxtwo.color);
                                                                    if(loopboxtwo.decoration!=null)
                                                                    {
                                                                        g.writeStringField('decoration', loopboxtwo.decoration);
                                                                    }
                                                                    g.writeStringField('size', loopboxtwo.size);
                                                                    if(loopboxtwo.flex!=null)
                                                                    {
                                                                        g.writeNumberField('flex', loopboxtwo.flex);
                                                                    }
                                                                    g.writeStringField('align', loopboxtwo.align);                                                    
                                                                }
                                                                g.writeEndObject();
                                                            }                                                           
                                                            g.writeEndArray();
                                                            if(loopbox.width!=null)
                                                            {
                                                                g.writeStringField('width', loopbox.width);
                                                                g.writeStringField('backgroundColor', loopbox.backgroundColor);
                                                            }
                                                            if(loopbox.flex!=null)
                                                            {
                                                                g.writeNumberField('flex', loopbox.flex);
                                                                g.writeStringField('spacing', loopbox.spacing);
                                                            }
                                                        }
                                                        g.writeEndObject();
                                                    }
                                                    g.writeEndArray();
                                                    if(loopAction.flex!=null)
                                                    {
                                                        g.writeNumberField('flex', loopAction.flex);
                                                    }
                                                }
                                                if(loopAction.layout=='baseline')
                                                {
                                                    g.writeFieldName('contents');
                                                    g.writeStartArray();
                                                    for(contentsData loopbox: loopAction.contents)
                                                    {
                                                        g.writeStartObject();
                                                        g.writeStringField('type', loopbox.type);
                                                        if(loopbox.type == 'icon')
                                                        {
                                                            g.writeStringField('url', loopbox.url);
                                                        }
                                                        if(loopbox.type == 'text')
                                                        {
                                                            g.writeStringField('text', loopbox.text);
                                                            g.writeStringField('color', loopbox.color);
                                                            if(loopbox.size!=null)
                                                            {
                                                                g.writeStringField('size',loopbox.size);
                                                            }
                                                        }
                                                        g.writeEndObject();
                                                    }
                                                    g.writeEndArray();
                                                    g.writeStringField('spacing', loopAction.spacing);
                                                    if(loopAction.margin!=null)
                                                    {
                                                        g.writeStringField('margin', loopAction.margin);
                                                    }
                                                }
                                                if(loopAction.layout=='vertical')
                                                {
                                                    g.writeFieldName('contents');
                                                    g.writeStartArray();
                                                    for(contentsData loopbox: loopAction.contents)
                                                    {
                                                        g.writeStartObject();
                                                        g.writeStringField('type', loopbox.type);
                                                        g.writeEndObject();
                                                    }
                                                    g.writeEndArray();
                                                    g.writeStringField('cornerRadius', loopAction.cornerRadius);
                                                    g.writeStringField('height', loopAction.height);
                                                    if(loopAction.width!=null)
                                                    {
                                                        g.writeStringField('width', loopAction.width);
                                                    }
                                                    g.writeStringField('borderColor', loopAction.borderColor);
                                                    g.writeStringField('borderWidth', loopAction.borderWidth);
                                                }
                                                
                                            }
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                        if(moreloopContent.cornerRadius!=null)
                                        {
                                            g.writeStringField('cornerRadius', moreloopContent.cornerRadius);
                                            g.writeStringField('width', moreloopContent.width);
                                            g.writeStringField('height', moreloopContent.height);
                                        }  
                                        if(moreloopContent.flex!=null)
                                        {
                                            g.writeNumberField('flex', moreloopContent.flex);
                                        }
                                        if(moreloopContent.spacing!=null)
                                        {
                                            g.writeStringField('spacing', moreloopContent.spacing);
                                        }                 
                                        if(moreloopContent.width!=null)
                                        {
                                            g.writeStringField('width', moreloopContent.width);
                                        }                     
                                    }
                                }
                                g.writeEndObject();
                            }
                            g.writeEndArray();
                            if(loopContent.position!=null)
                            {
                                g.writeStringField('position', loopContent.position);
                            }
                            if(loopContent.cornerRadius!=null)
                            {
                                g.writeStringField('cornerRadius', loopContent.cornerRadius);
                            }
                            if(loopContent.height!=null)
                            {
                                g.writeStringField('height', loopContent.height);
                            }
                            if(loopContent.offsetTop!=null)
                            {
                                g.writeStringField('offsetTop', loopContent.offsetTop);
                                g.writeStringField('backgroundColor', loopContent.backgroundColor);
                                g.writeStringField('offsetStart', loopContent.offsetStart);                              
                                g.writeStringField('width', loopContent.width);
                            }
                            if(loopContent.offsetBottom!=null)     
                            {
                                g.writeStringField('offsetBottom', loopContent.offsetBottom);
                                g.writeStringField('offsetStart', loopContent.offsetStart);
                                g.writeStringField('offsetEnd', loopContent.offsetEnd);
                            }
                            if(loopContent.paddingAll!=null)
                            {
                                g.writeStringField('paddingAll', loopContent.paddingAll);
                            }
                            if(loopContent.spacing!=null)
                            {
                                g.writeStringField('spacing', loopContent.spacing);
                            }
                            if(loopContent.margin!=null)
                            {
                                g.writeStringField('margin', loopContent.margin);
                            }
                        }
                        g.writeEndObject();
                    }
                    g.writeEndArray();
                    if(contents.body.paddingAll!=null)
                    {
                        g.writeStringField('paddingAll', contents.body.paddingAll);
                    }      
                    g.writeEndObject();
                }       
                if(contents.footer != null)
                {
                    g.writeFieldName('footer');
                    g.writeStartObject();
                    g.writeStringField('type', contents.footer.type);
                    g.writeStringField('layout', contents.footer.layout);
                    g.writeFieldName('contents');
                    g.writeStartArray();
                    for(contentsData Contentbox: contents.footer.contents)
                    {
                        g.writeStartObject();
                        g.writeStringField('type', Contentbox.type);
                        if(Contentbox.size!=null)
                        {
                            g.writeStringField('size', Contentbox.size);
                        }
                        if(Contentbox.style!=null)
                        {
                            g.writeStringField('style', Contentbox.style);
                        }
                        if(Contentbox.color!=null)
                        {
                            g.writeStringField('color', Contentbox.color);
                        }
                        if(Contentbox.action!=null)
                        {
                            g.writeFieldName('action');
                            g.writeStartObject();
                            g.writeStringField('type', Contentbox.action.type);
                            g.writeStringField('label', Contentbox.action.label);
                            g.writeStringField('uri', Contentbox.action.uri);
                            g.writeEndObject();
                        }
                        g.writeEndObject();
                    }
                    g.writeEndArray();
                    g.writeEndObject();
                }                                
            }
             
            if(contents.type == 'carousel') //Restaurant Apparel
            {
                g.writeFieldName('contents');
                g.writeStartArray();
                for(contentsData loopcrlContent: contents.contents)
                {
                    g.writeStartObject();
                    g.writeStringField('type', loopcrlContent.type);  //bubble
                    if(loopcrlContent.type == 'bubble')
                    {
                        if(loopcrlContent.size != null)
                        {
                            g.writeStringField('size', loopcrlContent.size);
                        }
                        if(loopcrlContent.header != null)    
                        {
                            g.writeFieldName('header');       
                            g.writeStartObject();
                            g.writeStringField('type', loopcrlContent.header.type);
                            g.writeStringField('layout', loopcrlContent.header.layout);
                            g.writeFieldName('contents');
                            g.writeStartArray();
                            for(contentsData crlContent: loopcrlContent.header.contents)
                            {
                                g.writeStartObject();
                                g.writeStringField('type', crlContent.type);
                                if(crlContent.type=='text')
                                {
                                    g.writeStringField('text', crlContent.text);
                                    g.writeStringField('color', crlContent.color);
                                    g.writeStringField('align', crlContent.align);
                                    g.writeStringField('size', crlContent.size);
                                    g.writeStringField('gravity', crlContent.gravity);
                                    if(crlContent.margin!=null)
                                    {
                                        g.writeStringField('margin', crlContent.margin);
                                    }
                                }
                                if(crlContent.type=='box')
                                {
                                    g.writeStringField('layout', crlContent.layout);
                                    g.writeFieldName('contents');
                                    g.writeStartArray();
                                    for(contentsData moreContent: crlContent.contents)
                                    {
                                        g.writeStartObject();
                                        g.writeStringField('type', moreContent.type);
                                        g.writeStringField('layout', moreContent.layout);
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData moreContenttwo: moreContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', moreContenttwo.type);                                                                                      
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                        g.writeStringField('width', moreContent.width);
                                        g.writeStringField('backgroundColor', moreContent.backgroundColor);
                                        g.writeStringField('height', moreContent.height);
                                        g.writeEndObject();
                                    }
                                    g.writeEndArray();
                                    g.writeStringField('backgroundColor', crlContent.backgroundColor);
                                    g.writeStringField('height', crlContent.height);
                                    g.writeStringField('margin', crlContent.margin);
                                }
                                g.writeEndObject();
                            }
                            g.writeEndArray();
                            g.writeStringField('backgroundColor', loopcrlContent.header.backgroundColor);
                            g.writeStringField('paddingTop', loopcrlContent.header.paddingTop);
                            g.writeStringField('paddingAll', loopcrlContent.header.paddingAll);
                            g.writeStringField('paddingBottom', loopcrlContent.header.paddingBottom);
                            g.writeEndObject();
                        }       
                        if(loopcrlContent.hero != null)
                        {
                            g.writeFieldName('hero');       
                            g.writeStartObject();          
                            g.writeStringField('type', loopcrlContent.hero.type);
                            g.writeStringField('url', loopcrlContent.hero.url);
                            g.writeStringField('size', loopcrlContent.hero.size);
                            g.writeStringField('aspectRatio', loopcrlContent.hero.aspectRatio);
                            g.writeStringField('aspectMode', loopcrlContent.hero.aspectMode);
                            if(loopcrlContent.hero.position!=null)
                            {
                                g.writeStringField('position', loopcrlContent.hero.position);
                            }
                            if(loopcrlContent.hero.action!=null)           
                            {       
                                g.writeFieldName('action');
                                g.writeStartObject();
                                g.writeStringField('type', loopcrlContent.hero.action.type);
                                g.writeStringField('uri', loopcrlContent.hero.action.uri);   
                                g.writeEndObject();
                            }            
                            g.writeEndObject();
                        }           
                                
                        if(loopcrlContent.body != null)
                        {
                            g.writeFieldName('body');
                            g.writeStartObject();
                            g.writeStringField('type', loopcrlContent.body.type);
                            g.writeStringField('layout', loopcrlContent.body.layout);
                            if(loopcrlContent.body.spacing!=null)
                            {
                                g.writeStringField('spacing', loopcrlContent.body.spacing);
                            }
                            g.writeFieldName('contents');
                            g.writeStartArray();
                            for(contentsData loopContent: loopcrlContent.body.contents)
                            {
                                g.writeStartObject();
                                g.writeStringField('type', loopContent.type);
                                if(loopContent.type == 'text')
                                {
                                    g.writeStringField('text', loopContent.text);
                                    if(loopContent.wrap!=null)
                                    {
                                        g.writeBooleanField('wrap', loopContent.wrap);
                                    }
                                    if(loopContent.weight!=null)
                                    {
                                        g.writeStringField('weight', loopContent.weight);
                                    }
                                    if(loopContent.size!=null)
                                    {
                                        g.writeStringField('size', loopContent.size);
                                    }
                                    if(loopContent.margin!=null)
                                    {
                                        g.writeStringField('margin', loopContent.margin);
                                        g.writeStringField('color', loopContent.color);
                                        g.writeNumberField('flex', loopContent.flex);
                                    }
                                }
                                if(loopContent.type == 'image')
                                {
                                    g.writeStringField('url', loopContent.url);
                                    g.writeStringField('size', loopContent.size);
                                    g.writeStringField('aspectMode', loopContent.aspectMode);
                                    g.writeStringField('aspectRatio', loopContent.aspectRatio);
                                    g.writeStringField('gravity', loopContent.gravity);
                                }
                                if(loopContent.type == 'box')
                                {                          
                                    g.writeStringField('layout', loopContent.layout);
                                    if(loopContent.layout=='baseline')
                                    {
                                        if(loopContent.margin!=null)
                                        {
                                            g.writeStringField('margin', loopContent.margin);
                                        }
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData loopAction: loopContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', loopAction.type);
                                            if(loopAction.type == 'icon')
                                            {
                                                g.writeStringField('size', loopAction.size);
                                                g.writeStringField('url', loopAction.url);
                                            }
                                            if(loopAction.type == 'text')
                                            {
                                                g.writeStringField('text', loopAction.text);
                                                g.writeStringField('size', loopAction.size);
                                                g.writeNumberField('flex', loopAction.flex);
                                                if(loopAction.wrap!=null)
                                                {
                                                    g.writeBooleanField('wrap', loopAction.wrap);
                                                    g.writeStringField('weight', loopAction.weight);  
                                                }                                                                                                        
                                                if(loopAction.color!=null)
                                                {
                                                    g.writeStringField('color', loopAction.color);
                                                    g.writeStringField('margin', loopAction.margin);
                                                }
                                            }
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                    }
                                    if(loopContent.layout=='vertical')
                                    {
                                        if(loopContent.margin!=null)
                                        {
                                            g.writeStringField('margin', loopContent.margin);
                                        }
                                        g.writeFieldName('contents');
                                        g.writeStartArray();
                                        for(contentsData loopAction: loopContent.contents)
                                        {
                                            g.writeStartObject();
                                            g.writeStringField('type', loopAction.type);
                                            if(loopAction.type == 'box')
                                            {
                                                g.writeStringField('layout', loopAction.layout);
                                                if(loopAction.spacing!=null)
                                                {
                                                    g.writeStringField('spacing', loopAction.spacing);
                                                }
                                                g.writeFieldName('contents');
                                                g.writeStartArray();
                                                for(contentsData loopbox: loopAction.contents)
                                                {
                                                    g.writeStartObject();
                                                    g.writeStringField('type', loopbox.type);
                                                    if(loopbox.type=='text')
                                                    {
                                                        g.writeStringField('text', loopbox.text);
                                                        if(loopbox.wrap!=null)
                                                        {
                                                            g.writeBooleanField('wrap', loopbox.wrap);
                                                        }
                                                        g.writeStringField('color', loopbox.color);
                                                        g.writeStringField('size', loopbox.size);
                                                        if(loopbox.flex!=null)
                                                        {
                                                            g.writeNumberField('flex', loopbox.flex);                                                           
                                                        }
                                                        if(loopbox.decoration!=null)
                                                        {                                                           
                                                            g.writeStringField('decoration', loopbox.decoration);
                                                            g.writeStringField('gravity', loopbox.gravity);
                                                        }
                                                        if(loopbox.weight!=null)
                                                        {
                                                            g.writeStringField('weight', loopbox.weight);
                                                        }
                                                    }
                                                    if(loopbox.type=='box')
                                                    {
                                                        g.writeStringField('layout', loopbox.layout);
                                                        g.writeFieldName('contents');
                                                        g.writeStartArray();
                                                        for(contentsData loopboxcon: loopbox.contents)
                                                        {
                                                            g.writeStartObject();
                                                            g.writeStringField('type', loopboxcon.type);
                                                            if(loopboxcon.type=='icon')
                                                            {
                                                                g.writeStringField('url', loopboxcon.url);
                                                            }
                                                            if(loopboxcon.type=='text')
                                                            {
                                                                g.writeStringField('text', loopboxcon.text);
                                                                g.writeFieldName('action');
                                                                g.writeStartObject();
                                                                g.writeStringField('type', loopboxcon.action.type);
                                                                g.writeStringField('uri', loopboxcon.action.uri);
                                                                g.writeEndObject();
                                                                g.writeStringField('color', loopboxcon.color);
                                                                g.writeNumberField('flex', loopboxcon.flex);
                                                                g.writeStringField('offsetTop', loopboxcon.offsetTop);
                                                            }
                                                            g.writeEndObject();
                                                        }
                                                        g.writeEndArray();
                                                        g.writeStringField('spacing', loopbox.spacing);
                                                    }
                                                    g.writeEndObject();
                                                }
                                                g.writeEndArray();
                                                if(loopAction.flex!=null)
                                                {
                                                    g.writeNumberField('flex', loopAction.flex);
                                                }
                                                if(loopAction.spacing!=null)
                                                {
                                                    g.writeStringField('spacing', loopAction.spacing);                                                   
                                                }
                                                if(loopAction.borderWidth!=null)
                                                {
                                                    g.writeStringField('borderWidth', loopAction.borderWidth);
                                                    g.writeStringField('cornerRadius', loopAction.cornerRadius);
                                                    g.writeStringField('borderColor', loopAction.borderColor);
                                                    g.writeStringField('margin', loopAction.margin);
                                                    g.writeStringField('height', loopAction.height);
                                                }
                                            }
                                            if(loopAction.type == 'text')
                                            {
                                                g.writeStringField('text', loopAction.text);
                                                g.writeStringField('color', loopAction.color);                                               
                                                g.writeStringField('size', loopAction.size);
                                                if(loopAction.wrap!=null)
                                                {
                                                    g.writeBooleanField('wrap', loopAction.wrap);
                                                }
                                                if(loopAction.align!=null)
                                                {
                                                    g.writeStringField('align', loopAction.align);
                                                    g.writeStringField('offsetTop', loopAction.offsetTop);
                                                }
                                            }
                                            g.writeEndObject();
                                        }
                                        g.writeEndArray();
                                        if(loopContent.spacing!=null)
                                        {
                                            g.writeStringField('spacing', loopContent.spacing);
                                        }
                                        if(loopContent.paddingAll!=null)
                                        {
                                            g.writeStringField('paddingAll', loopContent.paddingAll);
                                        }
                                        if(loopContent.position!=null)
                                        {
                                            g.writeStringField('position', loopContent.position);
                                            g.writeStringField('backgroundColor', loopContent.backgroundColor);
                                            g.writeStringField('offsetStart', loopContent.offsetStart);
                                        }
                                        if(loopContent.cornerRadius!=null)
                                        {
                                            g.writeStringField('cornerRadius', loopContent.cornerRadius);
                                            g.writeStringField('offsetTop', loopContent.offsetTop);
                                            g.writeStringField('height', loopContent.height);
                                            g.writeStringField('width', loopContent.width);
                                        }
                                        if(loopContent.offsetBottom!=null)
                                        {                                          
                                            g.writeStringField('offsetBottom', loopContent.offsetBottom);                                     
                                            g.writeStringField('offsetEnd', loopContent.offsetEnd);                                          
                                            g.writeStringField('paddingTop', loopContent.paddingTop);
                                        }
                                    }
                                }                       
                                g.writeEndObject();
                            }
                            g.writeEndArray();
                            if(loopcrlContent.body.paddingAll!=null)
                            {
                                g.writeStringField('paddingAll', loopcrlContent.body.paddingAll);
                            }
                            g.writeEndObject();
                        }
                        if(loopcrlContent.footer != null)
                        {
                            g.writeFieldName('footer');
                            g.writeStartObject();
                            g.writeStringField('type', loopcrlContent.footer.type);
                            g.writeStringField('layout', loopcrlContent.footer.layout);
                            g.writeStringField('spacing', loopcrlContent.footer.spacing);
                            g.writeFieldName('contents');
                            g.writeStartArray();
                            for(contentsData loopContent: loopcrlContent.footer.contents)
                            {
                                g.writeStartObject();
                                g.writeStringField('type', loopContent.type);
                                if(loopContent.type=='button')
                                {
                                    if(loopContent.style!=null)
                                    {
                                        g.writeStringField('style', loopContent.style);
                                    }
                                    if(loopContent.height!=null)
                                    {
                                        g.writeStringField('height', loopContent.height);
                                    }
                                    if(loopContent.color!=null)
                                    {
                                        g.writeStringField('color', loopContent.color);
                                    }                                  
                                    g.writeFieldName('action');
                                    g.writeStartObject();
                                    g.writeStringField('type', loopContent.action.type);
                                    g.writeStringField('label', loopContent.action.label);
                                    if(loopContent.action.uri!=null)
                                    {
                                        g.writeStringField('uri', loopContent.action.uri);
                                    }
                                    if(loopContent.action.text!=null)
                                    {
                                        g.writeStringField('text', loopContent.action.text);
                                    }
                                    if(loopContent.action.data!=null)
                                    {
                                        g.writeStringField('data', loopContent.action.data);
                                    }
                                    g.writeEndObject();
                                }                      
                                g.writeEndObject();
                            }
                            g.writeEndArray();
                            g.writeEndObject();
                        }
                    }
                    g.writeEndObject();
                }
                g.writeEndArray();
            }    
            g.writeEndObject();
            
        }     
        g.writeEndObject();
        return g;
    }

    public class senderData
    {
        public string name {get; set;}
        public string iconUrl {get; set;}
        public senderData(){}
    }

    public class quickReplyData 
    {
        public list<itemsData> items {get; set;}
        public quickReplyData(){}
    }

    public class itemsData
    {
        public string type {get; set;}
        public string imageUrl {get; set;}
        public actionData action {get; set;}
        public itemsData(){}
    }

    public class templateData
    {
        public string type {get; set;}
        public string thumbnailImageUrl {get; set;}
        public string imageAspectRatio {get; set;}
        public string imageSize {get; set;}
        public string imageBackgroundColor {get; set;}
        public string title {get; set;}
        public string text {get; set;}
        public actionData defaultAction {get; set;}
        public list<actionData> actions {get; set;}
        public list<columnData> columns {get; set;}
        public templateData(){}
    }

    //imageMap時使用
    public class videoData
    {
        public string originalContentUrl {get; set;}
        public string previewImageUrl {get; set;}
        public areaData area {get; set;}
        public imageAction externalLink{get; set;}
        public videoData(){}
    }

    //imageMap時使用
    public class imageAction
    {
        public string type {get; set;}
        public string text {get; set;}
        public string linkUri {get; set;}
        public string label {get; set;}
        public areaData area {get; set;}

        public imageAction()
        {
        }
    }

    public class areaData
    {
        public integer x {get; set;}
        public integer y {get; set;}
        public integer width {get; set;}
        public integer height {get; set;}
        public areaData(){}
    }

    public class actionData
    {
        public string type {get; set;}
        public string label {get; set;}
        public string uri {get; set;}
        public string data {get; set;}
        public string text {get; set;}
        public actionData(){}
    }

    public class columnData
    {
        public string thumbnailImageUrl {get; set;}
        public string imageBackgroundColor {get; set;}
        public string imageUrl {get; set;}
        public string title {get; set;}
        public string text {get; set;}
        public actionData defaultAction {get; set;}
        public list<actionData> actions {get; set;}
        public actionData action {get; set;}
    }

    public class singleContentData
    {
        public string type {get; set;}
        public string size {get; set;}
        public containerData header {get; set;}
        public containerData body {get; set;}
        public containerData footer {get; set;}
        public containerData hero {get; set;}
        public list<contentsData> contents {get; set;}
        
    }

    public class containerData
    {
        public string type {get; set;}
        public string layout {get; set;}
        public list<contentsData> contents {get; set;}
        public string url {get; set;}
        public string size {get; set;}
        public string aspectRatio {get; set;}
        public string aspectMode {get; set;}
        public actionData action {get; set;}
        public string spacing {get; set;}
        public string gravity {get; set;}
        public string position {get; set;}
        public string offsetTop {get; set;}
        public string offsetBottom {get; set;}
        public string offsetStart {get; set;}
        public string offsetEnd {get; set;}
        public string paddingAll {get; set;}
        public string paddingTop {get; set;}
        public string backgroundColor {get; set;}
        public string paddingBottom {get; set;}
        public string height {get; set;}
        public string borderColor {get; set;}
    }

    public class contentsData
    {
        public string type {get; set;}
        public string text {get; set;}
        public string url {get; set;}
        public string weight {get; set;}
        public string size {get; set;}
        public string layout {get; set;}
        public string margin {get; set;}
        public string color {get; set;}
        public integer flex {get; set;}
        public list<contentsData> contents {get; set;}
        public string spacing {get; set;}
        public Boolean wrap {get; set;}
        public string height {get; set;}
        public actionData action {get; set;}
        public string style {get; set;}
        public containerData footer {get; set;}
        public containerData hero {get; set;}
        public containerData body {get; set;}
        public containerData header {get; set;}
        public string gravity {get; set;}
        public string position {get; set;}
        public string offsetTop {get; set;}
        public string offsetBottom {get; set;}
        public string offsetStart {get; set;}
        public string offsetEnd {get; set;}
        public string aspectRatio {get; set;}
        public string aspectMode {get; set;}
        public string paddingAll {get; set;}
        public string paddingTop {get; set;}
        public string decoration {get; set;}
        public string align {get; set;}
        public string borderWidth {get; set;}
        public string cornerRadius {get; set;}
        public string borderColor {get; set;}
        public string backgroundColor {get; set;}
        public string width {get; set;}

    } 

    public class heroData
    {
        public string type {get; set;}
        public string url {get; set;}
        public string size {get; set;}
        public string aspectRatio {get; set;}
        public string aspectMode {get; set;}
        public actionData action {get; set;}
        public heroData(){}
    }

    public static string changeToUTF32(string inputString)
    {
        integer myIndex = inputString.lastIndexOf('0x1000');
        system.debug(myIndex);
        string returnString  = inputString;
        //第一手字元就是emoji，所以改成>=0。
        while(myIndex >=0)
        {
            returnString  = returnString.left(myIndex) + 
                getEMOJIMap().get(returnString.subString(myIndex, myIndex+8))+
                returnString.subString(myIndex+8,returnString.length());
            system.debug(returnString);

            myIndex = returnString.lastIndexOf('0x1000');
        }

        return returnString;
    }
    /*
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
    */

    //因為無法用取代的方式進行。
    private static map<string, string> mEMOJIMap;
    public static map<string, string> getEMOJIMap()
    {
        if(mEMOJIMap == null)
        {
            mEMOJIMap = new map<string, string>();
            mEMOJIMap.put('0x10008C', '\uDBC0\uDC8C');
            mEMOJIMap.put('0x10008D', '\uDBC0\uDC8D');
            mEMOJIMap.put('0x10008E', '\uDBC0\uDC8E');
            mEMOJIMap.put('0x10008F', '\uDBC0\uDC8F');
            mEMOJIMap.put('0x100090', '\uDBC0\uDC90');
            mEMOJIMap.put('0x100091', '\uDBC0\uDC91');
            mEMOJIMap.put('0x100092', '\uDBC0\uDC92');
            mEMOJIMap.put('0x100093', '\uDBC0\uDC93');
            mEMOJIMap.put('0x100094', '\uDBC0\uDC94');
            mEMOJIMap.put('0x100095', '\uDBC0\uDC95');
            mEMOJIMap.put('0x100096', '\uDBC0\uDC96');
            mEMOJIMap.put('0x100097', '\uDBC0\uDC97');
            mEMOJIMap.put('0x100098', '\uDBC0\uDC98');
            mEMOJIMap.put('0x100099', '\uDBC0\uDC99');
            mEMOJIMap.put('0x10009A', '\uDBC0\uDC9A');
            mEMOJIMap.put('0x10009B', '\uDBC0\uDC9B');
            mEMOJIMap.put('0x10009C', '\uDBC0\uDC9C');
            mEMOJIMap.put('0x10009D', '\uDBC0\uDC9D');
            mEMOJIMap.put('0x10009E', '\uDBC0\uDC9E');
            mEMOJIMap.put('0x10009F', '\uDBC0\uDC9F');

            mEMOJIMap.put('0x1000A0', '\uDBC0\uDCA0');
            mEMOJIMap.put('0x1000A1', '\uDBC0\uDCA1');
            mEMOJIMap.put('0x1000A2', '\uDBC0\uDCA2');
            mEMOJIMap.put('0x1000A3', '\uDBC0\uDCA3');
            mEMOJIMap.put('0x1000A4', '\uDBC0\uDCA4');
            mEMOJIMap.put('0x1000A5', '\uDBC0\uDCA5');
            mEMOJIMap.put('0x1000A6', '\uDBC0\uDCA6');
            mEMOJIMap.put('0x1000A7', '\uDBC0\uDCA7');
            mEMOJIMap.put('0x1000A8', '\uDBC0\uDCA8');
            mEMOJIMap.put('0x1000A9', '\uDBC0\uDCA9');
            mEMOJIMap.put('0x1000AA', '\uDBC0\uDCAA');
            mEMOJIMap.put('0x1000AB', '\uDBC0\uDCAB');
            mEMOJIMap.put('0x1000AC', '\uDBC0\uDCAC');
            mEMOJIMap.put('0x1000AD', '\uDBC0\uDCAD');
            mEMOJIMap.put('0x1000AE', '\uDBC0\uDCAE');
            mEMOJIMap.put('0x1000AF', '\uDBC0\uDCAF');
            mEMOJIMap.put('0x1000B0', '\uDBC0\uDCB0');
            mEMOJIMap.put('0x1000B1', '\uDBC0\uDCB1');
            mEMOJIMap.put('0x1000B2', '\uDBC0\uDCB2');
            mEMOJIMap.put('0x1000B3', '\uDBC0\uDCB3');

            mEMOJIMap.put('0x1000B4', '\uDBC0\uDCB4');
            mEMOJIMap.put('0x1000B5', '\uDBC0\uDCB5');
            mEMOJIMap.put('0x1000B6', '\uDBC0\uDCB6');
            mEMOJIMap.put('0x1000B7', '\uDBC0\uDCB7');
            mEMOJIMap.put('0x1000B8', '\uDBC0\uDCB8');
            mEMOJIMap.put('0x1000B9', '\uDBC0\uDCB9');
            mEMOJIMap.put('0x100078', '\uDBC0\uDC78');
            mEMOJIMap.put('0x100079', '\uDBC0\uDC79');
            mEMOJIMap.put('0x10007A', '\uDBC0\uDC7A');
            mEMOJIMap.put('0x10007B', '\uDBC0\uDC7B');
            mEMOJIMap.put('0x10007C', '\uDBC0\uDC7C');
            mEMOJIMap.put('0x10007D', '\uDBC0\uDC7D');
            mEMOJIMap.put('0x10007E', '\uDBC0\uDC7E');
            mEMOJIMap.put('0x10007F', '\uDBC0\uDC7F');
            mEMOJIMap.put('0x100080', '\uDBC0\uDC80');
            mEMOJIMap.put('0x100081', '\uDBC0\uDC81');
            mEMOJIMap.put('0x100082', '\uDBC0\uDC82');
            mEMOJIMap.put('0x100083', '\uDBC0\uDC83');
            mEMOJIMap.put('0x100084', '\uDBC0\uDC84');
            mEMOJIMap.put('0x100085', '\uDBC0\uDC85');

            mEMOJIMap.put('0x100086', '\uDBC0\uDC86');
            mEMOJIMap.put('0x100087', '\uDBC0\uDC87');
            mEMOJIMap.put('0x100088', '\uDBC0\uDC88');
            mEMOJIMap.put('0x100089', '\uDBC0\uDC89');
            mEMOJIMap.put('0x100088', '\uDBC0\uDC88');
            mEMOJIMap.put('0x100089', '\uDBC0\uDC89');
            mEMOJIMap.put('0x10008A', '\uDBC0\uDC8A');
            mEMOJIMap.put('0x10008B', '\uDBC0\uDC8B');
            mEMOJIMap.put('0x100001', '\uDBC0\uDC01');
            mEMOJIMap.put('0x100002', '\uDBC0\uDC02');
            mEMOJIMap.put('0x100003', '\uDBC0\uDC03');
            mEMOJIMap.put('0x100004', '\uDBC0\uDC04');
            mEMOJIMap.put('0x100005', '\uDBC0\uDC05');
            mEMOJIMap.put('0x100006', '\uDBC0\uDC06');
            mEMOJIMap.put('0x100007', '\uDBC0\uDC07');
            mEMOJIMap.put('0x100008', '\uDBC0\uDC08');
            mEMOJIMap.put('0x100009', '\uDBC0\uDC09');
            mEMOJIMap.put('0x10000A', '\uDBC0\uDC0A');
            mEMOJIMap.put('0x10000B', '\uDBC0\uDC0B');
            mEMOJIMap.put('0x10000C', '\uDBC0\uDC0C');
            mEMOJIMap.put('0x10000D', '\uDBC0\uDC0D');
            mEMOJIMap.put('0x10000E', '\uDBC0\uDC0E');

            mEMOJIMap.put('0x10000F', '\uDBC0\uDC0F');
            mEMOJIMap.put('0x100010', '\uDBC0\uDC10');
            mEMOJIMap.put('0x100011', '\uDBC0\uDC11');
            mEMOJIMap.put('0x100012', '\uDBC0\uDC12');
            mEMOJIMap.put('0x100013', '\uDBC0\uDC13');
            mEMOJIMap.put('0x100014', '\uDBC0\uDC14');
            mEMOJIMap.put('0x100015', '\uDBC0\uDC15');
            mEMOJIMap.put('0x100016', '\uDBC0\uDC16');
            mEMOJIMap.put('0x100017', '\uDBC0\uDC17');
            mEMOJIMap.put('0x100018', '\uDBC0\uDC18');
            mEMOJIMap.put('0x100019', '\uDBC0\uDC19');
            mEMOJIMap.put('0x10001A', '\uDBC0\uDC1A');
            mEMOJIMap.put('0x10001B', '\uDBC0\uDC1B');
            mEMOJIMap.put('0x10001C', '\uDBC0\uDC1C');
            mEMOJIMap.put('0x10001D', '\uDBC0\uDC1D');
            mEMOJIMap.put('0x10001E', '\uDBC0\uDC1E');
            mEMOJIMap.put('0x10001F', '\uDBC0\uDC1F');
            mEMOJIMap.put('0x100020', '\uDBC0\uDC20');
            mEMOJIMap.put('0x100021', '\uDBC0\uDC21');
            mEMOJIMap.put('0x100022', '\uDBC0\uDC22');
            mEMOJIMap.put('0x100023', '\uDBC0\uDC23');

            mEMOJIMap.put('0x100024', '\uDBC0\uDC24');
            mEMOJIMap.put('0x100025', '\uDBC0\uDC25');
            mEMOJIMap.put('0x100026', '\uDBC0\uDC26');
            mEMOJIMap.put('0x100027', '\uDBC0\uDC27');
            mEMOJIMap.put('0x100028', '\uDBC0\uDC28');
            mEMOJIMap.put('0x100029', '\uDBC0\uDC29');
            mEMOJIMap.put('0x10002A', '\uDBC0\uDC2A');
            mEMOJIMap.put('0x10002B', '\uDBC0\uDC2B');
            mEMOJIMap.put('0x10002C', '\uDBC0\uDC2C');
            mEMOJIMap.put('0x10002D', '\uDBC0\uDC2D');
            mEMOJIMap.put('0x10002E', '\uDBC0\uDC2E');
            mEMOJIMap.put('0x10002F', '\uDBC0\uDC2F');
            mEMOJIMap.put('0x100030', '\uDBC0\uDC30');
            mEMOJIMap.put('0x100031', '\uDBC0\uDC31');
            mEMOJIMap.put('0x100032', '\uDBC0\uDC32');
            mEMOJIMap.put('0x100033', '\uDBC0\uDC33');
            mEMOJIMap.put('0x100034', '\uDBC0\uDC34');
            mEMOJIMap.put('0x100035', '\uDBC0\uDC35');
            mEMOJIMap.put('0x100036', '\uDBC0\uDC36');
            mEMOJIMap.put('0x100037', '\uDBC0\uDC37');
            mEMOJIMap.put('0x100038', '\uDBC0\uDC38');
            mEMOJIMap.put('0x100039', '\uDBC0\uDC39');
            mEMOJIMap.put('0x10003A', '\uDBC0\uDC3A');

            mEMOJIMap.put('0x10003B', '\uDBC0\uDC3B');
            mEMOJIMap.put('0x10003C', '\uDBC0\uDC3C');
            mEMOJIMap.put('0x10003D', '\uDBC0\uDC3D');
            mEMOJIMap.put('0x100040', '\uDBC0\uDC40');
            mEMOJIMap.put('0x100041', '\uDBC0\uDC41');
            mEMOJIMap.put('0x100042', '\uDBC0\uDC42');
            mEMOJIMap.put('0x100043', '\uDBC0\uDC43');
            mEMOJIMap.put('0x100044', '\uDBC0\uDC44');
            mEMOJIMap.put('0x100045', '\uDBC0\uDC45');
            mEMOJIMap.put('0x100047', '\uDBC0\uDC47');
            mEMOJIMap.put('0x100049', '\uDBC0\uDC49');
            mEMOJIMap.put('0x10004A', '\uDBC0\uDC4A');
            mEMOJIMap.put('0x10004B', '\uDBC0\uDC4B');
            mEMOJIMap.put('0x10004C', '\uDBC0\uDC4C');
            mEMOJIMap.put('0x10004D', '\uDBC0\uDC4D');
            mEMOJIMap.put('0x10004E', '\uDBC0\uDC4E');
            mEMOJIMap.put('0x10004F', '\uDBC0\uDC4F');
            mEMOJIMap.put('0x100050', '\uDBC0\uDC50');
            mEMOJIMap.put('0x100051', '\uDBC0\uDC51');
            mEMOJIMap.put('0x100053', '\uDBC0\uDC53');

            mEMOJIMap.put('0x100054', '\uDBC0\uDC54');
            mEMOJIMap.put('0x100055', '\uDBC0\uDC55');
            mEMOJIMap.put('0x100056', '\uDBC0\uDC56');
            mEMOJIMap.put('0x100057', '\uDBC0\uDC57');
            mEMOJIMap.put('0x100058', '\uDBC0\uDC58');
            mEMOJIMap.put('0x100059', '\uDBC0\uDC59');
            mEMOJIMap.put('0x10005A', '\uDBC0\uDC5A');
            mEMOJIMap.put('0x10005B', '\uDBC0\uDC5B');
            mEMOJIMap.put('0x10005C', '\uDBC0\uDC5C');
            mEMOJIMap.put('0x10005D', '\uDBC0\uDC5D');
            mEMOJIMap.put('0x10005E', '\uDBC0\uDC5E');
            mEMOJIMap.put('0x10005F', '\uDBC0\uDC5F');
            mEMOJIMap.put('0x100060', '\uDBC0\uDC60');
            mEMOJIMap.put('0x100061', '\uDBC0\uDC61');
            mEMOJIMap.put('0x100062', '\uDBC0\uDC62');
            mEMOJIMap.put('0x100063', '\uDBC0\uDC63');
            mEMOJIMap.put('0x100064', '\uDBC0\uDC64');
            mEMOJIMap.put('0x100065', '\uDBC0\uDC65');
            mEMOJIMap.put('0x100066', '\uDBC0\uDC66');
            mEMOJIMap.put('0x100067', '\uDBC0\uDC67');
            mEMOJIMap.put('0x100068', '\uDBC0\uDC68');
            mEMOJIMap.put('0x100069', '\uDBC0\uDC69');

            mEMOJIMap.put('0x10006A', '\uDBC0\uDC6A');
            mEMOJIMap.put('0x10006B', '\uDBC0\uDC6B');
            mEMOJIMap.put('0x10006C', '\uDBC0\uDC6C');
            mEMOJIMap.put('0x10006D', '\uDBC0\uDC6D');
            mEMOJIMap.put('0x10006E', '\uDBC0\uDC6E');
            mEMOJIMap.put('0x10006F', '\uDBC0\uDC6F');
            mEMOJIMap.put('0x100070', '\uDBC0\uDC70');
            mEMOJIMap.put('0x100071', '\uDBC0\uDC71');
            mEMOJIMap.put('0x100072', '\uDBC0\uDC72');
            mEMOJIMap.put('0x100073', '\uDBC0\uDC73');
            mEMOJIMap.put('0x100074', '\uDBC0\uDC74');
            mEMOJIMap.put('0x100075', '\uDBC0\uDC75');
            mEMOJIMap.put('0x100076', '\uDBC0\uDC76');
            mEMOJIMap.put('0x100077', '\uDBC0\uDC77');
        }

        return mEMOJIMap;
    }
}
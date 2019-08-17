function flaToXML(flaPath, xmlPath)
{	
	var flaDoc = flaPath ? fl.openDocument(pathToURI(flaPath)): fl.getDocumentDOM();
	if (!xmlPath && flaDoc.path)
	{
		xmlPath = removeExtension(flaDoc.path) + ".xml";
	}
	
	fl.outputPanel.clear();
	var tracer = new FlaTracer(flaDoc);
	tracer.traceFla();
	if (xmlPath)
	{
		fl.outputPanel.save(pathToURI(xmlPath));
	}

	if (flaPath)
	{
		fl.closeDocument(flaDoc);
	}
}

function FlaTracer(flaDoc)
{
	this.indentCount = 0;
	this.tabs = "";
	this.bitmapsInfo = {}; // 

	this.addTrace = function(text)
	{
		if (this.tabs.length != this.indentCount)
		{
			this.tabs = "";
			for (var i=0; i < this.indentCount; i++)
			{
				this.tabs += "\t";
			}
		}
		fl.outputPanel.trace(this.tabs + text);
	}

	this.openTag = function(tagName, object, properties)
	{
		this.addTrace("<" + tagName + getPropertyString(object, properties) + ">");
		this.indentCount++;
	}

	this.closeTag = function (tagName, properties)
	{
		this.indentCount--;
		this.addTrace("</"+tagName+">");
	}

	this.addTag = function (tagName, object, properties)
	{
		this.addTrace("<" + tagName + getPropertyString(object, properties) + "/>");
	}	

	this.traceTimeline = function(timeline)
	{
		for (var i=0; i < timeline.layers.length; i++)
		{
			var layer = timeline.layers[i];
			//skipping some tags to make xml a tiny bit more readable
			var skipFrameTag = (layer.frames.length == 1 && layer.frames[0].duration == 1 && !layer.frames[0].actionScript);
			var emptyLayerTag = skipFrameTag && layer.frames[0].elements.length == 0;
			if (!emptyLayerTag)
			{
				this.openTag("layer", layer, ["name"]);
			}
			else
			{
				this.addTag("layer", layer, ["name"]);
			}
			
			for (var p=0; p < layer.frames.length; p++)
			{
				var frame = layer.frames[p];
				if (!skipFrameTag)
				{
					this.openTag("frame", frame, ["name", "duration", "actionScript"]); //TODO: consider adding tween information					
				}
				this.traceFrame(frame);
				if (!skipFrameTag)
				{
					this.closeTag("frame");
				}
			}

			if (!emptyLayerTag)
			{
				this.closeTag("layer");
			}
		}
	}

	this.traceFrame = function(frame)
	{
		for (var i=0; i < frame.elements.length; i++)
		{
			//tracing element
			var element = frame.elements[i];
			var tagName = "element";

			var properties = ["x", "y", "width", "height"];
			if (element.name) 
			{
				properties.unshift("name");
			}
			if (element.rotation)
			{
				properties.push("rotation");
			}
			
			var propertyObj = {
				name: element.name,
				x: element.x,
				y: element.y,
				width: element.width,
				height: element.height,
				rotation: element.rotation
			}

			if (element.elementType == "instance")
			{
				properties.push("libraryItem", "scaleX", "scaleY");
				propertyObj.libraryItem =  element.libraryItem ? element.libraryItem.name: null;
				propertyObj.scaleX =  element.scaleX;
				propertyObj.scaleY =  element.scaleY;
				tagName = "symbol";

				if (element.instanceType == "bitmap")
				{
					if (element.libraryItem && this.bitmapsInfo[propertyObj.libraryItem] == null)
					{
						this.bitmapsInfo[propertyObj.libraryItem] = {
							name: propertyObj.libraryItem,
							hPixels: element.hPixels,
							vPixels: element.vPixels,
							md5: null	//TODO: store bitmap data hash
						}
					}
					tagName = "bitmap_instance"
				}				
			}
			else if (element.elementType == "shape")
			{
				tagName = "shape";
			}
			else if (element.elementType == "text")
			{
				properties.push( "face", "size", "alignment", "lineType");
				propertyObj.face = element.getTextAttr("face");
				propertyObj.alignment = element.getTextAttr("alignment");
				propertyObj.size = element.getTextAttr("size");
				propertyObj.lineType = element.lineType;

				// Bug workaround - for some reason x and y of text field are two pixels off from value shown in flash authring tool.
				propertyObj.x = element.left;
				propertyObj.y = element.top;

				tagName = "text_field";
			}
			else
			{
				properties.push("elementType");
				this.addTag("element", element, properties);
			}

			this.addTag(tagName, propertyObj, properties);
		}
	}

	this.traceLibrary = function (library)
	{
		this.openTag("library");
		for (var i=0; i < library.items.length; i++)
		{
			//tracing library item
			var item = library.items[i];
			if (item.itemType == "movie clip")
			{
				if (item.linkageImportForRS)
				{
					this.addTag("imported_clip", item, ["name", "linkageIdentifier", "linkageURL"]);
				}
				else if (item.symbolType == "movie clip")
				{
					this.openTag("movie_clip", item, ["name", "linkageClassName", "linkageIdentifier"]);					
					this.traceTimeline(item.timeline);
					this.closeTag("movie_clip");
				}
				else
				{
					this.addTag("symbol", item, ["name", "symbolType"]);
				}
			}
			else if (item.itemType == "bitmap")
			{
				var info = this.bitmapsInfo[item.name];
				if (info != null)
				{
					this.addTag("bitmap", info, ["name", "hPixels", "vPixels", "md5"]);
				}
				else
				{
					this.addTag("unused_bitmap", item, ["name"]);
				}
			}
			else if (item.itemType != "folder")
			{
				this.addTag("item", item, ["name", "itemType"]);
			}

		}
		this.closeTag("library");
	}

	this.traceFla = function()
	{
		for (var i=0; i < flaDoc.timelines.length; i++)
		{
			this.openTag("timeline");
			this.traceTimeline(flaDoc.timelines[i]);
			this.closeTag("timeline");			
		}		
		this.traceLibrary(flaDoc.library);
	}
}

function getPropertyString(object, properties)
{
	var propertyString = "";
	if (properties)
	{
		for (var i=0; i < properties.length; i++)
		{
			var propertyName = properties[i];
			if (object[propertyName] != null)
			{
				propertyString += " "+propertyName+'=\"'+object[propertyName]+'"';
			}
		}
	}
	else
	{
		for (var propertyName in object)
		{
			if (object[propertyName] != null)
			{
				propertyString += " "+propertyName+'=\"'+object[propertyName]+'"';
			}
		}
	}
	return propertyString;
}

function removeExtension(path)
{
	var extPos = path.lastIndexOf(".")
	if (extPos == -1)
	{
		return path;
	}
	
	return path.substr(0, extPos);
}

function pathToURI(path)
{
	return "file:///"+path.replace(new RegExp("\\\\", "g"), "/");
}

function createToken(path)
{
	fl.outputPanel.clear();	
	fl.outputPanel.save(pathToURI(path));
}


//flaToXML();

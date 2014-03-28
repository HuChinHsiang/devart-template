﻿package  {	//flash	import flash.display.MovieClip;	import flash.events.MouseEvent;	//import flash.media.StageWebView;	import flash.geom.Rectangle;	import flash.events.Event;	import flash.events.IOErrorEvent;	import flash.events.ProgressEvent;	import flash.events.DataEvent;	import flash.system.Security;	import flash.system.LoaderContext;	import flash.display.Loader;	import flash.net.URLRequest;	import flash.net.URLVariables;	import flash.net.URLRequestMethod;	import flash.text.TextField;	import flash.net.URLLoader;	import flash.utils.setTimeout;	//twitter	import isle.susisu.twitter.Twitter;	import isle.susisu.twitter.TwitterRequest;	import isle.susisu.twitter.events.TwitterRequestEvent;		//facebook	import com.facebook.graph.FacebookDesktop;		//google search	import be.boulevart.google.ajaxapi.search.web.GoogleWebSearch;	import be.boulevart.google.events.GoogleApiEvent;	import be.boulevart.google.ajaxapi.search.GoogleSearchResult;	import be.boulevart.google.ajaxapi.search.web.data.GoogleWebItem;		//news	import be.boulevart.google.ajaxapi.search.news.GoogleNewsSearch;	import be.boulevart.google.ajaxapi.search.news.data.GoogleNewsItem;		//video	import be.boulevart.google.ajaxapi.search.videos.GoogleVideoSearch;	import be.boulevart.google.ajaxapi.search.videos.data.GoogleVideo;		//flickr	import com.adobe.webapis.flickr.events.FlickrResultEvent;	import com.adobe.webapis.flickr.FlickrService;	import com.adobe.webapis.flickr.PagedPhotoList;	import com.adobe.webapis.flickr.Photo;	import com.adobe.webapis.flickr.PhotoSize;	//osc	import of.ofxFlashCommunication;	import of.ofxFlashCommunicationEvent;		//minicomps	import com.bit101.components.Window;	import com.bit101.components.PushButton;	import com.bit101.components.InputText;	import com.bit101.components.IndicatorLight;			public class internetAPI extends MovieClip {		//twitter		var twitter:Twitter;		//facebook				//google		private var googleSearch:GoogleWebSearch;		private var googleResult:GoogleSearchResult;				//news		private var newsSearch:GoogleNewsSearch;		private var newsResult:GoogleSearchResult;				//video		private var videoSearch:GoogleVideoSearch;		private var videoResult:GoogleSearchResult;				//flickr		private var fs:FlickrService;		private var photoList:PagedPhotoList;		private var photoIndex:int;				//osc		private var comm:ofxFlashCommunication = null;		//webview		//private var sw:StageWebView;				//minicomps		private var p_win:Window;		private var p_fblogin:PushButton;		private var p_getfbfd:PushButton;		private var p_google:PushButton;		private var p_flickr:PushButton;		private var p_wiki:PushButton;		private var p_youtube:PushButton;		private var p_news:PushButton;		private var p_updatetwitter:PushButton;		private var p_twitterfd:PushButton;		private var p_trends:PushButton;		private var p_googletxt:InputText;		private var p_flickrtxt:InputText;		private var p_wikitxt:InputText;		private var p_youtubetxt:InputText;		private var p_newstxt:InputText;		private var p_twittertxt:InputText;		private var p_connect:IndicatorLight;		private var p_send:IndicatorLight;		private var p_receive:IndicatorLight;				private var i:int;				public function internetAPI() {			// constructor code			initComps();						initTwitter();			initFacebook();			initGoogle();			initFlickr();			initNews();			initVideo();			initWiki();			initTrends();			initSocket();		}		private function initComps():void{			p_win=new Window();			//p_win.hasCloseButton=true;			p_win.hasMinimizeButton=false;			p_win.height=350;			p_win.width=350;			p_win.title='internet API panel';			addChild(p_win);						p_googletxt=new InputText();			p_flickrtxt=new InputText();			p_wikitxt=new InputText();			p_youtubetxt=new InputText();			p_newstxt=new InputText();			p_twittertxt=new InputText();						p_fblogin=new PushButton();			p_fblogin.label='FB Login';			p_fblogin.x=p_fblogin.y=10;			p_win.addChild(p_fblogin);			p_getfbfd=new PushButton();			p_getfbfd.label='Get FB FD';			p_getfbfd.x=p_getfbfd.y=10;			p_win.addChild(p_getfbfd);						p_google=new PushButton();			p_google.label='Google';			p_google.x=120			p_google.y=40;			p_win.addChild(p_google);						p_googletxt.x=10;			p_googletxt.y=40;			p_win.addChild(p_googletxt);			p_flickr=new PushButton();			p_flickr.label='Flickr';			p_flickr.x=120;			p_flickr.y=70;			p_win.addChild(p_flickr);						p_flickrtxt.x=10;			p_flickrtxt.y=70;			p_win.addChild(p_flickrtxt);			p_wiki=new PushButton();			p_wiki.label='Wikipedia';			p_wiki.x=120;			p_wiki.y=100;			p_win.addChild(p_wiki);			p_wikitxt.x=10;			p_wikitxt.y=100;			p_win.addChild(p_wikitxt);			p_youtube=new PushButton();			p_youtube.label='Youtube';			p_youtube.x=120;			p_youtube.y=130;			p_win.addChild(p_youtube);			p_youtubetxt.x=10;			p_youtubetxt.y=130;			p_win.addChild(p_youtubetxt);			p_news=new PushButton();			p_news.label='News';			p_news.x=120;			p_news.y=160;			p_win.addChild(p_news);			p_newstxt.x=10;			p_newstxt.y=160;			p_win.addChild(p_newstxt);			p_updatetwitter=new PushButton();			p_updatetwitter.label='tweet!';			p_updatetwitter.x=120;			p_updatetwitter.y=190;			p_win.addChild(p_updatetwitter);			p_twittertxt.x=10;			p_twittertxt.y=190;			p_win.addChild(p_twittertxt);			p_twitterfd=new PushButton();			p_twitterfd.label='Twitter FD';			p_twitterfd.x=230;			p_twitterfd.y=190;			p_win.addChild(p_twitterfd);						p_trends=new PushButton();			p_trends.label='Google Trends';			p_trends.x=10;			p_trends.y=220;			p_win.addChild(p_trends);						p_connect=new IndicatorLight();			p_send=new IndicatorLight();			p_receive=new IndicatorLight();						p_connect.label='OF connect status';			p_connect.x=10;			p_connect.y=250;			p_win.addChild(p_connect);						p_send.label='send to OF';			p_send.x=10;			p_send.y=270;			p_send.color=0x00ff00;			p_win.addChild(p_send);						p_receive.label='receive from OF';			p_receive.x=10;			p_receive.y=290;			p_receive.color=0x00ff00;			p_win.addChild(p_receive);		}		private function initTwitter():void{			twitter=new Twitter('B5Jwzds38R3Ob9oZlgwNg', 'DETXnPNePjZt2zImvcMWaipDvpcP8VwesDMGXLzg','1647484538-raPiNhEKidyJUlsM36FrRyJh72aKGFmXxB3Akls','nIUXTWag6pw3YN0dWPQ9psXHpWLdCSbkmdrxaBhqp60')			var rtRequest:TwitterRequest=twitter.oauth_requestToken();			rtRequest.addEventListener(TwitterRequestEvent.COMPLETE,rtComplete);		}		private function rtComplete(e:TwitterRequestEvent):void{			var atRequest:TwitterRequest=twitter.statuses_homeTimeline();			atRequest.addEventListener(TwitterRequestEvent.COMPLETE,atComplete);			p_updatetwitter.addEventListener(MouseEvent.CLICK,twitterLogin);			p_twitterfd.addEventListener(MouseEvent.CLICK,twitterFd);		}		private function twitterFd(e:MouseEvent):void{			var ftRequest:TwitterRequest=twitter.friends_list();			ftRequest.addEventListener(TwitterRequestEvent.COMPLETE,ftComplete);		}		private function ftComplete(e:TwitterRequestEvent):void{			var request:TwitterRequest = e.currentTarget as TwitterRequest;			var fds:Object = JSON.parse(request.response as String);			trace(request.response);			for(i=0;i<fds.users.length;i++){				var obj:obj_mc=new obj_mc();				var loader:Loader=new Loader();				loader.load(new URLRequest(fds.users[i].profile_image_url_https));				obj.addChild(loader);				obj.x=Math.random()*stage.stageWidth;				obj.y=Math.random()*stage.stageHeight;				this.addChild(obj);			}		}		private function twitterLogin(e:MouseEvent):void{			twitter.statuses_update(p_twittertxt.text);		}		private function atComplete(e:TwitterRequestEvent):void{			var request:TwitterRequest = e.currentTarget as TwitterRequest;			var timeline:Array = JSON.parse(request.response as String) as Array;			//trace(request.response);		}					//google		private function initGoogle():void{			googleSearch=new GoogleWebSearch();			p_google.addEventListener(MouseEvent.CLICK,googleClick);		}		private function googleClick(e:MouseEvent):void{			trace('google search');						googleSearch.search(p_googletxt.text,0,'nl');			googleSearch.addEventListener(GoogleApiEvent.WEB_SEARCH_RESULT,ongoogleResult);		}		private function ongoogleResult(e:GoogleApiEvent):void{			googleResult=e.data as GoogleSearchResult;			for each(var result:GoogleWebItem in googleResult.results){				trace(result.titleNoFormatting);				var obj:obj_mc=new obj_mc();				var txt:TextField=new TextField();				txt.width=200;				txt.height=50;				txt.text=result.titleNoFormatting;				obj.addChild(txt);				obj.x=Math.random()*stage.stageWidth;				obj.y=Math.random()*stage.stageHeight;				this.addChild(obj);			}		}				// news		private function initNews():void{			newsSearch=new GoogleNewsSearch();			p_news.addEventListener(MouseEvent.CLICK,newsClick);		}		private function newsClick(e:MouseEvent):void{			trace('news search');			newsSearch.addEventListener(GoogleApiEvent.NEWS_SEARCH_RESULT,onnewsResult);			newsSearch.search(p_newstxt.text);		}		private function onnewsResult(e:GoogleApiEvent):void{			newsResult=e.data as GoogleSearchResult;			for each(var result:GoogleNewsItem in newsResult.results){				trace(result.titleNoFormatting);				var obj:obj_mc=new obj_mc();				var txt:TextField=new TextField();				txt.width=200;				txt.height=50;				txt.text=result.titleNoFormatting;				obj.addChild(txt);				obj.x=Math.random()*stage.stageWidth;				obj.y=Math.random()*stage.stageHeight;				this.addChild(obj);			}		}				// video		private function initVideo():void{			videoSearch=new GoogleVideoSearch();			p_youtube.addEventListener(MouseEvent.CLICK,videoClick);		}		private function videoClick(e:MouseEvent):void{			trace('video search');			videoSearch.addEventListener(GoogleApiEvent.VIDEO_SEARCH_RESULT,onvideoResult);			videoSearch.search(p_youtubetxt.text);		}		private function onvideoResult(e:GoogleApiEvent):void{			videoResult=e.data as GoogleSearchResult;			for each(var result:GoogleVideo in videoResult.results){								trace(result.playUrl);				var obj:obj_mc=new obj_mc();				var loader:Loader=new Loader();				loader.load(new URLRequest(result.thumbUrl));				obj.addChild(loader);				obj.x=Math.random()*stage.stageWidth;				obj.y=Math.random()*stage.stageHeight;				this.addChild(obj);			}		}				//facebook		private function initFacebook():void{			FacebookDesktop.init('571664929542195',fbinitHandler);		}		private function fbinitHandler(success:Object,fail:Object):void{			if(success){    				trace("fb loggedin");				fbLogin();			}else{				trace("fb not loggedin"); 				p_fblogin.addEventListener(MouseEvent.CLICK,fbLoginClick);			}		}		private function fbLoginClick(e:MouseEvent ):void{			FacebookDesktop.login(fbloginHandler,['publish_stream']);		}		private function fbloginHandler(success:Object,fail:Object):void{			if(success){				trace("fb loggedin");				fbLogin();			}else{				trace("fb no loggedin"); 			}		}		private function fbLogin():void{			p_fblogin.visible=false;			p_getfbfd.addEventListener(MouseEvent.CLICK,getFdClick);		}		private function getFdClick(e:MouseEvent ):void{			FacebookDesktop.api('me/friends',fbFriendList);		}		private function fbFriendList(success:Object,fail:Object):void{			if(success){				trace('geted friend');				var fdList:int=success.length;				if(fdList>50){					fdList=50;				}				for(i=0;i<fdList;i++){					var obj:obj_mc=new obj_mc();					var loader:Loader=new Loader();					loader.load(new URLRequest('https://graph.facebook.com/'+success[i].id+'/picture?type=square'));					obj.addChild(loader);					obj.x=Math.random()*stage.stageWidth;					obj.y=Math.random()*stage.stageHeight;					this.addChild(obj);				}							}		}				//flickr		private function initFlickr():void{			//Security.allowDomain('http://www.flickr.com');			//Security.loadPolicyFile('http://api.flickr.com/crossdomain.xml');					fs = new FlickrService('209af37bd2fed4ebaf2af2240c52d653');			fs.secret = '609da663233da901';			fs.auth.getFrob();			fs.addEventListener(FlickrResultEvent.AUTH_GET_FROB, flicrGetFrob);		}		private function flicrGetFrob(evt:FlickrResultEvent):void {			if (evt.success) {				trace("flickr login");				//				p_flickr.addEventListener(MouseEvent.CLICK,flickrClick);			}		}		private function flickrClick(e:MouseEvent):void{			fs.photos.search('',p_flickrtxt.text);			fs.addEventListener(FlickrResultEvent.PHOTOS_SEARCH, flickrPhotoSearch);		}		private function flickrPhotoSearch(evt:FlickrResultEvent):void {			trace("flickr search finish");			photoList = evt.data.photos as PagedPhotoList;			var temp:Photo;			var p:int;			var len:int = photoList.photos.length;			for (var i = 0; i < len; i++) {				temp = photoList.photos[i];				p = Math.ceil(Math.random() * len);				photoList.photos[i] = photoList.photos[p];				photoList.photos[p] = temp;			}			trace('flickr images:'+len);			for(i=0;i<photoList.photos.length-1;i++){				if(photoList.photos[i]){					fs.addEventListener(FlickrResultEvent.PHOTOS_GET_SIZES, hPhotoSize);					fs.photos.getSizes(photoList.photos[i].id);				}			}		}				private function hPhotoSize(evt:FlickrResultEvent):void {			var sizeArr:Array = evt.data.photoSizes;						var s:PhotoSize = sizeArr[0];			var obj:obj_mc=new obj_mc();			var l:Loader = new Loader();			l.contentLoaderInfo.addEventListener(Event.COMPLETE, hPhotoComplete);			l.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);			l.load(new URLRequest(s.source),new LoaderContext(true));			obj.addChild(l);			obj.x=Math.random()*stage.stageWidth;			obj.y=Math.random()*stage.stageHeight;			this.addChild(obj);		}		private function ioErrorHandler(e:IOErrorEvent):void{			trace('io error');		}		private function hPhotoComplete(e:Event):void {			//e.target.loader.width=50;			//e.target.loader.height=50;		}				//wiki		private function initWiki():void{			p_wiki.addEventListener(MouseEvent.CLICK,wikiClick);		}		private function wikiClick(e:MouseEvent):void{			searchWiki();		}		private function searchWiki():void{			var urlLoader:URLLoader=new URLLoader(new URLRequest('http://en.wikipedia.org/w/api.php?action=query&prop=extracts&titles='+p_wikitxt.text+'&format=json&exintro=1'));			urlLoader.addEventListener(Event.COMPLETE,wikiComplete);		}		private function wikiComplete(e:Event):void{			//trace(e.target.data);			var objwiki:Object=JSON.parse(e.target.data);			for (var pageId in objwiki.query.pages) {				if (objwiki.query.pages.hasOwnProperty(pageId)) {					trace(objwiki.query.pages[pageId].extract);					var obj:obj_mc=new obj_mc();					var txt:TextField=new TextField();					txt.width=200;					txt.height=50;					txt.htmlText=objwiki.query.pages[pageId].extract;					obj.addChild(txt);					obj.x=Math.random()*stage.stageWidth;					obj.y=Math.random()*stage.stageHeight;					this.addChild(obj);				}			}		}				//google hot trend		private function initTrends():void{			p_trends.addEventListener(MouseEvent.CLICK,getTrend2);					}		private function getTrend(e:MouseEvent):void{			var loader : URLLoader = new URLLoader();  			var request : URLRequest = new URLRequest("http://www.google.com/trends/hottrends/hotItems");  						request.method = URLRequestMethod.POST;  			var variables : URLVariables = new URLVariables();  			variables.ajax = "1";  			variables.pn = "p1";  			//p1= US, p8= AU, p13= canada, p15=Germany, p10=HK, p3=India, p6=Israel, p4=Japan, p14=Russia,p5=singapore, p12=taiwan, p9=UK, 			request.data = variables;  						loader.addEventListener(Event.COMPLETE, on_complete);  			loader.load(request);  		}		private function on_complete(e : Event):void{  			//trace(e.target.data);			var obj:Object;			//trace(e.target.data);			obj=JSON.parse(e.target.data);			var i,j:int;			//trace(obj.trendsByDateList.length)			var str:String='';			for(i=0;i<obj.trendsByDateList.length;i++){				for(j=0;j<obj.trendsByDateList[i].trendsList.length;j++){					//trace(obj.trendsByDateList[i].trendsList[j].title);					//trace(obj.trendsByDateList[i].trendsList[j].imgUrl);					str+='\n$'+obj.trendsByDateList[i].trendsList[j].title+'\n$'+obj.trendsByDateList[i].trendsList[j].imgUrl;										//imgUrl					//imgLinkUrl				}			}			trace(str);			sendToOF(str);								//for(i=0;i<obj		}		 		private function getTrend2(loc:String=''):void{			 //http://hawttrends.appspot.com/api/terms/			 //1US,3India,4Japan,5singapore,6Israel,8AU,9UK,10HK,12taiwan,13canada,14russia,15germany 			var loader2 : URLLoader = new URLLoader();  			var request2 : URLRequest = new URLRequest("http://hawttrends.appspot.com/api/terms/");  			 			loader2.addEventListener(Event.COMPLETE, on_complete2);  			loader2.load(request2);  		}		private function on_complete2(e : Event):void{  			var obj2:Object;						obj2=JSON.parse(e.target.data);			//trace(e.target.data);			var i:int;			for(i=0;i<obj2[1].length;i++){				trace(obj2[1][i])			}			for(i=0;i<obj2[5].length;i++){				trace(obj2[5][i])			}			for(i=0;i<obj2[8].length;i++){				trace(obj2[8][i])			}			for(i=0;i<obj2[9].length;i++){				trace(obj2[9][i])			}		}														//socket		private function initSocket():void		{			//comm = new ofxFlashCommunication("127.0.0.1",1234);			comm = new ofxFlashCommunication("192.168.255.13",1234);			comm.addEventListener('connect ioerror',OFIOerror);			comm.addEventListener('connect close',OFconnectclose);			comm.addEventListener('connected',OFconnect);			comm.addEventListener(				ofxFlashCommunicationEvent.NEW_DATA				,onNewData			);					}		private function OFIOerror(e:Event):void{			p_connect.color=0xff0000;			p_connect.isLit =true;			trace('of io error');		}		private function OFconnect(e:Event):void{			p_connect.color=0x00ff00;			p_connect.isLit =true;			trace('of connect');		}		private function OFconnectclose(e:Event):void{			p_connect.color=0xff0000;			p_connect.isLit =true;			trace('connect close');		}		private function onNewData(oEv:ofxFlashCommunicationEvent):void {			trace(oEv.getMessage());			p_receive.isLit =true;			setTimeout(function(){					   p_receive.isLit =false;					   },100);		}				//傳資料到socket server		private function sendToOF(str:String):void		{			comm.send(str);			p_send.isLit =true;			setTimeout(function(){					   p_send.isLit =false;					   },100);		}	}	}
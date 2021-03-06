package com.pomodairo.twitter
{ 
        import com.pomodairo.components.config.TwitterConfigPanel;
        import com.pomodairo.core.Storage;
import com.pomodairo.settings.ConfigItemName;
import com.pomodairo.settings.ConfigItemName;
import com.pomodairo.settings.ConfigManager;
import com.swfjunkie.tweetr.Tweetr;
        import com.swfjunkie.tweetr.events.TweetEvent;
        import com.swfjunkie.tweetr.oauth.OAuth;
        import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
        
        import flash.events.Event;
        import flash.geom.Rectangle;
        import flash.html.HTMLLoader;
        import flash.net.URLRequest;
        import flash.net.navigateToURL;
        import flash.utils.Dictionary;
        
        import mx.controls.Alert;

		/**
		 * Handles OAuth authentication towards Twitter. We will store the OAuth shared
		 * secret in the SQLite database to avoid entering credentials every time we restart
		 * the application.
		 * 
		 * If twitter is disabled in configuration we will clear the shared secrets in the database. 
		 */
        public class TwitterClient 
        { 
			

			
			private var tweetr:Tweetr;
			private var oauth:OAuth;
			private var htmlLoader:HTMLLoader;
			
			private var authHasFailed:Boolean = false;
			
			//--------------------------------------------------------------------------
			//
			//  Initialization for Authentication
			//
			//--------------------------------------------------------------------------
			
			public function authenticate():void
			{
				tweetr = new Tweetr();
				// tweetr.serviceHost = "http://tweetr.swfjunkie.com/proxy"; // Might be needed... or not
				
				oauth = new OAuth();
				oauth.consumerKey = "RSkqe2Iuu3oVxRBxokh7rA"; 
				oauth.consumerSecret = "bX1iytYZ76Blzko33KLt0xUgQjI1fZBrL51ZezCY2I"; 
				oauth.callbackURL = "http://netsyndicate.net/";
				oauth.pinlessAuth = true;
				
				oauth.addEventListener(OAuthEvent.COMPLETE, handleOAuthEvent);
				oauth.addEventListener(OAuthEvent.ERROR, handleOAuthEvent);
				
				// Check if we have OAuth shared keys stored that we can use
				var cfg:ConfigManager = ConfigManager.instance;
				
				if (cfg.hasConfig(ConfigItemName.OAUTH_TOKEN)
					&& cfg.hasConfig(ConfigItemName.OAUTH_TOKEN_SECRET)) {
					// Use stored credentials
					oauth.oauthToken = cfg.getConfig(ConfigItemName.OAUTH_TOKEN);
					oauth.oauthTokenSecret = cfg.getConfig(ConfigItemName.OAUTH_TOKEN_SECRET);
					tweetr.oAuth = oauth;
					
				} else {
					// Request allowance from user
					htmlLoader = HTMLLoader.createRootWindow(true, null, true, new Rectangle(50,50, 780, 500));
					htmlLoader.stage.nativeWindow.alwaysInFront = true;
					oauth.htmlLoader = htmlLoader;
					oauth.getAuthorizationRequest();
				}
				
			}
			
			public function clearSharedCredentials():void {
				ConfigManager.instance.clearConfig(ConfigItemName.OAUTH_TOKEN);
				Storage.instance.removeConfig(ConfigItemName.OAUTH_TOKEN_SECRET);
			}
			
			//--------------------------------------------------------------------------
			//
			//  Eventhandling
			//
			//--------------------------------------------------------------------------
			
			private function handleOAuthEvent(event:OAuthEvent):void
			{
				if (event.type == OAuthEvent.COMPLETE)
				{
					htmlLoader.stage.nativeWindow.close();
					tweetr.oAuth = oauth;
					// Save shared keys in the database
					ConfigManager.instance.setConfig(ConfigItemName.OAUTH_TOKEN, oauth.oauthToken);
					ConfigManager.instance.setConfig(ConfigItemName.OAUTH_TOKEN_SECRET, oauth.oauthTokenSecret);
				}
				else
				{
					trace("Twitter Auth Failed. OauthEvent."+event.type.toLocaleUpperCase());
				}
			}
			
			//--------------------------------------------------------------------------
			//
			//  Methods
			//
			//--------------------------------------------------------------------------
			
			public function setStatus(text:String):void {
				try {
					if (!authHasFailed) {
						trace("Set Twitter Status: "+text);
						tweetr.updateStatus(text);
					}
				} catch (error:Error) {
					Alert.show("Twitter-authentication failed =(\nMake sure you entered correct credentials in the popup window. You can also try and disable/re-enable twitter.");
					authHasFailed = true;
				}
			}
		}
} 
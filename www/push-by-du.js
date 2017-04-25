var exec = cordova.require('cordova/exec');


var PushByDu = function() {

};

/**
 * Unregister from push notifications
 */

PushByDu.prototype.init = function(apiKey, pushMode, onMessageFunc) {

	PushByDu.prototype.onMessage = onMessageFunc;

    exec(null, null, 'PushByDu', 'init', [apiKey,pushMode]);
};

/**
 * Unregister from push notifications
 */

PushByDu.prototype.echo = function(message) {
    exec(null, null, 'PushByDu', 'echo', [message]);
};

PushByDu.prototype.unBind = function() {
    exec(null, null, 'PushByDu', 'unBind', []);
};

require('cordova/channel').onCordovaReady.subscribe(function() {
	exec(onMessage, onError, 'PushByDu', 'onMessage', []);
	function onMessage(message) {
		console.log("onMessage   In");
		console.log(message);
		if(message.type=="onBind"){
			PushByDu.prototype.channelId = message.data.channelId;
			PushByDu.prototype.userId = message.data.userId;
			PushByDu.prototype.appId = message.data.appId;
			cordova.fireDocumentEvent('onBind',{message:message});
		}else{
			//PushByDu.prototype.onMessage(message);
			cordova.fireDocumentEvent('onBaiduMessage',{message:message});
		}
	}
	function onError(error){
		console.log("onError   In");
		console.log(error);
	}
});




module.exports = new PushByDu();
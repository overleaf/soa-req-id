uuid = require('node-uuid')

module.exports =
	getCallbackAndReqId: (args, callbackOverride)->
		callback = args[args.length-1]
		sl_req_id = args[args.length-2]
		if(!isFunction(callback))
			sl_req_id = callback
		if typeof(sl_req_id) != "string"
			sl_req_id = null
		else if sl_req_id.indexOf("sl_req_id") == -1
			sl_req_id = null

		if callbackOverride?
			callback = callbackOverride
			
		return {sl_req_id:sl_req_id, callback:callback}

	use : ->
		return (req, res, next)=>
			req.sl_req_id = req.headers["sl_req_id"] || @newId()
			next()

	newId: ->
		return "sl_req_id:#{uuid.v4()}"


isFunction = (fun)->
	return typeof(fun) == "function"

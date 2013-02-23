uuid = require('node-uuid')

module.exports =
	getCallbackAndReqId: (callback, sl_req_id)->
		if typeof sl_req_id == "function"
			return sl_req_id: null, callback: sl_req_id
		else
			return sl_req_id: sl_req_id, callback: callback

	use : ->
		return (req, res, next)=>
			currentHeader = req.headers["sl_req_id"]
			if !currentHeader? || currentHeader == 'null'
				id = @newId()
			else
				id = currentHeader
			req.sl_req_id = id
			next()

	newId: ->
		value = "sl_req_id:#{uuid.v4()}"
		return value


isFunction = (fun)->
	return typeof(fun) == "function"

SandboxedModule = require('sandboxed-module')
assert = require('assert')
require('chai').should()
sinon = require('sinon')
path = require('path')
modulePath = '../soa-req-id'


describe 'third party data store', ->
	stubbed_sl_req_id = "this_is_an_id_stubbed"
	beforeEach ->
		@uuid =
			v4: -> return stubbed_sl_req_id
			oi: "   kkk"
		
		@helper = SandboxedModule.require modulePath, requires:
			'node-uuid' : @uuid

	describe "callback finder", ->
		req_id = "sl_req_id:j1klej8jklsajd"
		origonalCallback = ->

		it 'should work with no other arguemnts', ->
			args = [req_id, origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with 1 other arguemnt', ->
			args = ["project_id", req_id, origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with 3 other arguemnts', ->
			args = ["project_id", "user_id", {},req_id, origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with only the callback', ->
			args = [origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			callback.should.equal(origonalCallback)

		it 'should work with only the sl_req_id', ->
			args = [req_id]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id

		it 'should work with no req id', ->
			args = [{}, origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

		it 'should not set the sl_req_id if the second by last arg does not start with sl_req_id', ->
			args = ["radom_string", origonalCallback]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

		it 'should take a second argument which is the definate callback and still return the req id', ->
			args = [req_id]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args, origonalCallback)
			assert.equal sl_req_id, req_id
			callback.should.equal origonalCallback

		it 'should take a second argument which is the definate callback and return null req id', ->
			args = ["not req"]
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args, origonalCallback)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

	describe "pulling the header out and putting it on the request as middlewear", ->

		it 'should put the sl_req_id on the request if it is already there', (done)->
			middlewear = @helper.use()
			sl_req_id = "this_is_an_id"
			req = headers:{"sl_req_id":sl_req_id}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal sl_req_id

		it 'should generate a new sl_req_id if it is not already on there', (done)->
			middlewear = @helper.use()
			req = {headers:{}}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal "sl_req_id:#{stubbed_sl_req_id}"


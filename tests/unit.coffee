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
			args = {0:req_id, 1:origonalCallback}
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with 1 other arguemnt', ->
			args = 0:"project_id", 1:req_id, 2:origonalCallback
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with 3 other arguemnts', ->
			args = 0:"project_id", 1:"user_id", 2:{}, 3:req_id, 4:origonalCallback
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id
			callback.should.equal(origonalCallback)

		it 'should work with only the callback', ->
			args = 0:origonalCallback
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			callback.should.equal(origonalCallback)

		it 'should work with only the sl_req_id', ->
			args = 0:req_id
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			sl_req_id.should.equal req_id

		it 'should work with no req id', ->
			args = 0:{}, 1:origonalCallback
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

		it 'should not set the sl_req_id if the second by last arg does not start with sl_req_id', ->
			args = 0:"radom_string", 1:origonalCallback
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

		it 'should take a second argument which is the definate callback and still return the req id', ->
			args = 0:req_id
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args, origonalCallback)
			assert.equal sl_req_id, req_id
			callback.should.equal origonalCallback

		it 'should take a second argument which is the definate callback and return null req id', ->
			args = 0:"not req"
			{callback, sl_req_id} = @helper.getCallbackAndReqId(args, origonalCallback)
			assert.equal sl_req_id, null
			callback.should.equal origonalCallback

	describe "pulling the header out and putting it on the request as middlewear", ->

		it 'should put the sl_req_id on the request if it is already there', (done)->
			middlewear = @helper.use()
			sl_req_id = "sl_req_id:045872d3-7c8c-42ba-b2d9-4ae49b73a373"
			req = headers:{"sl_req_id":sl_req_id}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal sl_req_id

		it 'should generate a new sl_req_id if it is null', (done)->
			middlewear = @helper.use()
			req = {headers:{"sl_req_id":null}}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal "sl_req_id:#{stubbed_sl_req_id}"

		it 'should generate a new sl_req_id if it is not already on there', (done)->
			middlewear = @helper.use()
			req = {headers:{"sl_req_id":undefined}}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal "sl_req_id:#{stubbed_sl_req_id}"

		it 'should generate a new sl_req_id if the value is an string of null', (done)->
			middlewear = @helper.use()
			req = {headers:{"sl_req_id":"null"}}
			middlewear(req, {}, done)
			req.sl_req_id.should.equal "sl_req_id:#{stubbed_sl_req_id}"

	describe "getting a new id", ->
		it 'should start with sl_req_id', ->
			@helper.newId().should.equal "sl_req_id:#{stubbed_sl_req_id}"


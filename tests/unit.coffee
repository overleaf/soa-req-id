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

	describe "getCallbackAndReqId", ->
		req_id = "sl_req_id:j1klej8jklsajd"
		callback = () ->

		describe "when the request id and callback are present", ->
			beforeEach ->
				@result = @helper.getCallbackAndReqId(callback, req_id)

			it "should return them both untouched", ->
				@result.callback.should.equal callback
				@result.sl_req_id.should.equal req_id

		describe "when the request id is missing", ->
			beforeEach ->
				@result = @helper.getCallbackAndReqId(callback, null)

			it "should return the callback and null for the request id", ->
				@result.callback.should.equal callback
				(@result.sl_req_id == null).should.equal true

		describe "when the request id is a function", ->
			beforeEach ->
				@result = @helper.getCallbackAndReqId((() ->), callback)

			it "should return the function as the callback", ->
				@result.callback.should.equal callback
				(@result.sl_req_id == null).should.equal true

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


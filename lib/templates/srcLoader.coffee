# Buildr
window.Buildr ?= class
	# Options
	scripts: null
	styles: null
	baseUrl: null
	appendEl: null
	beforeEl: null
	serverCompilation: null

	# Construct a new Buildr instance
	constructor: ({scripts,styles,appendEl,baseUrl,beforeEl,serverCompilation}) ->
		@scripts = scripts or []
		@styles = styles or []
		@appendEl = appendEl or document.head or document.getElementsByTagName('head')[0]
		@baseUrl = baseUrl or @getRootUrl()
		@beforeEl = beforeEl or document.head.lastChild
		@serverCompilation = serverCompilation or false

	# Get the root url of our page
	getRootUrl: ->
		# Prepare
		host = (document.location.hostname||document.location.host)
		protocol = document.location.protocol
		rootUrl = "#{protocol}//#{host}"

		# Port
		if document.location.port
			rootUrl += ':'+document.location.port
		rootUrl += '/'

		# Return
		rootUrl

	# Load Styles and Scripts
	load: (next) ->
		me = @
		me.loadStyle ->
			me.loadScript ->
				next() if next

	# Script Loader
	loadScriptIndex: 0
	loadScript: (next) ->
		# Prepare
		me = @
		scriptSrc = @baseUrl + @scripts[@loadScriptIndex]
		scriptSrc += '?js' if @serverCompilation
		scriptLoaded = ->
			if @readyState? and @readyState isnt 'complete'
				return
			if @src? and @src isnt scriptSrc
				return
			++me.loadScriptIndex
			me.loadScript next

		# Exists
		if @scripts[@loadScriptIndex]?
			scriptEl = document.createElement('script')
			scriptEl.src = scriptSrc
			if /\.coffee$/.test(scriptSrc)
				scriptEl.type = 'text/coffeescript'
			else
				scriptEl.onreadystatechange = scriptLoaded
				scriptEl.onload = scriptLoaded
				scriptEl.onerror = scriptLoaded
			@appendEl.appendChild scriptEl, @beforeEl.nextSibling
			@beforeEl = scriptEl
			if /\.coffee$/.test(scriptSrc)
				scriptLoaded()

		# Completed
		else
			next()

		# Return
		true

	# Style Loader
	loadStyleIndex: 0
	loadStyle: (next) ->
		# Prepare
		me = @
		styleHref = @baseUrl + @styles[@loadStyleIndex]
		styleHref += '?css' if @serverCompilation
		styleLoaded = ->
			++me.loadStyleIndex
			me.loadStyle next

		# Exists
		if @styles[@loadStyleIndex]?
			styleEl = document.createElement('link')
			styleEl.href = styleHref
			styleEl.media = 'screen'
			if /\.less$/.test(styleHref)
				styleEl.rel = 'stylesheet/less'
			else
				styleEl.rel = 'stylesheet'
			styleEl.type = 'text/css'
			#styleEl.onreadystatechange = styleLoaded
			#styleEl.onload = styleLoaded
			#styleEl.onerror = styleLoaded
			@appendEl.insertBefore styleEl, @beforeEl.nextSibling
			@beforeEl = styleEl
			styleLoaded()

		# Completed
		else
			next()

		# Return
		true

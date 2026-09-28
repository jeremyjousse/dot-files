// Preload patch for github-labels to use modern HTTP Authorization header
// instead of deprecated access_token query param.
const Module = require('module')

try {
	const origRequire = Module.prototype.require
	Module.prototype.require = function patchedRequire(id, ...args) {
		const res = origRequire.call(this, id, ...args)
		if (id === 'github' && res && res.prototype && !res.prototype.patchedAuth) {
			const origAuth = res.prototype.authenticate
			res.prototype.authenticate = function patchedAuthenticate(options) {
				const isOAuth = options && options.type === 'oauth' && options.token
				const authOptions = isOAuth ? { ...options, type: 'token' } : options
				return origAuth.call(this, authOptions)
			}
			res.prototype.patchedAuth = true
		}
		return res
	}
} catch {
	// Pass through without failing if patching cannot occur
}

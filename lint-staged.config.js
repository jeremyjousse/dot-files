module.exports = {
	'*.{js,cjs,mjs,jsx,ts,cts,mts,tsx}': ['oxlint --fix', 'oxfmt --write'],
	'*.{json,jsonc}': ['oxfmt --write'],
}

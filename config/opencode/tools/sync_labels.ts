import { execFileSync } from 'node:child_process'
import { existsSync, readFileSync, realpathSync } from 'node:fs'
import { homedir } from 'node:os'
import { isAbsolute, join, relative, resolve } from 'node:path'
import { tool } from '@opencode-ai/plugin'

interface LabelSpec {
	name: string
	color?: string
	description?: string
}

export default tool({
	description: 'Synchronize GitHub repository labels using native gh label CLI commands from a JSON specification',
	args: {
		repo: tool.schema
			.string()
			.optional()
			.describe('Target repository in owner/repo format or URL (defaults to active git repository)'),
		config: tool.schema
			.string()
			.optional()
			.describe('Path to the JSON labels configuration file (defaults to .github/labels.json or global fallback)'),
	},
	async execute(args: Record<string, any> = {}, context: any = {}) {
		const cwd = context?.directory || process.cwd()

		let repo = typeof args.repo === 'string' ? args.repo.trim() : ''
		if (repo) {
			const match = repo.match(/github\.com[/:]([^/\s?#]+\/[^/\s?#]+)/)
			if (match) {
				repo = match[1]
			}
			repo = repo.replace(/\.git$/, '')
		} else {
			try {
				const remoteUrl = execFileSync('git', ['config', '--get', 'remote.origin.url'], {
					cwd,
					encoding: 'utf8',
					stdio: ['ignore', 'pipe', 'ignore'],
					timeout: 5000,
				}).trim()
				const match = remoteUrl.match(/github\.com[/:]([^/\s?#]+\/[^/\s?#]+)/)
				if (match) {
					repo = match[1].replace(/\.git$/, '')
				}
			} catch {
				// Fall back to gh repo view
			}

			if (!repo) {
				try {
					repo = execFileSync('gh', ['repo', 'view', '--json', 'nameWithOwner', '-q', '.nameWithOwner'], {
						cwd,
						encoding: 'utf8',
						stdio: ['ignore', 'pipe', 'ignore'],
						timeout: 10000,
					}).trim()
				} catch {
					throw new Error('Could not determine target repository. Please specify with repo (owner/repo).')
				}
			}
		}

		const isExplicitConfig = Boolean(typeof args.config === 'string' && args.config.trim())
		let configFile = isExplicitConfig ? (args.config as string).trim() : ''
		if (configFile) {
			if (!isAbsolute(configFile)) {
				configFile = resolve(cwd, configFile)
			}
		} else {
			const projectLabels = join(cwd, '.github', 'labels.json')
			const globalLabels = join(homedir(), '.config', 'opencode', 'labels.json')
			if (existsSync(projectLabels)) {
				configFile = projectLabels
			} else if (existsSync(globalLabels)) {
				configFile = globalLabels
			} else {
				throw new Error(
					'No labels configuration file found. Please provide a config path or create .github/labels.json.',
				)
			}
		}

		if (!existsSync(configFile)) {
			throw new Error(`Labels configuration file not found at: ${configFile}`)
		}

		let realConfigFile: string
		try {
			realConfigFile = realpathSync(configFile)
		} catch {
			realConfigFile = resolve(configFile)
		}

		if (isExplicitConfig) {
			let realCwd: string
			try {
				realCwd = existsSync(cwd) ? realpathSync(cwd) : resolve(cwd)
			} catch {
				realCwd = resolve(cwd)
			}

			const rel = relative(realCwd, realConfigFile)
			const isOutside = rel.startsWith('..') || isAbsolute(rel)
			if (isOutside) {
				if (typeof context?.ask === 'function') {
					await context.ask({
						permission: 'external_directory',
						patterns: [realConfigFile],
						always: [realConfigFile],
						metadata: {
							path: realConfigFile,
							description: 'Read labels configuration outside workspace',
						},
					})
				} else {
					throw new Error(
						`Explicit labels configuration file resolves outside the workspace directory: ${realConfigFile}`,
					)
				}
			}
		}

		let rawLabels: LabelSpec[]
		try {
			rawLabels = JSON.parse(readFileSync(configFile, 'utf8'))
		} catch (err) {
			throw new Error(
				`Failed to parse labels configuration file ${configFile}: ${err instanceof Error ? err.message : String(err)}`,
			)
		}

		if (typeof context?.ask === 'function') {
			await context.ask({
				permission: 'sync_labels',
				patterns: [repo],
				always: [repo],
				metadata: {
					repo,
					config: configFile,
					count: rawLabels.length,
				},
			})
		}

		const results: string[] = []
		let statusCount = 0
		let typeCount = 0
		let priorityCount = 0
		let effortCount = 0

		for (const label of rawLabels) {
			if (!label.name) continue

			const cmdArgs = ['label', 'create', label.name, '--force', '--repo', repo]
			if (label.color) {
				cmdArgs.push('--color', label.color.replace(/^#/, ''))
			}
			if (label.description) {
				cmdArgs.push('--description', label.description)
			}

			execFileSync('gh', cmdArgs, {
				cwd,
				encoding: 'utf8',
				stdio: ['ignore', 'pipe', 'pipe'],
				timeout: 10000,
			})
			results.push(label.name)

			if (label.name.startsWith('Status:')) statusCount++
			else if (label.name.startsWith('Type:')) typeCount++
			else if (label.name.startsWith('Priority:')) priorityCount++
			else if (label.name.startsWith('Effort:')) effortCount++
		}

		return [
			`Successfully synchronized ${results.length} labels for ${repo} using ${configFile}:`,
			`- Status:   ${statusCount}`,
			`- Type:     ${typeCount}`,
			`- Priority: ${priorityCount}`,
			`- Effort:   ${effortCount}`,
		].join('\n')
	},
})

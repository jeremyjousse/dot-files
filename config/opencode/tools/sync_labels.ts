import { execFileSync } from 'node:child_process'
import { existsSync, readFileSync } from 'node:fs'
import { homedir } from 'node:os'
import { join } from 'node:path'

interface LabelSpec {
	name: string
	color?: string
	description?: string
}

export default {
	description: 'Synchronize GitHub repository labels using native gh label CLI commands from a JSON specification',
	args: {},
	async execute(args: Record<string, any> = {}, context: any = {}) {
		const cwd = context?.directory || process.cwd()

		let repo = typeof args.repo === 'string' ? args.repo.trim() : ''
		if (repo) {
			const match = repo.match(/github\.com[/:]([^/]+\/[^/.]+)/)
			if (match) {
				repo = match[1].replace(/\.git$/, '')
			}
		} else {
			try {
				const remoteUrl = execFileSync('git', ['config', '--get', 'remote.origin.url'], {
					cwd,
					encoding: 'utf8',
					stdio: ['ignore', 'pipe', 'ignore'],
					timeout: 5000,
				}).trim()
				const match = remoteUrl.match(/github\.com[/:]([^/]+\/[^/.]+)/)
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

		let configFile = typeof args.config === 'string' ? args.config.trim() : ''
		if (!configFile) {
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

		let rawLabels: LabelSpec[]
		try {
			rawLabels = JSON.parse(readFileSync(configFile, 'utf8'))
		} catch (err) {
			throw new Error(
				`Failed to parse labels configuration file ${configFile}: ${err instanceof Error ? err.message : String(err)}`,
			)
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
}

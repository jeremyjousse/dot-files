---
name: documentation-best-practices
description: Use when writing, reviewing, or refactoring technical documentation, READMEs, ADRs, changelogs, or docstrings using ASD-STE100 Simplified Technical English.
---

# Documentation Best Practices

Write technical documentation in clear, unambiguous, concise English. Apply these ASD-STE100 principles to prose for
software documentation. Preserve the meaning and technical details of the source.

## Writing Rules

### Sentence length and structure

- Keep procedural instructions to 20 words or fewer.
- Keep conceptual descriptions to 25 words or fewer.
- Put one idea or instruction in each sentence.
- Limit paragraphs to six sentences. Use shorter paragraphs when they improve scanning.
- Count prose words. Do not count code, file paths, flags, environment variables, or other exact technical payloads.

### Voice and mood

- Use active voice in prose.
- Use imperative verbs for steps and procedures. Write `Run the command`, not `You should run the command`.
- Name the actor when a conceptual sentence needs one. Prefer `The tool reads the config file` over passive constructions.

### Terminology and precision

- Use one term consistently for each concept. Define unfamiliar terms before using them.
- Avoid vague qualifiers such as `simply`, `easily`, `basically`, `just`, and `appropriate`.
- Avoid idioms, metaphors, and unnecessary jargon.
- Replace ambiguous uses of `it`, `this`, or `that` with the specific noun.
- State conditions, outcomes, and limits explicitly. Do not imply a guarantee that the software does not provide.

### Sequential clarity

- Present procedures with multiple actions as numbered steps in chronological order.
- Put prerequisites, constraints, and warnings before the action they affect.
- Give each step one primary action. Put verification after the action it checks.

### Technical payload integrity

- Preserve code spans, CLI flags, file paths, environment variables, identifiers, and error messages exactly.
- Do not rewrite, translate, or normalize technical payloads to satisfy prose rules.
- Keep prose outside code spans concise and consistent with the surrounding documentation.

## Rewrite Examples

**Bad:** You should simply run `pnpm install` and it will basically set things up for you.

**Good:** Run `pnpm install` to install the project dependencies.

**Bad:** The config file is read by the CLI after it starts.

**Good:** The CLI reads the config file after it starts.

**Bad:** Before continuing, check the permissions. Then create the file. After that, run the command.

**Good:**

1. Check that you have write permission in the target directory.
2. Create the file.
3. Run `tool --config config.yml`.

## Pre-output Checklist

- [ ] Does each procedural sentence contain no more than 20 words?
- [ ] Does each conceptual sentence contain no more than 25 words?
- [ ] Does each sentence express one idea, and does each paragraph contain at most six sentences?
- [ ] Does prose use active voice and imperative verbs for procedures?
- [ ] Does each concept use one consistent term, without vague qualifiers or ambiguous pronouns?
- [ ] Do numbered procedures follow chronological order, with prerequisites and warnings first?
- [ ] Are all technical payloads exact and unchanged?

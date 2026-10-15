#!/bin/sh
# PreToolUse hook: remind the agent to load linear-method before writing a Linear issue.
cat >/dev/null
printf '%s\n' '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Before writing this Linear issue: if the linear-method skill is not loaded in this session, load it first, then read 3-5 recent issues from the target team and match their style."}}'

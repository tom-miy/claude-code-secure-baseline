# db-change-review

Use this skill before making database schema changes, bulk data changes, or destructive data operations.

## Required Review Steps

1. State the exact operation you intend to perform.
2. Identify the environment: local, test, staging, or production.
3. Identify affected tables, rows, migrations, files, or services.
4. Describe the expected impact and rollback option.
5. Prefer a dry run, transaction, migration preview, or staging check first.
6. Stop and ask for explicit human approval before executing destructive or production-adjacent operations.

## Operations That Require Approval

- `DROP`
- `TRUNCATE`
- unrestricted `DELETE`
- unrestricted `UPDATE`
- production database access
- irreversible migrations
- bulk writes to user, customer, billing, auth, or audit data

## Output Format

When this skill applies, respond with:

```text
Operation:
Environment:
Affected data:
Risk:
Verification:
Rollback:
Approval needed:
```

Do not proceed with the high-risk operation until approval is explicitly given in the current conversation.

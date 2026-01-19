# Common commands for the Beancount ledger

# Default: show help
default:
    @just --list

# Record transactions and push
record message="record: add transactions":
    git add *.bean
    git commit -m "{{message}}"
    git push

# Check ledger syntax
check:
    uv run bean-check books/main.bean

# Query ledger
query q:
    uv run bean-query books/main.bean "{{q}}"

# Show balances
balance:
    uv run bean-query books/main.bean "SELECT account, sum(position) WHERE account ~ 'Assets' GROUP BY account ORDER BY account"

# Start fava
fava:
    uv run fava -H 127.0.0.1 books/main.bean

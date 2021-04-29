#!/bin/sh

set -ex

cd crates.io-index

total_commits=`git rev-list HEAD --count`
echo "Found $total_commits commits."
if [ "$total_commits" -lt 50000 ]
then
    echo "Below threshold, skipping squash."
    exit 0
fi

now=`date '+%Y-%m-%d'`
git config user.name "Cron Squash"
git config user.email ""
git remote -v show
head=`git rev-parse HEAD`
git push -f origin $head:refs/heads/snapshot-$now

msg=$(cat <<-END
Collapse index into one commit

Previous HEAD was $head, now on the \`snapshot-$now\` branch

More information about this change can be found [online] and on [this issue]

[online]: https://internals.rust-lang.org/t/cargos-crate-index-upcoming-squash-into-one-commit/8440
[this issue]: https://github.com/rust-lang/crates-io-cargo-teams/issues/47
END
)

new_rev=$(git commit-tree HEAD^{tree} -m "$msg")

git push origin $new_rev:refs/heads/master \
  --force-with-lease=refs/heads/master:$head

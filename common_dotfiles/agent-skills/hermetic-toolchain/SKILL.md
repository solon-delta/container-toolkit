---
name: hermetic-toolchain
description: Set up a hermetic toolchain — a Makefile that runs every build, test, and lint command inside a podman container. Use when the user wants a containerized toolchain, a Makefile for building and testing, reproducible builds, or a build that does not depend on host tools.
---

The toolchain is **hermetic**: no target touches a host compiler, linter, or package manager. Every command runs inside one podman container, from one pinned image, over the current working directory.

## 1. Grill the specifics

Invoke the `grilling` skill on the toolchain design. Look up facts in the repo first (language, package manager, existing scripts, test command), then put the decisions to the user.

Cover:

- The image and its tag. A pinned tag, never `latest`.
- The target list. `build` and `test` are mandatory. Offer the ones the language expects (`check`, `fmt`, `lint`, `run`, `clean`).
- The command behind each target.
- The container working directory that the current directory mounts onto.
- The package cache. Ask whether a named volume holds it, and which path in the container it covers.
- Extra podman flags the toolchain needs (`--user`, capabilities, ports, environment).

Done when the image tag, every target name, and the command behind each target are written down and confirmed.

## 2. Write the Makefile

Put one `PODMAN` variable at the top and prefix every recipe with it. Shape:

```make
.PHONY: build test

IMAGE    := <registry>/<image>:<tag>

PODMAN   := podman run --rm \
            -v "$(PWD)":<workdir> \
            -w <workdir> \
            $(IMAGE)

build:
	$(PODMAN) <build command>

test:
	$(PODMAN) <test command>
```

Done when every confirmed target appears in the file, each recipe line starts with `$(PODMAN)`, and `.PHONY` lists all of them.

## 3. Prove it runs

Run `make build` and `make test`. Read the output of each.

Done when both targets exit 0, or when a failure is reported to the user with the command output.

## Rules

- One image for all targets. A second image needs the user to ask for it.
- Recipe lines use a tab, not spaces.
- Quote `"$(PWD)"` so a path with a space still mounts.
- A named volume for the cache survives `--rm`. A bind mount into the host home directory does not belong here.
- Keep the recipes to one command each. Multi-step logic belongs in a script that the container runs.

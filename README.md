# Container Toolkit

Container definitions for distrobox and podman to use applications in a more or less sandboxed environment without polluting the host system.

## Structure

```
common_dotfiles/
  <some-config-folder>/            # Shared configurations baked into podman images
containers/
  <container-name>/
    distrobox.ini                  # Distrobox container definition
    Containerfile                  # Podman container definition
scripts/
  entrypoint.sh                    # Shared container entrypoint (env-var driven)
  sandbox.sh                       # Shared host sandbox launcher (env-var driven)
  <container>-sandbox.sh           # Thin host wrappers setting AGENT_NAME/AGENT_IMAGE
```

- **Distrobox containers** use `distrobox assemble` and inherit the host shell and
  home directory automatically. Container-specific manifests live in their own
  subdirectory under `containers/`.
- **Podman containers** are built from a Containerfile. Shared configs from
  `common_dotfiles/` are baked into the image at build time. Persistent state
  (auth, session data) is stored under `$DBX_CONTAINER_HOME_PREFIX/<container>/`
  and bind-mounted at runtime. A single shared entrypoint (`scripts/entrypoint.sh`)
  symlinks baked-in defaults into the persistent home without overwriting
  existing files, and merges the baked-in settings file into the live one so
  image default updates keep reaching existing users. Behavior is controlled
  per-container via the `AGENT_*` environment variables set in each Containerfile.

## Prerequisites

Optionally set the `DBX_CONTAINER_HOME_PREFIX` environment variable to control
where persistent container home directories are stored (shared with distrobox).
If unset, podman containers default to `$HOME`.

## Usage

```sh
make help                # list available targets
```

The Makefile provides targets for:
- Creating and destroying distrobox containers
- Building and installing podman container images

Wrapper scripts for podman containers are installed to `~/.local/bin/` and can be run from any directory.

## Creating New Containers

- **Distrobox**: Add a `distrobox.ini` file in `containers/<name>/`.
- **Podman**: Add a `Containerfile` in `containers/<name>/` and add a corresponding wrapper script.

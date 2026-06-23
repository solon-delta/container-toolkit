# Distrobox Toolkit

Container definitions for distrobox and podman.

## Structure

```
common_dotfiles/                   # Shared dotfiles for podman container builds
containers/
  office/                          # Distrobox container for office/academic work
    distrobox.ini
  <future-container>/              # Raw podman containers
    Containerfile
    dotfiles/
```

- **Distrobox containers** use `distrobox assemble` and inherit the host shell and
  home directory automatically. Container-specific manifests live in their own
  subdirectory under `containers/`.
- **Podman containers** are built from a Containerfile. Shared dotfiles from
  `common_dotfiles/` and container-specific files from `dotfiles/` are copied
  into the image at build time. Containers are run with `--rm -it` and the
  working directory bind-mounted.

## Usage

```sh
make help              # list available targets
make create-office     # create the office distrobox container
make destroy-office    # destroy the office distrobox container
```

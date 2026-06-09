# asdf-pulumi

[![Builds, tests & co](https://github.com/compono/asdf-pulumi/actions/workflows/workflow.yml/badge.svg)](https://github.com/compono/asdf-pulumi/actions/workflows/workflow.yml)

[Pulumi](https://www.pulumi.com/) plugin for the [asdf](https://github.com/asdf-vm/asdf) version manager.

## Prerequisites

- Make sure you have the required dependencies installed:
  - `curl`
  - `git`
  - `tar` (Linux/macOS releases)
  - `unzip` (Windows releases)

## Installation

```bash
asdf plugin add pulumi https://github.com/compono/asdf-pulumi.git
```

## Usage

```bash
# Show all installable versions
asdf list all pulumi

# Install the latest version (or a specific one)
asdf install pulumi latest
asdf install pulumi 3.245.0

# Set a version globally or for the current project
asdf set pulumi latest
```

Check the [asdf documentation](https://asdf-vm.com/manage/versions.html) for
more on installing and managing versions.

## License

Licensed under the [GNU General Public License v3.0](./LICENSE).

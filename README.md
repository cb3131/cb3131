# cb3131

A Roblox game project using an external-editor workflow. Game code lives on the
filesystem as [Luau](https://luau.org/) and is synced into Roblox Studio with
[Rojo](https://rojo.space/). The toolchain is managed by
[Rokit](https://github.com/rojo-rbx/rokit), so every contributor (and the Cloud
Agent) gets the exact same pinned tool versions.

> Roblox Studio itself only runs on Windows and macOS. This repo is the
> filesystem side of the workflow: you edit and validate code here (works on
> Linux/CI too), then use Rojo to live-sync it into Studio on your local
> machine.

## Project layout

| Path | Maps to (in Studio) | Purpose |
| --- | --- | --- |
| `src/shared` | `ReplicatedStorage/Shared` | Code shared by client and server |
| `src/server` | `ServerScriptService/Server` | Server scripts |
| `src/client` | `StarterPlayerScripts/Client` | Client scripts |
| `tests/` | – | Lune unit tests (run outside Studio) |
| `default.project.json` | – | Rojo project / instance tree |

## Tooling

Pinned in `rokit.toml`:

- **Rojo** – build/serve the place, sync into Studio
- **Wally** – package manager (`wally.toml`)
- **StyLua** – formatter (`stylua.toml`)
- **Selene** – linter (`selene.toml`)
- **Lune** – standalone Luau runtime used to run unit tests
- **luau-lsp** – language server + `analyze` for type-checking

## Setup

Install [Rokit](https://github.com/rojo-rbx/rokit), then from the repo root:

```sh
rokit install          # install the pinned tools
```

Cloud Agents run `.cursor/install.sh`, which installs Rokit + the tools,
fetches Roblox global type definitions, and generates a Rojo sourcemap.

## Common commands

```sh
rojo build default.project.json -o build.rbxlx      # build a place file
rojo serve default.project.json --address 0.0.0.0   # live-sync server for Studio
stylua src tests                                     # format
stylua --check src tests                             # verify formatting (CI)
selene src tests                                     # lint
lune run tests/run.luau                              # run unit tests

# Type-check the Roblox source (needs the generated artifacts):
rojo sourcemap default.project.json -o sourcemap.json
curl -sSf https://raw.githubusercontent.com/JohnnyMorganz/luau-lsp/main/scripts/globalTypes.d.luau -o globalTypes.d.luau
luau-lsp analyze --sourcemap=sourcemap.json --defs=globalTypes.d.luau src
```

`sourcemap.json`, `globalTypes.d.luau`, and build outputs are generated
artifacts and are git-ignored.

## Connecting Roblox Studio

1. On your Windows/macOS machine, install the Rojo plugin in Studio.
2. Run `rojo serve` (locally, or against this environment's exposed port 34872).
3. In Studio, open the Rojo plugin and click **Connect**.

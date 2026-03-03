# Far Manager Help to Markdown Tool

`HlfToMd` converts FAR Manager `.hlf` help files to Markdown (`.md`).

## System Requirements

- Windows, Linux, or macOS
- .NET 10 SDK (the project targets `net10.0`)
- A source `.hlf` file (for example `FarEng.hlf`)

## Build

From the project root:

```bash
dotnet build
```

The compiled executable is created under `bin/Debug/net10.0/`.

## Usage

Run from the project root:

```bash
dotnet run
```

Default behavior:

- Input: `FarEng.hlf`
- Output: `FarEng.md`

Run with a custom input file:

```bash
dotnet run -- MyHelp.hlf
```

Custom behavior:

- Input: `MyHelp.hlf`
- Output: `MyHelp.md`

You can also pass a relative or absolute path:

```bash
dotnet run -- docs/Manual.hlf
```

The output is written next to the input file as `docs/Manual.md`.

## Notes

Generated output may include LaTeX color commands: `\color` and `\colorbox`.
If you plan to publish the generated Markdown on GitHub, note that GitHub does not support `\colorbox` rendering.

Part of this project was vibe-coded with supervision.

## Feedback

File an issue or request a new feature in [GitHub Issues](https://github.com/yegor-mialyk/far-plugins/issues).

## License

Copyright (C) 1995-2026 Yegor Mialyk. All rights reserved.

Licensed under the [MIT](LICENSE) License.

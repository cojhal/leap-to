# leap-to

CLI for cd'ing to path aliases.

This is a PureScript reproduction of an old, quirky Perl script I wrote years ago and still use daily. The original can be found [here](original.md).

## Installation

```bash
> npm install -g leap-to
```

## Basic usage

Register current directory as `mypath`:

```bash
> leap register mypath
```

Register path as `mypath`:

```bash
> leap register mypath ./path/to/register
```

Change directory to `mypath`:

```bash
> `leap mypath`
```

Print help text:

```bash
> leap --help
```
